import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  // 🔥 1. Tambahkan variabel untuk TextCapitalization
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    // 🔥 2. Beri nilai default 'none' agar tidak merusak form lama (seperti email/password)
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      // 🔥 3. Pasang variabelnya di sini agar efeknya aktif
      textCapitalization: textCapitalization,

      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColor.textGrey),
        prefixIcon: Icon(prefixIcon, color: AppColor.textGrey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColor.bgWhite,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.primaryGreen, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
