import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _uniCtrl      = TextEditingController();
  final _dormCtrl     = TextEditingController();
  final _roomCtrl     = TextEditingController();

  // stepper — แบ่งฟอร์มเป็น 2 ขั้น ไม่ให้ดูยาวเกินไป
  int _step = 0;

  @override
  void dispose() {
    for (final c in [
      _usernameCtrl, _emailCtrl, _passCtrl, _confirmCtrl,
      _nameCtrl, _uniCtrl, _dormCtrl, _roomCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok   = await auth.register(
      username:    _usernameCtrl.text.trim(),
      email:       _emailCtrl.text.trim(),
      password:    _passCtrl.text,
      fullName:    _nameCtrl.text.trim(),
      university:  _uniCtrl.text.trim(),
      dormName:    _dormCtrl.text.trim(),
      roomNumber:  _roomCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      // หลัง register — ไปตั้ง PIN
      context.go('/pin');
    } else {
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => _step == 0 ? context.go('/login') : setState(() => _step = 0),
        ),
        title: Text(_step == 0 ? 'สร้างบัญชีใหม่' : 'ข้อมูลหอพัก'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Progress indicator
                Row(
                  children: List.generate(2, (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i == 0 ? 4 : 0, left: i == 1 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: i <= _step ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 24),

                if (_step == 0) ..._buildStep1(),
                if (_step == 1) ..._buildStep2(),

                const SizedBox(height: 28),

                // ปุ่มถัดไป / สมัคร
                CustomButton(
                  label:     _step == 0 ? 'ถัดไป' : 'สมัครสมาชิก',
                  isLoading: auth.status == AuthStatus.loading,
                  onPressed: _step == 0
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _step = 1);
                          }
                        }
                      : _register,
                ),

                const SizedBox(height: 16),

                if (_step == 0)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('มีบัญชีแล้ว? ',
                            style: TextStyle(color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text('เข้าสู่ระบบ',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            )),
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

  // Step 1 — ข้อมูลบัญชี
  List<Widget> _buildStep1() => [
    const Text('ข้อมูลบัญชี',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    const SizedBox(height: 4),
    const Text('กรอกข้อมูลสำหรับเข้าสู่ระบบ',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    const SizedBox(height: 24),
    CustomTextField(
      label: 'ชื่อผู้ใช้ (username)',
      hint: 'เช่น somchai_123',
      controller: _usernameCtrl,
      prefixIcon: Icons.person_outline,
      validator: (v) {
        if (v == null || v.isEmpty) return 'กรุณากรอก username';
        if (v.length < 3) return 'username ต้องมีอย่างน้อย 3 ตัว';
        return null;
      },
    ),
    const SizedBox(height: 14),
    CustomTextField(
      label: 'ชื่อ-นามสกุล',
      hint: 'เช่น สมชาย ใจดี',
      controller: _nameCtrl,
      prefixIcon: Icons.badge_outlined,
    ),
    const SizedBox(height: 14),
    CustomTextField(
      label: 'อีเมล',
      hint: 'example@email.com',
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      validator: (v) {
        if (v == null || v.isEmpty) return 'กรุณากรอกอีเมล';
        if (!v.contains('@')) return 'อีเมลไม่ถูกต้อง';
        return null;
      },
    ),
    const SizedBox(height: 14),
    CustomTextField(
      label: 'รหัสผ่าน',
      hint: 'อย่างน้อย 8 ตัวอักษร',
      controller: _passCtrl,
      isPassword: true,
      prefixIcon: Icons.lock_outline,
      validator: (v) {
        if (v == null || v.isEmpty) return 'กรุณากรอกรหัสผ่าน';
        if (v.length < 8) return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัว';
        return null;
      },
    ),
    const SizedBox(height: 14),
    CustomTextField(
      label: 'ยืนยันรหัสผ่าน',
      hint: 'กรอกรหัสผ่านอีกครั้ง',
      controller: _confirmCtrl,
      isPassword: true,
      prefixIcon: Icons.lock_outline,
      validator: (v) {
        if (v != _passCtrl.text) return 'รหัสผ่านไม่ตรงกัน';
        return null;
      },
    ),
  ];

  // Step 2 — ข้อมูลหอพัก
  List<Widget> _buildStep2() => [
    const Text('ข้อมูลหอพัก',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    const SizedBox(height: 4),
    const Text('ใส่ข้อมูลนี้เพื่อให้แอปช่วยได้ตรงขึ้น (ไม่บังคับ)',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    const SizedBox(height: 24),
    CustomTextField(
      label: 'มหาวิทยาลัย',
      hint: 'เช่น มหาวิทยาลัยตัวอย่าง',
      controller: _uniCtrl,
      prefixIcon: Icons.school_outlined,
    ),
    const SizedBox(height: 14),
    CustomTextField(
      label: 'ชื่อหอพัก',
      hint: 'เช่น หอพักอินทนิล',
      controller: _dormCtrl,
      prefixSvgPath: 'assets/icons/home.svg',
    ),
    const SizedBox(height: 14),
    CustomTextField(
      label: 'หมายเลขห้อง',
      hint: 'เช่น 302',
      controller: _roomCtrl,
      keyboardType: TextInputType.number,
      prefixIcon: Icons.door_front_door_outlined,
    ),
  ];
}