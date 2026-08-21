import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  Future<void> saveData(String key, dynamic value) async {
    final String jsonString = jsonEncode(value);
    await _prefs.setString(key, jsonString);
  }

  dynamic getData(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  Future<void> clearData(String key) async {
    await _prefs.remove(key);
  }
}
