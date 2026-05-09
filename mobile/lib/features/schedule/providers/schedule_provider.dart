import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/schedule_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';

enum ScheduleStatus { initial, loading, loaded, error }

class ScheduleProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  ScheduleStatus status = ScheduleStatus.initial;
  String? error;
  Map<int, List<ScheduleModel>> byDay = {};

  Future<void> fetchSchedules() async {
    status = ScheduleStatus.loading;
    error = null;
    notifyListeners();

    try {
      final res = await _api.get(ApiConstants.schedules);
      final List data = res.data['data'] ?? [];
      final schedules = data.map((e) => ScheduleModel.fromJson(e)).toList();

      byDay = {};
      for (var s in schedules) {
        byDay[s.dayOfWeek] ??= [];
        byDay[s.dayOfWeek]!.add(s);
      }

      status = ScheduleStatus.loaded;
    } on DioException catch (e) {
      error = e.response?.data['message'] ?? 'เกิดข้อผิดพลาด';
      status = ScheduleStatus.error;
    } catch (e) {
      error = e.toString();
      status = ScheduleStatus.error;
    }
    notifyListeners();
  }

  Future<bool> createSchedule(Map<String, dynamic> data) async {
    try {
      await _api.post(ApiConstants.schedules, body: data);
      await fetchSchedules();
      return true;
    } catch (e) {
      if (e is DioException) {
        error = e.response?.data['message'] ?? 'เกิดข้อผิดพลาด';
      } else {
        error = e.toString();
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSchedule(String id) async {
    try {
      await _api.delete(ApiConstants.scheduleById(id));
      await fetchSchedules();
      return true;
    } catch (e) {
      return false;
    }
  }
}
