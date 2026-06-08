import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/theme.dart';
import 'providers/theme_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/subjects_screen.dart';
import 'widgets/adaptive_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
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
    );
  }
}
