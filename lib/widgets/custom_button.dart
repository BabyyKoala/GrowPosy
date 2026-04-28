import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Memisahkan isi konten agar kode tidak berulang
    final Widget buttonContent = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: isOutlined ? AppColor.primaryGreen : AppColor.bgWhite,
              strokeWidth: 2.5,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Agar ikon dan teks rapat ke tengah
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              // 🔥 PERBAIKAN: Dibungkus Flexible agar tidak overflow di layar kecil
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis, // Teks akan jadi "..." jika kepanjangan
                ),
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 52, // Standar target sentuh (touch target) UI/UX modern
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              child: buttonContent,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              child: buttonContent,
            ),
    );
  }
}