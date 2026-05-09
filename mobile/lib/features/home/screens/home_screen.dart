// home_screen.dart — หน้าหลัก + Bottom Navigation Bar

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../schedule/screens/schedule_screen.dart';
import '../../todo/screens/todo_screen.dart';
import '../../finance/screens/finance_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // หน้าทั้งหมดใน Bottom Nav
  final List<Widget> _screens = const [
    _DashboardTab(),   // หน้าแรก — สรุปทุกอย่าง
    ScheduleScreen(),  // ตารางเรียน
    TodoScreen(),      // To-do
    FinanceScreen(),   // รายรับ-รายจ่าย
    ProfileScreen(),   // โปรไฟล์
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // IndexedStack — เก็บ state ของทุกหน้าไว้
        // ไม่ reload เมื่อกลับมา ต่างจาก PageView
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      BottomNavigationBarItem(
        icon: SvgPicture.asset('assets/icons/home.svg', colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn), width: 24),
        activeIcon: SvgPicture.asset('assets/icons/home.svg', colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn), width: 24),
        label: 'หน้าแรก',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'ตาราง'),
      const BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), activeIcon: Icon(Icons.check_circle), label: 'งาน'),
      const BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'เงิน'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline),      activeIcon: Icon(Icons.person),      label: 'ฉัน'),
    ];

    return BottomNavigationBar(
      currentIndex:     _currentIndex,
      onTap:            (i) => setState(() => _currentIndex = i),
      type:             BottomNavigationBarType.fixed,
      selectedItemColor:   AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedFontSize:    11,
      unselectedFontSize:  11,
      backgroundColor: AppColors.surface,
      elevation: 12,
      items: items,
    );
  }
}

// ===== Dashboard Tab — หน้าแรกสรุปทุกอย่าง =====
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'สวัสดี, ${user?.fullName?.split(' ').first ?? user?.username ?? 'น้อง'} 👋',
                              style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/home.svg',
                                  colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                                  width: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  user?.dormName ?? 'DekHor App',
                                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Avatar
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          child: Text(
                            (user?.username ?? 'D').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Quick stats row
                    Row(
                      children: [
                        _StatChip(icon: '📅', label: 'วันนี้มีเรียน', value: '3 วิชา'),
                        const SizedBox(width: 10),
                        _StatChip(icon: '✅', label: 'งานค้าง', value: '2 ชิ้น'),
                        const SizedBox(width: 10),
                        _StatChip(icon: '💰', label: 'เงินเหลือ', value: '฿2,340'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('เข้าถึงด่วน',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: const [
                        _QuickAction(imagePath: 'assets/images/3d_icons/schedule.png', label: 'ตาราง'),
                        _QuickAction(imagePath: 'assets/images/3d_icons/task.png', label: 'งาน'),
                        _QuickAction(imagePath: 'assets/images/3d_icons/expense.png', label: 'รายจ่าย'),
                        _QuickAction(imagePath: 'assets/images/3d_icons/electric.png', label: 'ค่าไฟ'),
                        _QuickAction(imagePath: 'assets/images/3d_icons/restaurant.png', label: 'ร้านอาหาร'),
                        _QuickAction(imagePath: 'assets/images/3d_icons/market.png', label: 'ตลาด'),
                        _QuickAction(imagePath: 'assets/images/3d_icons/chat.png', label: 'แชท'),
                        _QuickAction(imagePath: 'assets/images/3d_icons/sos.png', label: 'ช่วยชีวิต'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // งานใกล้ due
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('งานที่ต้องส่งเร็วๆ นี้ 🔥',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    // placeholder — จะเชื่อม API จริงในขั้นถัดไป
                    _TodoCard(title: 'ส่งรายงาน ER Diagram', subject: 'Database Systems', daysLeft: 2, priority: 'high'),
                    _TodoCard(title: 'Lab Web Dev ครั้งที่ 5', subject: 'Web Development', daysLeft: 4, priority: 'medium'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Widgets เล็กๆ =====

class _StatChip extends StatelessWidget {
  final String icon, label, value;
  const _StatChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ],
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final String imagePath, label;
  const _QuickAction({required this.imagePath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The 3D Image covering the whole container, perfectly centered
            Positioned.fill(
              child: Transform.scale(
                scale: 1.45, // ซูมเพิ่มขึ้นเพื่อให้ขอบของทุกรูปถูกตัดออกหมด
                child: Image.asset(
                  imagePath, 
                  fit: BoxFit.cover, 
                  // ไม่ใช้ alignment เพื่อให้รูปอยู่ตรงกลางเป๊ะๆ ป้องกันขอบโหว่
                ),
              ),
            ),
            // The Text
            Positioned(
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75), // เพิ่มความทึบของพื้นหลังตัวหนังสือให้อ่านง่ายขึ้น
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  final String title, subject, priority;
  final int daysLeft;
  const _TodoCard({required this.title, required this.subject, required this.daysLeft, required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = priority == 'high' ? AppColors.error : AppColors.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(subject, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              daysLeft == 0 ? 'วันนี้!' : 'อีก $daysLeft วัน',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}