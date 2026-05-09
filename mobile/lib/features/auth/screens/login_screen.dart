import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();

  @override
  void dispose() {
    // ล้าง controller เมื่อหน้าถูกทำลาย — ป้องกัน memory leak
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // ตรวจ form validation ก่อน
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (ok) {
      context.go('/home');
    } else {
      // แสดง error message จาก API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'เกิดข้อผิดพลาด'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white, // Cleaner white background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Logo + Title
                Center(
                  child: Column(
                    children: [
                      // Placeholder for custom logo in the image
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9D76C1), Color(0xFFF6A6FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9D76C1).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Center(
                          child: SvgPicture.asset('assets/icons/home.svg', colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), width: 50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // DekHor text matching the logo text in the image
                      const Text(
                        'DekHor',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7149C6), // PrimaryDark
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'ยินดีต้อนรับกลับ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C5470), // TextPrimary
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'เข้าสู่ระบบเพื่อใช้งาน DekHor',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFBFA2DB), // TextSecondary
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Email
                CustomTextField(
                  label:        'อีเมล',
                  hint:         'กรอกอีเมลของคุณ',
                  controller:   _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon:   Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'กรุณากรอกอีเมล';
                    if (!v.contains('@'))       return 'อีเมลไม่ถูกต้อง';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password
                CustomTextField(
                  label:      'รหัสผ่าน',
                  hint:       'กรอกรหัสผ่าน',
                  controller: _passCtrl,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                    if (v.length < 8)           return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัว';
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Implement forgot password
                    },
                    child: const Text(
                      'Forgot Password',
                      style: TextStyle(
                        color: Color(0xFF9D76C1), // Primary
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ปุ่ม Login
                CustomButton(
                  label:     'เข้าสู่ระบบ',
                  onPressed: _login,
                  isLoading: auth.status == AuthStatus.loading,
                ),

                const SizedBox(height: 24),

                // ลิงก์ไป Register
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ยังไม่มีบัญชี? ',
                        style: TextStyle(color: Color(0xFF5C5470)), // TextPrimary
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: const Text(
                          'สมัครสมาชิก',
                          style: TextStyle(
                            color: Color(0xFF7149C6), // PrimaryDark
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}