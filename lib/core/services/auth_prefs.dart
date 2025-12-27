import 'package:shared_preferences/shared_preferences.dart';

class AuthPrefs {
  static const _kRememberMe = 'remember_me';

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kRememberMe) ?? true; // default ON
  }

  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRememberMe, value);
  }
}
