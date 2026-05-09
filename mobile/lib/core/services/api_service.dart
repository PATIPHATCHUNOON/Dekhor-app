// api_service.dart — HTTP client กลาง ใช้ Dio
// ทุก feature เรียกผ่านที่นี่ ไม่ต้องเขียน http ซ้ำๆ

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _setupDio();
  }

  late final Dio _dio;
  final _storage = StorageService();

  void _setupDio() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    // Interceptor — แนบ token อัตโนมัติทุก request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            // ใส่ Authorization header อัตโนมัติ
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Token หมดอายุ — ลบ token แล้วให้แอป redirect ไป login
          if (error.response?.statusCode == 401) {
            _storage.clearAll();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ===== GET =====
  Future<Response> get(String url, {Map<String, dynamic>? params}) async {
    return await _dio.get(url, queryParameters: params);
  }

  // ===== POST =====
  Future<Response> post(String url, {Map<String, dynamic>? body}) async {
    return await _dio.post(url, data: body);
  }

  // ===== PUT =====
  Future<Response> put(String url, {Map<String, dynamic>? body}) async {
    return await _dio.put(url, data: body);
  }

  // ===== PATCH =====
  Future<Response> patch(String url, {Map<String, dynamic>? body}) async {
    return await _dio.patch(url, data: body);
  }

  // ===== DELETE =====
  Future<Response> delete(String url) async {
    return await _dio.delete(url);
  }
}