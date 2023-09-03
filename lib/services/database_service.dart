import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fetcher/fetcher.dart';
import 'package:flutter/foundation.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/utils/exceptions/invalid_operation_exception.dart';

class DatabaseService {
  static final instance = DatabaseService();

  final _db = FirebaseFirestore.instance;

  late final _users = _db.collection('users').withConverter<User>(
    fromFirestore: (snapshot, _) => User.fromJson(snapshot.id, snapshot.data()!),
    toFirestore: (model, _) => model.toJson(),    // Only used for the set command, which is never used.
  );

  /// Add a new user.
  /// Return user id.
  Future<String> addUser(String username) async {
    await throwIfNoInternet();    // Firebase 'add' command need internet, and never stops if there is no connection.
    final userRef = await _users.add(User(id: '', name: username));   // User.id is ignored at serialisation
    debugPrint('[DatabaseService] user $username added');
    return userRef.id;
  }

  Future<User?> getPartner(String id) async {
    debugPrint('[DatabaseService] get partner $id');
    return (await _users.doc(id).get()).data();
  }

  /// Set user partner
  /// Update [userId]'s partner AND [partnerId]'s partner
  Future<void> setPartner(String userId, String partnerId) async {
    debugPrint('[DatabaseService] set user\'s partner');
    Map<String, dynamic> buildData(String partnerId) => {
      'partnerId': partnerId,
    };

    // Use a transaction to make sure the partner is free
    await _db.runTransaction((transaction) async {
      final partnerRef = _users.doc(partnerId);

      // Check partner is free
      final partner = (await transaction.get(partnerRef)).data();
      if (partner == null) throw const InvalidOperationException('Partenaire introuvable');
      if (partner.hasPartner) throw const InvalidOperationException('Partenaire occupé');

      // Set partner
      transaction.update(_users.doc(userId), buildData(partnerId));
      transaction.update(_users.doc(partnerId), buildData(userId));
    });
  }

  /// Remove user partner
  /// Update [userId]'s partner AND [partnerId]'s partner
  Future<void> removePartner(String userId, String partnerId) async {
    debugPrint('[DatabaseService] remove user\'s partner');
    final data = {
      'partnerId': FieldValue.delete(),
    };

    // Batch update
    final batch = _db.batch();
    batch.update(_users.doc(userId), data);
    batch.update(_users.doc(partnerId), data);
    await batch.commit();
  }

  /// Add a new user's vote
  Future<void> setUserVote(String userId, String groupId, SwipeValue value) async {
    await _users.doc(userId).update({
      'votes.$groupId': value.name,
      'lastVotedAt': DateTime.now(),  // Using 'FieldValue.serverTimestamp()' is more accurate, but it doubles the db exchanges (automatically fetch the value set by server after the update), and this value is not used in the app.
    });
    debugPrint('[DatabaseService] set user\'s vote $groupId to $value');
  }

  /// Remove a user's vote
  Future<void> clearUserVote(String userId, String groupId) async {
    await _users.doc(userId).update({
      'votes.$groupId': FieldValue.delete(),
    });
    debugPrint('[DatabaseService] remove user\'s vote $groupId');
  }
}

class UserStore {   // TODO refactor to use a cleaner logic like in Mb App (stream only, with cache first & background update)
  UserStore(this.id);

  final String id;

  late final _dbRef = DatabaseService.instance._users.doc(id);

  EventStream<User>? stream;

  /// Return last cached user data.
  User? get cached => stream?.valueOrNull;

  /// Return last cached user data, and fetch last up-to-date version from database if not available.
  Future<User?> fetch() async {
    // Return latest cached value
    if (cached != null) return cached!;

    // If no cached value is available, get value from database
    debugPrint('[DatabaseService] get user $id');
    final user = (await _dbRef.get()).data();
    if (user == null) return null;    // User does not exists

    // Create a stream to stay up-to-date
    stream = EventStream.fromStream(_dbRef.snapshots().map((snapshot) => snapshot.data()!));
    return user;
  }
}
