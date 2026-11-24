import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._(this._preferences, this._isDark, this._fromCode, this._toCode);

  static const _darkThemeKey = 'dark_theme';
  static const _fromCurrencyKey = 'from_currency';
  static const _toCurrencyKey = 'to_currency';

  final SharedPreferences _preferences;
  bool _isDark;
  String _fromCode;
  String _toCode;

  static Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppSettings._(
      preferences,
      preferences.getBool(_darkThemeKey) ?? false,
      preferences.getString(_fromCurrencyKey) ?? 'RUB',
      preferences.getString(_toCurrencyKey) ?? 'USD',
    );
  }

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;
  String get fromCurrency => _fromCode;
  String get toCurrency => _toCode;

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    await _preferences.setBool(_darkThemeKey, _isDark);
  }

  Future<void> saveCurrencies(String from, String to) async {
    _fromCode = from;
    _toCode = to;
    notifyListeners();
    await _preferences.setString(_fromCurrencyKey, from);
    await _preferences.setString(_toCurrencyKey, to);
  }
}
