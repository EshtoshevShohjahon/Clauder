import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avtoassist/l10n/app_strings.dart';

/// Til boshqaruvi provideri
/// 4 til: en, ru, uz (lotin), uz_cyrl (kirill)
/// Tanlangan til SharedPreferences'da saqlanadi
class LocaleProvider extends ChangeNotifier {
  static const String _prefsKey = 'app_language';

  String _code = 'uz';
  String get code => _code;

  LocaleProvider() {
    _load();
  }

  /// Flutter Locale obyekti
  Locale get locale {
    switch (_code) {
      case 'en':
        return const Locale('en');
      case 'ru':
        return const Locale('ru');
      case 'uz_cyrl':
        return const Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl');
      case 'uz':
      default:
        return const Locale('uz');
    }
  }

  /// Qo'llab-quvvatlanadigan tillar ro'yxati
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
  ];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _code = prefs.getString(_prefsKey) ?? 'uz';
    notifyListeners();
  }

  /// Tilni o'zgartirish
  Future<void> setLanguage(String code) async {
    if (!AppStrings.values.containsKey(code)) return;
    _code = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
    notifyListeners();
  }

  /// Tarjima olish
  String t(String key) {
    return AppStrings.values[_code]?[key] ??
        AppStrings.values['uz']?[key] ??
        key;
  }

  /// Joriy til nomi
  String get currentLanguageName => AppStrings.languageNames[_code] ?? 'O\'zbekcha';
}
