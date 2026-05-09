class ScheduleModel {
  final String id;
  final String subject;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;
  final String? teacher;
  final String color;
  final String? semester;

  static const List<String> dayNames = ['อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์'];

  ScheduleModel({
    required this.id,
    required this.subject,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.room,
    this.teacher,
    this.semester,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      subject: json['subject'] ?? '',
      dayOfWeek: json['day_of_week'] ?? 0,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      color: json['color'] ?? '#7F77DD',
      room: json['room'],
      teacher: json['teacher'],
      semester: json['semester'],
    );
  }
}
