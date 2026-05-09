// auth_provider.dart — จัดการ state ของ Auth ทั้งหมด
// ทุกหน้าที่ต้องรู้ว่า login อยู่หรือเปล่า ดูได้จากที่นี่

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

// สถานะของ Auth
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final _api     = ApiService();
  final _storage = StorageService();

  AuthStatus _status  = AuthStatus.initial;
  UserModel? _user;
  String?    _errorMessage;

  // getter — ให้ UI อ่านค่าได้ แต่แก้ตรงๆ ไม่ได้
  AuthStatus get status       => _status;
  UserModel? get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool get isAuthenticated    => _status == AuthStatus.authenticated;

  // เรียกตอนแอปเปิด — ตรวจว่ามี token เก็บอยู่ไหม
  Future<void> checkAuth() async {
    final token = await _storage.getToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      // ดึงข้อมูล user ด้วย token ที่มีอยู่
      final res = await _api.get(ApiConstants.me);
      _user   = UserModel.fromJson(res.data['data']);
      _status = AuthStatus.authenticated;
    } catch (_) {
      // Token ใช้ไม่ได้แล้ว
      await _storage.clearAll();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ===== REGISTER =====
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? university,
    String? dormName,
    String? roomNumber,
  }) async {
    _setLoading();
    try {
      final res = await _api.post(ApiConstants.register, body: {
        'username':    username,
        'email':       email,
        'password':    password,
        'full_name':   fullName,
        'university':  university,
        'dorm_name':   dormName,
        'room_number': roomNumber,
      });

      await _handleAuthResponse(res.data);
      return true;
    } on DioException catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  // ===== LOGIN =====
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final res = await _api.post(ApiConstants.login, body: {
        'email':    email,
        'password': password,
      });

      await _handleAuthResponse(res.data);
      return true;
    } on DioException catch (e) {
      _setError(_parseError(e));
      return false;
    }
  }

  // ===== LOGOUT =====
  Future<void> logout() async {
    await _storage.clearAll();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ===== PRIVATE HELPERS =====

  // บันทึก token และข้อมูล user หลัง login/register สำเร็จ
  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    final token = data['data']['token'];
    final user  = UserModel.fromJson(data['data']['user']);

    await _storage.saveToken(token);
    await _storage.saveUserId(user.id);
    await _storage.saveUsername(user.username);

    _user   = user;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  void _setLoading() {
    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status       = AuthStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }

  // แปลง Dio error → ข้อความภาษาไทย
  String _parseError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? 'เกิดข้อผิดพลาด';
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'ไม่สามารถเชื่อมต่อ server ได้ กรุณาตรวจสอบ internet';
    }
    return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
  }
}
