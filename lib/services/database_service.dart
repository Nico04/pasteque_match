import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/services/storage_service.dart';
import 'package:pasteque_match/utils/_utils.dart';

class DatabaseService {
  static final _db = FirebaseFirestore.instance;

  static final _names = _db.collection('names').withConverter<Name>(
    fromFirestore: (snapshot, _) => Name.fromJson(snapshot.data()!),
    toFirestore: (model, _) => model.toJson(),
  );
  static final _users = _db.collection('users').withConverter<User>(
    fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
    toFirestore: (model, _) => model.toJson(),
  );

  /// Add a new user.
  /// Return user id.
  static Future<String> addUser(String username) async {
    await throwIfNoInternet();    // Firebase 'add' command need internet, and never stops if there is no connection.
    final userRef = await _users.add(User(name: username));
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
    return snapshot.docs.map((ref) => ref.data()).toList();
  }
}