import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app/theme.dart';
import 'l10n/translations.dart';
import 'providers/locale_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/timer_provider.dart';
import 'repositories/study_repository.dart';
import 'screens/bullet_list_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/questions_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/subjects_screen.dart';
import 'widgets/adaptive_scaffold.dart';
import 'widgets/command_palette.dart';
import 'widgets/shortcut_help_modal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = StudyRepository();
  await StudyRepository.init();

  final localeProvider = LocaleProvider();
  await localeProvider.loadSaved();
  await Translations.instance.load(localeProvider.current);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: localeProvider),
        Provider<StudyRepository>.value(value: repo),
        ChangeNotifierProvider(create: (_) => StatsProvider(repo)),
        ChangeNotifierProvider(create: (_) => TimerProvider(repo)),
      ],
      child: const StudyBuddyApp(),
    ),
  );
}

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    return MaterialApp(
      title: translate('app.title'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.mode,
      locale: localeProvider.current,
      supportedLocales: Translations.supported,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _scaffoldKey = GlobalKey<AdaptiveScaffoldState>();
  final _rootFocus = FocusNode();

  @override
  void dispose() {
    _rootFocus.dispose();
    super.dispose();
  }

  void _navigate(int index) {
    _scaffoldKey.currentState?.navigateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocaleProvider>();
    return KeyboardListener(
      focusNode: _rootFocus,
      autofocus: true,
      onKeyEvent: (e) {
        if (e is! KeyDownEvent) return;
        final meta =
            HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed;
        final key = e.logicalKey;

        if (meta && key == LogicalKeyboardKey.keyK) {
          CommandPalette.show(context, _navigate);
          return;
        }
        if (!meta && key == LogicalKeyboardKey.slash) {
          return;
        }
        if (!meta && key == LogicalKeyboardKey.question) {
          ShortcutHelpModal.show(context);
          return;
        }
      },
      child: AdaptiveScaffold(
        key: _scaffoldKey,
        destinations: [
          NavDestinationConfig(
            label: translate('nav.dashboard'),
            icon: const Icon(Icons.dashboard_outlined),
            body: const DashboardScreen(),
          ),
          NavDestinationConfig(
            label: translate('nav.subjects'),
            icon: const Icon(Icons.book_outlined),
            body: const SubjectsScreen(),
          ),
          NavDestinationConfig(
            label: translate('nav.questions'),
            icon: const Icon(Icons.quiz_outlined),
            body: const QuestionsPanel(),
          ),
          NavDestinationConfig(
            label: translate('nav.stats'),
            icon: const Icon(Icons.bar_chart_outlined),
            body: const StatsScreen(),
          ),
          NavDestinationConfig(
            label: translate('nav.notes'),
            icon: const Icon(Icons.notes_outlined),
            body: const NotesScreen(),
          ),
          NavDestinationConfig(
            label: translate('nav.bullet_list'),
            icon: const Icon(Icons.checklist_outlined),
            body: const BulletListScreen(),
          ),
        ],
      ),
    );
  }
}
