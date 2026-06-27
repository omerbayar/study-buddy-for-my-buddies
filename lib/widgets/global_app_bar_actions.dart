import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/translations.dart';
import '../providers/locale_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/theme_provider.dart';
import 'shortcut_help_modal.dart';

class GlobalAppBarActions extends StatelessWidget {
  const GlobalAppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TodayMinutesBadge(),
        const SizedBox(width: 4),
        _ThemeToggleButton(),
        _LanguageButton(),
        IconButton(
          icon: const Icon(Icons.keyboard_outlined),
          tooltip: translate('dashboard.shortcuts_tooltip'),
          onPressed: () => ShortcutHelpModal.show(context),
        ),
      ],
    );
  }
}

class _TodayMinutesBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final minutes = context.watch<StatsProvider>().todayMinutes;
    return Chip(
      label: Text(translate('dashboard.minutes_today', {'minutes': minutes})),
      avatar: const Icon(Icons.access_time, size: 16),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      tooltip: isDark
          ? translate('dashboard.theme_light')
          : translate('dashboard.theme_dark'),
      onPressed: provider.toggle,
    );
  }
}

class _LanguageButton extends StatelessWidget {
  static const _flags = {
    'tr': '🇹🇷',
    'en': '🇬🇧',
    'de': '🇩🇪',
    'fr': '🇫🇷',
    'ro': '🇷🇴',
  };

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentCode = localeProvider.current.languageCode;

    return PopupMenuButton<Locale>(
      icon: Text(_flags[currentCode] ?? '🌐',
          style: const TextStyle(fontSize: 20)),
      tooltip: '',
      onSelected: (locale) => localeProvider.setLocale(locale),
      itemBuilder: (_) => Translations.supported.map((locale) {
        final code = locale.languageCode;
        return PopupMenuItem<Locale>(
          value: locale,
          child: Row(
            children: [
              Text(_flags[code] ?? '🌐', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(translate('lang.$code')),
            ],
          ),
        );
      }).toList(),
    );
  }
}
