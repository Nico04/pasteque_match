import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/services/storage_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
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

  final user = UserStore();
  final partner = UserStore();

  /// Add a new user.
  /// Return user id.
  Future<String> addUser(String username) async {
    await throwIfNoInternet();    // Firebase 'add' command need internet, and never stops if there is no connection.
    final userRef = await _users.add(User(id: '', name: username));   // User.id is ignored at serialisation
    debugPrint('[DatabaseService] user $username added');
    return userRef.id;
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
  Future<void> setUserVote(String nameId, SwipeValue value) async {
    if (!user.isInitiated) throw const UnauthorizedException();
    await user._dbRef!.update({
      'votes.$nameId': value.name,
    });
  }
}

class UserStore {
  UserStore([String? id]) {
    if (id != null) this.id = id;
  }

  bool get isInitiated => _id != null;

  String? _id;
  String? get id => _id;
  set id(String? value) {
    if (value == id) return;
    if (value == null) {
      _id = null;
      _dbRef = null;
      _stream = null;
    } else {
      _id = value;
      _dbRef = DatabaseService.instance._users.doc(id);
      debugPrint('[DatabaseService] UserStore initiated with id $id');
    }
  }

  DocumentReference<User>? _dbRef;
  ValueStream<User>? _stream;

  /// Return last cached user data.
  User? get cached => _stream?.value;

  /// Return last cached user data, and fetch last up-to-date version from database if not available.
  Future<User> fetch() async {
    assert(isInitiated);

    // Return latest cached value
    if (cached != null) return cached!;

    // If no cached value is available, get value from database
    debugPrint('[DatabaseService] get user $id');
    final user = (await _dbRef!.get()).data();
    if (user == null) throw const UnauthorizedException();    // User does not exists

    // Create a stream to stay up-to-date
    _stream = _dbRef!.snapshots().map((snapshot) => snapshot.data()!).shareValue();    // No need to use shareValueSeeded because snapshots() command already do it
    return user;
  }
}
