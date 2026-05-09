// pin_screen.dart — ตั้ง PIN 6 หลัก / ยืนยัน PIN ก่อนเข้าแอป

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/api_constants.dart';

// mode ของหน้า PIN
enum PinMode { setup, verify }

class PinScreen extends StatefulWidget {
  final PinMode mode;
  const PinScreen({super.key, this.mode = PinMode.setup});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _api     = ApiService();
  final _storage = StorageService();

  String _pin        = '';
  String _confirmPin = '';
  bool   _isConfirm  = false; // ขั้นตอนยืนยัน PIN ซ้ำ
  bool   _isLoading  = false;
  String? _error;

  // กดปุ่มตัวเลข
  void _onKeyTap(String key) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin  += key;
      _error = null;
    });

    // เมื่อกรอกครบ 6 หลัก
    if (_pin.length == 6) {
      Future.delayed(const Duration(milliseconds: 200), _onPinComplete);
    }
  }

  // ลบตัวสุดท้าย
  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _onPinComplete() async {
    if (widget.mode == PinMode.setup) {
      await _handleSetup();
    } else {
      await _handleVerify();
    }
  }

  // ตั้ง PIN ใหม่
  Future<void> _handleSetup() async {
    if (!_isConfirm) {
      // ขั้นแรก — จำ PIN ไว้ แล้วให้กรอกอีกรอบ
      setState(() {
        _confirmPin = _pin;
        _pin        = '';
        _isConfirm  = true;
      });
      return;
    }

    // ขั้นสอง — ตรวจว่าตรงกันไหม
    if (_pin != _confirmPin) {
      setState(() {
        _pin   = '';
        _error = 'PIN ไม่ตรงกัน กรุณากรอกใหม่';
        _isConfirm  = false;
        _confirmPin = '';
      });
      return;
    }

    // บันทึก PIN ไป API
    setState(() => _isLoading = true);
    try {
      await _api.post(ApiConstants.setPin, body: {'pin': _pin});
      await _storage.savePinEnabled(true);

      if (!mounted) return;
      context.go('/home');
    } catch (_) {
      setState(() {
        _error     = 'บันทึก PIN ไม่สำเร็จ';
        _isLoading = false;
        _pin       = '';
      });
    }
  }

  // ยืนยัน PIN (ตอนเปิดแอป)
  Future<void> _handleVerify() async {
    setState(() => _isLoading = true);
    try {
      await _api.post(ApiConstants.verifyPin, body: {'pin': _pin});
      if (!mounted) return;
      context.go('/home');
    } catch (_) {
      setState(() {
        _pin       = '';
        _error     = 'PIN ไม่ถูกต้อง';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.mode == PinMode.setup
        ? (_isConfirm ? 'ยืนยัน PIN อีกครั้ง' : 'ตั้ง PIN 6 หลัก')
        : 'กรอก PIN เพื่อเข้าใช้งาน';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // ไอคอน
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 20),

            Text(title,
              style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
              )),
            const SizedBox(height: 8),

            const Text('รหัสจะใช้เข้าแอปแทน password',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 40),

            // วงกลมแสดง PIN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) => Container(
                width: 16, height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length
                      ? AppColors.primary
                      : AppColors.border,
                ),
              )),
            ),

            // Error message
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ],

            const Spacer(),

            // Numpad
            if (_isLoading)
              const CircularProgressIndicator(color: AppColors.primary)
            else
              _buildNumpad(),

            const SizedBox(height: 40),

            // ข้าม (เฉพาะ setup)
            if (widget.mode == PinMode.setup)
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('ข้ามไปก่อน',
                  style: TextStyle(color: AppColors.textSecondary)),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['1','2','3'],
      ['4','5','6'],
      ['7','8','9'],
      ['','0','del'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: keys.map((row) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) => _buildKey(key)).toList(),
        )).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    if (key.isEmpty) return const SizedBox(width: 72, height: 72);

    return GestureDetector(
      onTap: () => key == 'del' ? _onDelete() : _onKeyTap(key),
      child: Container(
        width: 72, height: 72,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: key == 'del'
              ? const Icon(Icons.backspace_outlined,
                  size: 22, color: AppColors.textSecondary)
              : Text(key,
                  style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  )),
        ),
      ),
    );
  }
}