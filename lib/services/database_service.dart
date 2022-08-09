import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/services/storage_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/utils/exceptions/invalid_operation_exception.dart';
import 'package:pasteque_match/utils/exceptions/unauthorized_exception.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseService {
  static final instance = DatabaseService();

  final _db = FirebaseFirestore.instance;

  late final _names = _db.collection('names').withConverter<Name>(
    fromFirestore: (snapshot, _) => Name.fromJson(snapshot.data()!),
    toFirestore: (model, _) => model.toJson(),
  );
  late final _users = _db.collection('users').withConverter<User>(
    fromFirestore: (snapshot, _) => User.fromJson(snapshot.id, snapshot.data()!),
    toFirestore: (model, _) => model.toJson(),
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

  /// Return all the names.
  /// Use a 1 day cache, to avoid too many queries.
  Future<List<Name>> getNames() async {
    // Compute best source
    final lastDatabaseNamesReadAt = StorageService.readLastDatabaseNamesReadAt();
    final source = lastDatabaseNamesReadAt != null && lastDatabaseNamesReadAt.add(const Duration(days: 1)).isAfter(DateTime.now())
        ? Source.cache
        : Source.serverAndCache;

    // Fetch data
    debugPrint('[DatabaseService] get names from ${source.name}');
    final snapshot = await _names.get(GetOptions(source: source));

    // Update read date
    if (!snapshot.metadata.isFromCache) {
      await StorageService.saveLastDatabaseNamesReadAt(DateTime.now());
    }

    // Return data
    return snapshot.docs.map((ref) => ref.data()).toList();
  }

  /// Add a new user's vote
  Future<void> setUserVote(String userId, String nameId, SwipeValue value) async {
    await _users.doc(userId).update({
      'votes.$nameId': value.name,
    });
  }
}

class UserStore {
  UserStore(this.id);

  final String id;

  late final _dbRef = DatabaseService.instance._users.doc(id);

  ValueStream<User>? _stream;

  /// Return last cached user data.
  User? get cached => _stream?.value;

  /// Return last cached user data, and fetch last up-to-date version from database if not available.
  Future<User?> fetch() async {
    // Return latest cached value
    if (cached != null) return cached!;

    // If no cached value is available, get value from database
    debugPrint('[DatabaseService] get user $id');
    final user = (await _dbRef.get()).data();
    if (user == null) return null;    // User does not exists

    // Create a stream to stay up-to-date
    _stream = _dbRef.snapshots().map((snapshot) => snapshot.data()!).shareValue()..listen((user) => debugPrint('[DatabaseService] user ${user.name} value stream'));   // No need to use shareValueSeeded because snapshots() command already do it    // TODO remove listen part
    return user;
  }
}
