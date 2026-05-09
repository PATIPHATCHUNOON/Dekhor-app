import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';
import 'add_schedule_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // วันที่เลือกอยู่ตอนนี้ — default วันนี้
  int _selectedDay = DateTime.now().weekday % 7;

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลครั้งแรก
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().fetchSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ตารางเรียน'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Day selector
          _buildDaySelector(),

          // Content
          Expanded(
            child: _buildBody(provider),
          ),
        ],
      ),
    );
  }

  // ===== Day Selector Bar =====
  Widget _buildDaySelector() {
    const days = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: List.generate(7, (i) {
          final isSelected = i == _selectedDay;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDay = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  days[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ===== Body =====
  Widget _buildBody(ScheduleProvider provider) {
    if (provider.status == ScheduleStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (provider.status == ScheduleStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(provider.error ?? 'โหลดไม่สำเร็จ',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: provider.fetchSchedules,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    // รายวิชาในวันที่เลือก
    final daySchedules = provider.byDay[_selectedDay] ?? [];

    if (daySchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'วัน${ScheduleModel.dayNames[_selectedDay]}ไม่มีเรียน',
              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มวิชา'),
              onPressed: () => _showAddSheet(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: daySchedules.length,
      itemBuilder: (_, i) => _ScheduleCard(
        schedule: daySchedules[i],
        onDelete: (id) async {
          final ok = await context.read<ScheduleProvider>().deleteSchedule(id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ok ? 'ลบแล้ว' : 'ลบไม่สำเร็จ'),
            backgroundColor: ok ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        },
      ),
    );
  }

  // ===== Bottom Sheet เพิ่มวิชา =====
  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddScheduleSheet(),
    );
  }
}

// ===== Schedule Card =====
class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final void Function(String) onDelete;

  const _ScheduleCard({required this.schedule, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // แปลง hex string → Color
    final color = Color(
      int.parse(schedule.color.replaceFirst('#', '0xFF')),
    );

    return Dismissible(
      // swipe ซ้ายเพื่อลบ
      key: Key(schedule.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(schedule.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // สีข้างซ้าย
            Container(
              width: 6,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // เวลา
            Column(
              children: [
                Text(schedule.startTime,
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    )),
                Container(width: 1, height: 16, color: AppColors.border),
                Text(schedule.endTime,
                    style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary,
                    )),
              ],
            ),
            const SizedBox(width: 16),
            // รายละเอียด
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schedule.subject,
                        style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        )),
                    const SizedBox(height: 4),
                    if (schedule.room != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(schedule.room!,
                              style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary,
                              )),
                        ],
                      ),
                    if (schedule.teacher != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(schedule.teacher!,
                              style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary,
                              )),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Tag สี
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}