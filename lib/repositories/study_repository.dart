import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/bullet_item.dart';
import '../models/bullet_list_model.dart';
import '../models/daily_goal.dart';
import '../models/note.dart';
import '../models/question_log.dart';
import '../models/study_session.dart';
import '../models/subject.dart';

class StudyRepository {
  static const _subjectBox = 'subjects';
  static const _sessionBox = 'sessions';
  static const _goalBox = 'goals';
  static const _questionBox = 'questions';
  static const _noteBox = 'notes';
  static const _bulletBox = 'bullet_lists';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(StudySessionAdapter());
    Hive.registerAdapter(DailyGoalAdapter());
    Hive.registerAdapter(QuestionLogAdapter());
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(BulletItemAdapter());
    Hive.registerAdapter(BulletListModelAdapter());
    await Hive.openBox<Subject>(_subjectBox);
    await Hive.openBox<StudySession>(_sessionBox);
    await Hive.openBox<DailyGoal>(_goalBox);
    await Hive.openBox<QuestionLog>(_questionBox);
    await Hive.openBox<Note>(_noteBox);
    await Hive.openBox<BulletListModel>(_bulletBox);
  }

  Box<Subject> get _subjects => Hive.box<Subject>(_subjectBox);
  Box<StudySession> get _sessions => Hive.box<StudySession>(_sessionBox);
  Box<DailyGoal> get _goals => Hive.box<DailyGoal>(_goalBox);
  Box<QuestionLog> get _questions => Hive.box<QuestionLog>(_questionBox);
  Box<Note> get _notes => Hive.box<Note>(_noteBox);
  Box<BulletListModel> get _bullets => Hive.box<BulletListModel>(_bulletBox);

  // --- Subjects ---
  List<Subject> getSubjects() => _subjects.values.toList();
  ValueListenable<Box<Subject>> watchSubjects() => _subjects.listenable();

  Future<void> saveSubject(Subject s) => _subjects.put(s.id, s);
  Future<void> deleteSubject(String id) => _subjects.delete(id);

  // --- Sessions ---
  List<StudySession> getSessions() => _sessions.values.toList();
  ValueListenable<Box<StudySession>> watchSessions() =>
      _sessions.listenable();

  Future<void> saveSession(StudySession s) => _sessions.put(s.id, s);

  List<StudySession> getSessionsForDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return _sessions.values
        .where((s) => DateFormat('yyyy-MM-dd').format(s.startTime) == key)
        .toList();
  }

  // --- Goals ---
  DailyGoal? getGoalForDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return _goals.get(key);
  }

  Future<void> saveGoal(DailyGoal g) => _goals.put(g.dateKey, g);

  // --- Questions ---
  List<QuestionLog> getQuestionsForDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return _questions.values
        .where((q) => DateFormat('yyyy-MM-dd').format(q.date) == key)
        .toList();
  }

  ValueListenable<Box<QuestionLog>> watchQuestions() =>
      _questions.listenable();

  Future<void> saveQuestionLog(QuestionLog q) => _questions.put(q.id, q);

  // --- Notes ---
  List<Note> getNotes() =>
      _notes.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  ValueListenable<Box<Note>> watchNotes() => _notes.listenable();

  Future<void> saveNote(Note n) => _notes.put(n.id, n);
  Future<void> deleteNote(String id) => _notes.delete(id);

  // --- Bullet Lists ---
  List<BulletListModel> getBulletLists() =>
      _bullets.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  ValueListenable<Box<BulletListModel>> watchBulletLists() => _bullets.listenable();

  Future<void> saveBulletList(BulletListModel l) => _bullets.put(l.id, l);

  Future<void> deleteBulletList(String id) => _bullets.delete(id);
}
