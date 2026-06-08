import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Translations {
  Translations._();

  static final Translations instance = Translations._();

  Map<String, String> _strings = {};
  Locale _current = const Locale('tr');

  Locale get current => _current;

  static const List<Locale> supported = [
    Locale('tr'),
    Locale('en'),
    Locale('de'),
    Locale('fr'),
    Locale('ro'),
  ];

  Future<void> load(Locale locale) async {
    _current = locale;
    final data = await rootBundle
        .loadString('assets/translations/${locale.languageCode}.json');
    final map = json.decode(data) as Map<String, dynamic>;
    _strings = map.map((k, v) => MapEntry(k, v.toString()));
  }

  String get(String slug, [Map<String, Object>? params]) {
    var value = _strings[slug] ?? slug;
    if (params != null) {
      params.forEach((key, replacement) {
        value = value.replaceAll('{$key}', replacement.toString());
      });
    }
    return value;
  }

  static LocalizationsDelegate<Translations> get delegate =>
      _TranslationsDelegate();
}

class _TranslationsDelegate extends LocalizationsDelegate<Translations> {
  @override
  bool isSupported(Locale locale) => Translations.supported
      .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<Translations> load(Locale locale) async {
    await Translations.instance.load(locale);
    return Translations.instance;
  }

  @override
  bool shouldReload(_TranslationsDelegate old) => false;
}

String translate(String slug, [Map<String, Object>? params]) =>
    Translations.instance.get(slug, params);

String t(String slug, [Map<String, Object>? params]) =>
    translate(slug, params);
