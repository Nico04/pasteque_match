import 'package:pasteque_match/utils/_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  //#region Global
  static late SharedPreferences _storage;

  static Future<void> init() async => _storage = await SharedPreferences.getInstance();

  static Future<void> deleteAll() => _storage.clear();
  //#endregion

  //#region Data
  static const _userIdKey = 'userId';
  static Future<void> saveUserId(String value) => _storage.setString(_userIdKey, value);
  static String? readUserId() => _storage.getString(_userIdKey);

  static const _lastDatabaseNamesReadAtKey = 'lastDatabaseNamesReadAt';
  static Future<void> saveLastDatabaseNamesReadAt(DateTime value) => _storage.setString(_lastDatabaseNamesReadAtKey, const NullableDateTimeConverter().toJson(value)!);
  static DateTime? readLastDatabaseNamesReadAt() => const NullableDateTimeConverter().fromJson(_storage.getString(_lastDatabaseNamesReadAtKey));
  //#endregion
}
