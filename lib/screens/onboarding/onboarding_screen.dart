import 'package:flutter/material.dart';
import '../../services/session_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> data = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Pantau Tumbuh Kembang",
      "desc": "Catat perkembangan anak dengan mudah dan cepat",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Notifikasi Jadwal",
      "desc": "Ingatkan jadwal posyandu tanpa terlewat",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Data Aman",
      "desc": "Semua data tersimpan dengan aman",
    },
  ];

  void finishOnboarding() async {
    await SessionService.setFirstTime(false);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          /// 🔥 SKIP BUTTON
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: finishOnboarding,
                child: const Text("Skip"),
              ),
            ),
          ),

          /// 🔥 CONTENT
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: data.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// IMAGE (ILUSTRASI FIGMA)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 600),
                        opacity: currentIndex == index ? 1 : 0.3,
                        child: Image.asset(data[index]['image']!, height: 250),
                      ),

                      const SizedBox(height: 40),

                      /// TITLE
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 500),
                        offset: currentIndex == index
                            ? Offset.zero
                            : const Offset(0, 0.3),
                        child: Text(
                          data[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// DESC
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 600),
                        opacity: currentIndex == index ? 1 : 0,
                        child: Text(
                          data[index]['desc']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// 🔥 INDICATOR
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(data.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(4),
                width: currentIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.green
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),

          const SizedBox(height: 30),

          /// 🔥 BUTTON PREMIUM
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  currentIndex == data.length - 1 ? "Mulai Sekarang" : "Lanjut",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
