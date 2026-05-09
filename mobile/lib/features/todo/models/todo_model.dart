import 'package:flutter/material.dart';

class TodoModel {
  final String   id;
  final String   title;
  final String?  subject;
  final DateTime? dueDate;
  final bool     isDone;
  final String   priority;    // low / medium / high
  final DateTime? remindAt;
  final DateTime? completedAt;

  const TodoModel({
    required this.id,
    required this.title,
    required this.isDone,
    required this.priority,
    this.subject,
    this.dueDate,
    this.remindAt,
    this.completedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> j) => TodoModel(
    id:          j['id']?.toString() ?? j['_id']?.toString() ?? '',
    title:       j['title'] ?? '',
    subject:     j['subject'],
    isDone:      j['is_done'] ?? false,
    priority:    j['priority'] ?? 'medium',
    dueDate:     j['due_date'] != null ? DateTime.parse(j['due_date']) : null,
    remindAt:    j['remind_at'] != null ? DateTime.parse(j['remind_at']) : null,
    completedAt: j['completed_at'] != null ? DateTime.parse(j['completed_at']) : null,
  );

  // เหลืออีกกี่วัน
  int? get daysLeft {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  // สีตาม priority
  static const Map<String, Color> priorityColors = {
    'high':   Color(0xFFE24B4A),
    'medium': Color(0xFFBA7517),
    'low':    Color(0xFF1D9E75),
  };

  Color get priorityColor => priorityColors[priority] ?? const Color(0xFF888780);

  String get priorityLabel {
    switch (priority) {
      case 'high':   return 'ด่วนมาก';
      case 'medium': return 'ปานกลาง';
      default:       return 'ไม่ด่วน';
    }
  }
}