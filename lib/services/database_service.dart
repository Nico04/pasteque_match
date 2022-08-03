import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
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
    return userRef.id;
  }
}