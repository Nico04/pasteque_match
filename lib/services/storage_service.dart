import 'dart:convert';

import 'package:pasteque_match/models/filters.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  //#region Global
  static late SharedPreferences _storage;

  static Future<void> init() async => _storage = await SharedPreferences.getInstance();

  static Future<void> deleteAll() => _storage.clear();
  //#endregion

  //#region UserId
  static const _userIdKey = 'userId';
  static Future<void> saveUserId(String value) => _storage.setString(_userIdKey, value);
  static String? readUserId() => _storage.getString(_userIdKey);
  //#endregion

  //#region Filters
  static const _filtersKey = 'filters';
  static Future<void> saveFilters(NameGroupFilters? value) => _storage.setString(_filtersKey, value == null ? '' : json.encode(value.toJson()));
  static NameGroupFilters? readFilters() {
    try {
      final rawValue = _storage.getString(_filtersKey);
      if (rawValue == null || rawValue.isEmpty) return null;
      return NameGroupFilters.fromJson(json.decode(rawValue));
    } catch(e, s) {
      reportError(e, s);
      return null;
    }
  }
  //#endregion
}
