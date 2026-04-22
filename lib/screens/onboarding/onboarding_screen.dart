import 'package:flutter/material.dart';
import '../../services/session_service.dart';

// 🔥 Import Sistem Tema & Custom Widgets
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  // 🔥 Teks telah disesuaikan agar MATCH dengan gambar yang kamu miliki
  final List<Map<String, String>> data = [
    {
      "image": "assets/images/onboarding1.png", // Gambar Ibu & Anak
      "title": "Pantau Tumbuh Kembang",
      "desc":
          "Catat perkembangan tinggi dan berat badan buah hati Anda dengan mudah dan akurat.",
    },
    {
      "image": "assets/images/onboarding2.png", // Gambar Grafik KMS
      "title": "Grafik KMS Digital",
      "desc":
          "Pantau status gizi anak melalui visualisasi grafik Kartu Menuju Sehat standar Kemenkes.",
    },
    {
      "image": "assets/images/onboarding3.png", // Gambar Perawat/Kader
      "title": "Terhubung dengan Posyandu",
      "desc":
          "Data terintegrasi langsung dengan para Kader untuk memastikan si kecil selalu sehat.",
    },
  ];

  void finishOnboarding() async {
    // Menandai bahwa user sudah pernah membuka aplikasi
    await SessionService.setFirstTime(false);

    if (!mounted) return;
    // Arahkan ke halaman pengecekan sesi utama (Splash/Login)
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      body: Column(
        children: [
          // 🔥 SKIP BUTTON
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                child: TextButton(
                  onPressed: finishOnboarding,
                  child: const Text(
                    "Lewati",
                    style: TextStyle(
                      color: AppColor.textGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🔥 CONTENT SLIDER
          Expanded(
            child: PageView.builder(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              itemCount: data.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ILUSTRASI FIGMA
                      AnimatedScale(
                        duration: const Duration(milliseconds: 400),
                        scale: currentIndex == index ? 1.0 : 0.8,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: currentIndex == index ? 1 : 0.3,
                          child: Image.asset(
                            data[index]['image']!,
                            height: 280,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // JUDUL
                      Text(
                        data[index]['title']!,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.heading1.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 16),

                      // DESKRIPSI
                      Text(
                        data[index]['desc']!,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bodyText.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 🔥 INDICATOR DOTS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(data.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: currentIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? AppColor.primaryGreen
                      : AppColor.borderGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),

          const SizedBox(height: 40),

          // 🔥 TOMBOL NAVIGASI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: CustomButton(
              text: currentIndex == data.length - 1
                  ? "Mulai Sekarang"
                  : "Lanjut",
              onPressed: () {
                if (currentIndex == data.length - 1) {
                  finishOnboarding();
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
