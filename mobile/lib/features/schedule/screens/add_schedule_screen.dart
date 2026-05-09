// add_schedule_screen.dart — Bottom Sheet เพิ่ม/แก้ไขวิชา

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/schedule_provider.dart';

class AddScheduleSheet extends StatefulWidget {
  const AddScheduleSheet({super.key});

  @override
  State<AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<AddScheduleSheet> {
  final _subjectCtrl = TextEditingController();
  final _roomCtrl    = TextEditingController();
  final _teacherCtrl = TextEditingController();
  final _semCtrl     = TextEditingController();

  int    _selectedDay  = 1;         // จันทร์
  String _startTime    = '08:00';
  String _endTime      = '10:00';
  String _selectedColor = '#7F77DD';
  bool   _isLoading    = false;

  final _colors = [
    '#7F77DD','#1D9E75','#D85A30',
    '#378ADD','#BA7517','#E24B4A',
    '#639922','#888780',
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _roomCtrl.dispose();
    _teacherCtrl.dispose();
    _semCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final parts = (isStart ? _startTime : _endTime).split(':');
    final initial = TimeOfDay(
      hour:   int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (isStart) _startTime = formatted;
      else         _endTime   = formatted;
    });
  }

  Future<void> _save() async {
    if (_subjectCtrl.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('ข้อผิดพลาด'),
          content: const Text('กรุณากรอกชื่อวิชา'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final ok = await context.read<ScheduleProvider>().createSchedule({
      'subject':     _subjectCtrl.text.trim(),
      'day_of_week': _selectedDay,
      'start_time':  _startTime,
      'end_time':    _endTime,
      'room':        _roomCtrl.text.trim().isEmpty ? null : _roomCtrl.text.trim(),
      'teacher':     _teacherCtrl.text.trim().isEmpty ? null : _teacherCtrl.text.trim(),
      'color':       _selectedColor,
      'semester':    _semCtrl.text.trim().isEmpty ? null : _semCtrl.text.trim(),
    });

    if (!mounted) return;
    
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('เพิ่มวิชาสำเร็จ ✓'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('เพิ่มไม่สำเร็จ'),
          content: Text(context.read<ScheduleProvider>().error ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const days = ['อา','จ','อ','พ','พฤ','ศ','ส'];

    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('เพิ่มวิชาเรียน',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // ชื่อวิชา
            CustomTextField(
              label: 'ชื่อวิชา *',
              hint: 'เช่น Database Systems',
              controller: _subjectCtrl,
              prefixIcon: Icons.book_outlined,
            ),
            const SizedBox(height: 14),

            // เลือกวัน
            const Text('วัน *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(7, (i) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDay = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedDay == i
                          ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(days[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _selectedDay == i
                              ? Colors.white : AppColors.textSecondary,
                        )),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 14),

            // เวลา
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('เวลาเริ่ม *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _pickTime(true),
                        child: _TimeBox(time: _startTime),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('เวลาสิ้นสุด *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _pickTime(false),
                        child: _TimeBox(time: _endTime),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ห้องเรียน
            CustomTextField(
              label: 'ห้องเรียน',
              hint: 'เช่น IT-301',
              controller: _roomCtrl,
              prefixIcon: Icons.meeting_room_outlined,
            ),
            const SizedBox(height: 14),

            // อาจารย์
            CustomTextField(
              label: 'อาจารย์',
              hint: 'ชื่ออาจารย์',
              controller: _teacherCtrl,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 14),

            // ภาคเรียน
            CustomTextField(
              label: 'ภาคเรียน',
              hint: 'เช่น 1/2568',
              controller: _semCtrl,
              prefixIcon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 14),

            // เลือกสี
            const Text('สีวิชา',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: _colors.map((hex) {
                final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 32, height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.textPrimary, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            CustomButton(
              label: 'เพิ่มวิชา',
              onPressed: _save,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String time;
  const _TimeBox({required this.time});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(time,
            style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
            )),
      ],
    ),
  );
}