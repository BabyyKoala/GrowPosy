import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final String? initialValue;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.initialValue,
  }) : 
  // 🔥 PERBAIKAN: Mencegah crash jika developer memasukkan controller DAN initialValue bersamaan
  assert(
         initialValue == null || controller == null,
         'Tidak boleh menggunakan initialValue dan controller secara bersamaan. Jika ada controller, set nilai awalnya melalui controller.text!',
       );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: isPassword,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      onTap: onTap,
      // 🔥 PERBAIKAN: Jika isPassword true, maxLines WAJIB 1.
      maxLines: isPassword ? 1 : maxLines, 
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColor.textLightGrey)
            : null,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}