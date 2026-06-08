import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../l10n/translations.dart';

class LocaleProvider extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _key = 'locale';

  Locale _current = const Locale('tr');

  Locale get current => _current;

  static Future<void> ensureBoxOpen() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
  }

  Future<void> loadSaved() async {
    await ensureBoxOpen();
    final box = Hive.box<String>(_boxName);
    final saved = box.get(_key);
    if (saved != null &&
        Translations.supported.any((l) => l.languageCode == saved)) {
      _current = Locale(saved);
    } else {
      _current = const Locale('tr');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == _current.languageCode) return;
    await Translations.instance.load(locale);
    _current = locale;
    final box = Hive.box<String>(_boxName);
    await box.put(_key, locale.languageCode);
    notifyListeners();
  }
}
