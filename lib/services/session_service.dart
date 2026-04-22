import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyFirstTime = 'first_time';

  // Menyimpan status apakah user sudah pernah melihat onboarding
  static Future<void> setFirstTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstTime, value);
  }

  // Mengecek apakah ini pertama kalinya aplikasi dibuka
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    // Jika null (belum pernah diset), default-nya adalah true
    return prefs.getBool(_keyFirstTime) ?? true;
  }
}
