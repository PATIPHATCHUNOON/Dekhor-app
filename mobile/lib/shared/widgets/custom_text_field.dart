import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String         label;
  final String?        hint;
  final TextEditingController controller;
  final bool           isPassword;
  final TextInputType  keyboardType;
  final String?        Function(String?)? validator;
  final IconData?      prefixIcon;
  final String?        prefixSvgPath;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isPassword    = false,
    this.keyboardType  = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.prefixSvgPath,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), // Softer corners
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFCF8FF), // Pastel very light purple
                Color(0xFFE5D9F2), // PrimaryLight
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9D76C1).withOpacity(0.08), // Primary soft shadow
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: const Color(0xFFD0BFFF), width: 1.5),
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscure,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Color(0xFFBFA2DB), fontSize: 14),
              prefixIcon: widget.prefixSvgPath != null
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        widget.prefixSvgPath!,
                        colorFilter: const ColorFilter.mode(Color(0xFF9D76C1), BlendMode.srcIn),
                        width: 22,
                        height: 22,
                      ),
                    )
                  : widget.prefixIcon != null
                      ? Icon(widget.prefixIcon, color: const Color(0xFF9D76C1), size: 22)
                      : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF9D76C1),
                        size: 22,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}