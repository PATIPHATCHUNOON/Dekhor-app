// splash_screen.dart — หน้าแรกที่เห็นตอนเปิดแอป
// ตรวจ token แล้ว redirect อัตโนมัติ

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // รอให้ animation โหลด
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.checkAuth();

    if (!mounted) return;
    if (auth.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/home.svg',
                  colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                  width: 55,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'DekHor',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'แอปสำหรับเด็กหอ',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}