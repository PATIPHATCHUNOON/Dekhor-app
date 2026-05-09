// api_constants.dart — URL และ Endpoint ทั้งหมดอยู่ที่นี่ที่เดียว
// ถ้าย้าย server แค่แก้ไฟล์นี้ไฟล์เดียว

class ApiConstants {
  // เปลี่ยนเป็น IP จริงของเครื่องที่รัน Backend
  // ห้ามใช้ localhost บน emulator — ใช้ 10.0.2.2 แทน (Android)
  // iPhone simulator ใช้ localhost ได้ปกติ
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  // Auth
  static const String register = '$_baseUrl/auth/register';
  static const String login    = '$_baseUrl/auth/login';
  static const String me       = '$_baseUrl/auth/me';

  // Users
  static const String updateProfile = '$_baseUrl/users/profile';
  static const String setPin        = '$_baseUrl/auth/pin/setup';
  static const String verifyPin     = '$_baseUrl/auth/pin/verify';

  // Schedules
  static const String schedules     = '$_baseUrl/schedules';
  static String scheduleById(String id) => '$_baseUrl/schedules/$id';
  static String shareSchedule(String uid, String sem) =>
      '$_baseUrl/schedules/share/$uid/$sem';

  // Exams
  static const String exams         = '$_baseUrl/exams';
  static const String upcomingExams = '$_baseUrl/exams/upcoming';
  static String examById(String id) => '$_baseUrl/exams/$id';

  // Todos
  static const String todos         = '$_baseUrl/todos';
  static const String dueSoon       = '$_baseUrl/todos/due-soon';
  static String todoById(String id) => '$_baseUrl/todos/$id';
  static String toggleTodo(String id) => '$_baseUrl/todos/$id/toggle';

  // Finance
  static const String transactions  = '$_baseUrl/finance/transactions';
  static const String splits        = '$_baseUrl/finance/splits';
  static const String calcElectric  = '$_baseUrl/finance/calc/electric';
  static String summary(int year, int month) =>
      '$_baseUrl/finance/summary/$year/$month';
  static String splitById(String id) => '$_baseUrl/finance/splits/$id';
  static String markPaid(String memberId) =>
      '$_baseUrl/finance/splits/members/$memberId/pay';
}   