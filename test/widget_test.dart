import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:bullet_list/main.dart';
import 'package:bullet_list/l10n/translations.dart';
import 'package:bullet_list/models/bullet_item.dart';
import 'package:bullet_list/models/bullet_list_model.dart';
import 'package:bullet_list/models/daily_goal.dart';
import 'package:bullet_list/models/note.dart';
import 'package:bullet_list/models/question_log.dart';
import 'package:bullet_list/models/study_session.dart';
import 'package:bullet_list/models/subject.dart';
import 'package:bullet_list/providers/locale_provider.dart';
import 'package:bullet_list/providers/stats_provider.dart';
import 'package:bullet_list/providers/theme_provider.dart';
import 'package:bullet_list/providers/timer_provider.dart';
import 'package:bullet_list/repositories/study_repository.dart';

void main() {
  late Directory tmpDir;

  setUpAll(() async {
    tmpDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tmpDir.path);
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(StudySessionAdapter());
    Hive.registerAdapter(DailyGoalAdapter());
    Hive.registerAdapter(QuestionLogAdapter());
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(BulletItemAdapter());
    Hive.registerAdapter(BulletListModelAdapter());
    await Hive.openBox<Subject>('subjects');
    await Hive.openBox<StudySession>('sessions');
    await Hive.openBox<DailyGoal>('goals');
    await Hive.openBox<QuestionLog>('questions');
    await Hive.openBox<Note>('notes');
    await Hive.openBox<BulletListModel>('bullet_lists');
    await Translations.instance.load(const Locale('tr'));
  });

  tearDownAll(() async {
    await Hive.close();
    await tmpDir.delete(recursive: true);
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    final repo = StudyRepository();
    final localeProvider = LocaleProvider();

    await tester.pumpWidget(
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
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
