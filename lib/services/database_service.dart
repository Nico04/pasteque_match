import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/utils/exceptions/database_error.dart';
import 'package:pasteque_match/utils/exceptions/invalid_operation_exception.dart';

class DatabaseService {
  static final instance = DatabaseService();

  final _db = FirebaseFirestore.instance;

  late final _users = _db.collection('users').withConverter<User>(
    fromFirestore: (snapshot, _) => User.fromJson(snapshot.id, snapshot.data()!),
    toFirestore: (model, _) => model.toJson(),    // Used by 'add' command
  );

  late final _reports = _db.collection('reports');

  /// Add a new user.
  /// Return user id.
  Future<String> addUser(String username) async {
    await throwIfNoInternet();    // Firebase 'add' command need internet, and never stops if there is no connection.
    final userRef = await _users.add(User(id: '', name: username));   // User.id is ignored at serialisation
    debugPrint('[DatabaseService] user $username added');
    return userRef.id;
  }

  Future<User?> getUser(String id) async {
    debugPrint('[DatabaseService] get user $id');
    return (await _users.doc(id).get()).data();
  }

  /// Set user's FCM token
  Future<void> setUserFcmToken(String userId, String? token) async {
    await _users.doc(userId).update({
      'fcmToken': token,
    });
    debugPrint('[DatabaseService] User FCM token is set');
  }

  /// Set user partner
  /// Update [userId]'s partner AND [partnerId]'s partner
  Future<void> setPartner(String userId, String partnerId) async {
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
    debugPrint('[DatabaseService] New user partner is set');
  }

  final _deletePartnerIdData = {
    'partnerId': FieldValue.delete(),
  };

  /// Remove user partner
  /// Update [userId]'s partner AND [partnerId]'s partner
  Future<void> removePartner(String userId, String partnerId) async {
    final batch = _db.batch();
    batch.update(_users.doc(userId), _deletePartnerIdData);
    batch.update(_users.doc(partnerId), _deletePartnerIdData);
    await batch.commit();
    debugPrint('[DatabaseService] Partner $partnerId removed');
  }

  /// Add a new user's vote
  Future<void> setUserVote(String userId, String groupId, SwipeValue value) async {
    await _users.doc(userId).update({
      'votes.$groupId': UserVote(value, DateTime.now()).toJson(),   // Using 'FieldValue.serverTimestamp()' is more accurate, but it doubles the db exchanges (automatically fetch the value set by server after the update), and we don't need accuracy here.
    });
    debugPrint('[DatabaseService] Vote for $groupId changed to $value');
  }

  /// Remove a user's vote
  Future<void> clearUserVote(String userId, String groupId) async {
    await _users.doc(userId).update({
      'votes.$groupId': FieldValue.delete(),
    });
    debugPrint('[DatabaseService] Vote for $groupId removed');
  }

  /// Set name order indices for multiple [groupId]s for user [userId]
  Future<void> setUserNameOrderIndexes(String userId, NameOrderIndexes orders) async {
    if (orders.isEmpty) return;
    await _users.doc(userId).update({
      for (final MapEntry(key:groupId, value:order) in orders.entries)
        'orders.$groupId': order,
    });
    debugPrint('[DatabaseService] Name order indexes for [${orders.keys.join(', ')}] changed');
  }

  /// Report an error on a group
  Future<void> reportGroupError(String groupId, String comment) async {
    await _reports.doc(groupId).set({   // set() command create document if it does not exists (where update() doesn't).
      'comments': FieldValue.arrayUnion([comment]),
    }, SetOptions(merge: true));
    debugPrint('[DatabaseService] Group $groupId reported');
  }

  /// Delete user
  Future<void> deleteUser(String userId, String? partnerId) async {
    final batch = _db.batch();
    if (partnerId != null) batch.update(_users.doc(partnerId), _deletePartnerIdData);
    batch.delete(_users.doc(userId));
    await batch.commit();
    debugPrint('[DatabaseService] User $userId deleted');
  }
}

class UserStore with Disposable {
  UserStore(this.id);

  final String id;

  late final _dbRef = DatabaseService.instance._users.doc(id);

  /// User data stream
  ///
  /// The initial state can come from the server directly, or from a local cache.
  /// If there is state available in a local cache, it will be initially populated with the cached data,
  /// then updated with the server's data when the client has caught up with the server's state.
  ///
  /// If users does not exists, a [DatabaseError] is emitted.
  late final stream = EventStream.fromStream(_dbRef.snapshots().map((snapshot) {
    if (!snapshot.exists) throw DatabaseError('User $id not found');
    return snapshot.data()!;
  }));

  @override
  void dispose() {
    stream.close();
    super.dispose();
  }
}
