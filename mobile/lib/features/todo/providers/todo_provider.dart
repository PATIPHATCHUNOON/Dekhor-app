import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/todo_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';

enum TodoStatus { initial, loading, loaded, error }

class TodoProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  TodoStatus status = TodoStatus.initial;
  String? error;
  List<TodoModel> _allTodos = [];
  String filter = 'all'; // 'all', 'pending', 'done'

  List<TodoModel> get todos {
    if (filter == 'pending') {
      return _allTodos.where((t) => !t.isDone).toList();
    } else if (filter == 'done') {
      return _allTodos.where((t) => t.isDone).toList();
    }
    return _allTodos;
  }

  int get pendingCount => _allTodos.where((t) => !t.isDone).length;

  void setFilter(String f) {
    filter = f;
    notifyListeners();
  }

  Future<void> fetchTodos() async {
    status = TodoStatus.loading;
    error = null;
    notifyListeners();

    try {
      final res = await _api.get(ApiConstants.todos);
      final List data = res.data['data'] ?? [];
      _allTodos = data.map((e) => TodoModel.fromJson(e)).toList();
      status = TodoStatus.loaded;
    } on DioException catch (e) {
      error = e.response?.data['message'] ?? 'เกิดข้อผิดพลาด';
      status = TodoStatus.error;
    } catch (e) {
      error = e.toString();
      status = TodoStatus.error;
    }
    notifyListeners();
  }

  Future<bool> createTodo(Map<String, dynamic> data) async {
    try {
      await _api.post(ApiConstants.todos, body: data);
      await fetchTodos();
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

  Future<void> toggleDone(String id) async {
    try {
      await _api.patch(ApiConstants.toggleTodo(id));
      await fetchTodos();
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _api.delete(ApiConstants.todoById(id));
      await fetchTodos();
    } catch (e) {
      // Handle error if needed
    }
  }
}
