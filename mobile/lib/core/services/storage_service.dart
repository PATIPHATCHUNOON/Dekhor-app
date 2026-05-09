// storage_service.dart — เก็บและดึง token / ข้อมูล local

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Singleton — มีแค่ instance เดียวตลอดแอป
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // secure storage สำหรับ token (เข้ารหัส)
  final _secure = const FlutterSecureStorage();

  // ===== TOKEN =====
  Future<void> saveToken(String token) async {
    await _secure.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secure.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _secure.delete(key: 'auth_token');
  }

  // ===== USER DATA (ไม่ sensitive เก็บใน SharedPreferences) =====
  Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // ===== PIN =====
  Future<void> savePinEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pin_enabled', enabled);
  }

  Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('pin_enabled') ?? false;
  }

  // ===== CLEAR ALL (Logout) =====
  Future<void> clearAll() async {
    await _secure.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}