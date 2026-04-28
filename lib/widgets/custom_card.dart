import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../theme/app_text_style.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final Widget? trailingWidget;

  const CustomCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.color,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColor.primaryGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.bgWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.borderGrey),
        boxShadow: [
          BoxShadow(
            color: AppColor.textBlack.withOpacity(0.04), // Bayangan lebih lembut
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            highlightColor: activeColor.withOpacity(0.05),
            splashColor: activeColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: activeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: activeColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyle.heading3.copyWith(fontSize: 16),
                          // 🔥 PERBAIKAN: Mencegah judul merusak layout
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTextStyle.bodySmall,
                          // 🔥 PERBAIKAN: Subtitle maksimal 2 baris
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  trailingWidget ??
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColor.textLightGrey,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}