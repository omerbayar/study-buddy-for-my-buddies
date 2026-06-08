import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/theme.dart';
import 'providers/stats_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/timer_provider.dart';
import 'repositories/study_repository.dart';
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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
    return MaterialApp(
      title: 'Study Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.mode,
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
    return KeyboardListener(
      focusNode: _rootFocus,
      autofocus: true,
      onKeyEvent: (e) {
        if (e is! KeyDownEvent) return;
        final meta = HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed;
        final key = e.logicalKey;

        if (meta && key == LogicalKeyboardKey.keyK) {
          CommandPalette.show(context, _navigate);
          return;
        }
        if (!meta && key == LogicalKeyboardKey.slash) {
          // let child handle it (notes search)
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
            label: 'Dashboard',
            icon: const Icon(Icons.dashboard_outlined),
            body: const DashboardScreen(),
          ),
          NavDestinationConfig(
            label: 'Dersler',
            icon: const Icon(Icons.book_outlined),
            body: const SubjectsScreen(),
          ),
          NavDestinationConfig(
            label: 'Sorular',
            icon: const Icon(Icons.quiz_outlined),
            body: const QuestionsPanel(),
          ),
          NavDestinationConfig(
            label: 'İstatistik',
            icon: const Icon(Icons.bar_chart_outlined),
            body: const StatsScreen(),
          ),
          NavDestinationConfig(
            label: 'Notlar',
            icon: const Icon(Icons.notes_outlined),
            body: const NotesScreen(),
          ),
        ],
      ),
    );
  }
}
