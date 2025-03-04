import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static Future<bool?> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    return null;
  }

  static Future<bool?> saveMap(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, jsonEncode(value));
    return null;
  }

  static Future<String?> getString(String key,
      [String defaultValue = '']) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<Map<String, dynamic>> getMap(String key) async {
    try {
      return jsonDecode(await getString(key) ?? "{}");
    } catch (_) {
      return {};
    }
  }

  static Future<bool?> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
