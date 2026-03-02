import 'package:flutter/material.dart';
import '../data/repositories/user_repository.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  final UserRepository _userRepository = UserRepository();

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'ru', 'uz'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
    // Sync language preference to backend (fire-and-forget)
    _syncLanguageToBackend(locale.languageCode);
  }

  Future<void> _syncLanguageToBackend(String languageCode) async {
    try {
      await _userRepository.updateProfile(language: languageCode);
    } catch (_) {
      // Silently ignore — language switch works locally even if API fails
    }
  }

  void clearLocale() {
    _locale = const Locale('en');
    notifyListeners();
  }
}
