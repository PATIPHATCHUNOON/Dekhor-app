// app.dart — กำหนด route ทุกหน้าของแอป

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/pin_screen.dart';
import 'features/home/screens/home_screen.dart';

class DekHorApp extends StatelessWidget {
  const DekHorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DekHor',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: _router(context),
    );
  }

  // Theme ของแอป
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Sarabun', // รองรับภาษาไทย
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }

  // Router — กำหนด path ทุกหน้า
  GoRouter _router(BuildContext context) {
    return GoRouter(
      initialLocation: '/splash',
      // redirect — ตรวจสอบ auth ก่อนเข้าหน้า
      redirect: (context, state) {
        final auth   = context.read<AuthProvider>();
        final isAuth = auth.isAuthenticated;
        final path   = state.matchedLocation;

        // หน้าที่ไม่ต้อง login
        final publicRoutes = ['/splash', '/login', '/register'];

        if (!isAuth && !publicRoutes.contains(path)) return '/login';
        if (isAuth  &&  publicRoutes.contains(path)) return '/home';
        return null; // ผ่านได้
      },
      routes: [
        GoRoute(path: '/splash',   builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/pin',      builder: (_, __) => const PinScreen()),
        GoRoute(path: '/home',     builder: (_, __) => const HomeScreen()),
      ],
    );
  }
}