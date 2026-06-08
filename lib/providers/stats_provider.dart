import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../repositories/study_repository.dart';

class StatsProvider extends ChangeNotifier {
  final StudyRepository _repo;

  StatsProvider(this._repo) {
    _repo.watchSessions().addListener(_onDataChanged);
  }

  void _onDataChanged() => notifyListeners();

  int get todayMinutes {
    final sessions = _repo.getSessionsForDate(DateTime.now());
    return sessions.fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int get streak {
    int count = 0;
    var day = DateTime.now();
    while (true) {
      final goal = _repo.getGoalForDate(day);
      final sessions = _repo.getSessionsForDate(day);
      final minutes = sessions.fold(0, (s, e) => s + e.durationMinutes);
      final target = goal?.targetMinutes ?? 60;
      if (minutes >= target) {
        count++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return count;
  }

  List<int> weeklyMinutes() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final sessions = _repo.getSessionsForDate(day);
      return sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    });
  }

  Map<String, int> subjectMinutesToday() {
    final sessions = _repo.getSessionsForDate(DateTime.now());
    final result = <String, int>{};
    for (final s in sessions) {
      result[s.subjectId] = (result[s.subjectId] ?? 0) + s.durationMinutes;
    }
    return result;
  }

  String get todayDateKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void dispose() {
    _repo.watchSessions().removeListener(_onDataChanged);
    super.dispose();
  }
}
