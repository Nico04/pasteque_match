import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/services/storage_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseService {
  static final _db = FirebaseFirestore.instance;

  static final _names = _db.collection('names').withConverter<NameData>(
    fromFirestore: (snapshot, _) => NameData.fromJson(snapshot.data()!),
    toFirestore: (model, _) => model.toJson(),
  );
  static final _users = _db.collection('users').withConverter<User>(
    fromFirestore: (snapshot, _) => User.fromJson(snapshot.id, snapshot.data()!),
    toFirestore: (model, _) => model.toJson(),
  );

  static DocumentReference<User> get _userRef => _users.doc(StorageService.readUserId());
  static ValueStream<User>? _userStream;
  static Future<User?> getUser() async {
    // Return latest cached value
    if (_userStream != null) return _userStream!.value!;

    // If no cached value is available, get value from database
    debugPrint('[DatabaseService] get user');
    final user = (await _userRef.get()).data();
    if (user == null) return null;

    // Create a stream to stay up-to-date
    _userStream = _userRef.snapshots().map((snapshot) => snapshot.data()!).shareValueSeeded(user);
    return user;
  }

  /// Add a new user.
  /// Return user id.
  static Future<String> addUser(String username) async {
    await throwIfNoInternet();    // Firebase 'add' command need internet, and never stops if there is no connection.
    final userRef = await _users.add(User(id: '', name: username));   // User.id is ignored at serialisation
    debugPrint('[DatabaseService] user $username added');
    return userRef.id;
  }

  /// Return all the names.
  /// Use a 1 day cache, to avoid too many queries.
  static Future<List<Name>> getNames() async {
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
    return snapshot.docs.map((ref) => Name.fromBase(
      id: ref.id,
      nameBase: ref.data(),
    )).toList();
  }

  /// Add a new user's vote
  static Future<void> addUserVote(String nameId, SwipeValue value) async {
    await _userRef.update({
      'votes.$nameId': value.name,
    });
  }
}