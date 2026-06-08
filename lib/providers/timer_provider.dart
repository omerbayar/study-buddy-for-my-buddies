import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/study_session.dart';
import '../repositories/study_repository.dart';

enum TimerPhase { focus, shortBreak, longBreak }

class TimerProvider extends ChangeNotifier {
  static const _focusMinutes = 25;
  static const _shortBreakMinutes = 5;
  static const _longBreakMinutes = 15;

  final StudyRepository _repo;

  TimerProvider(this._repo);

  TimerPhase _phase = TimerPhase.focus;
  int _remainingSeconds = _focusMinutes * 60;
  bool _running = false;
  String? _activeSubjectId;
  int _pomodoroCount = 0;
  DateTime? _sessionStart;
  Timer? _timer;

  TimerPhase get phase => _phase;
  int get remainingSeconds => _remainingSeconds;
  bool get running => _running;
  String? get activeSubjectId => _activeSubjectId;
  int get pomodoroCount => _pomodoroCount;

  int get totalSeconds {
    return switch (_phase) {
      TimerPhase.focus => _focusMinutes * 60,
      TimerPhase.shortBreak => _shortBreakMinutes * 60,
      TimerPhase.longBreak => _longBreakMinutes * 60,
    };
  }

  double get progress =>
      (_remainingSeconds / totalSeconds).clamp(0.0, 1.0);

  void selectSubject(String? id) {
    _activeSubjectId = id;
    notifyListeners();
  }

  void startPause() {
    if (_running) {
      _pause();
    } else {
      _start();
    }
  }

  void _start() {
    _running = true;
    _sessionStart ??= DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void _pause() {
    _running = false;
    _timer?.cancel();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _running = false;
    _sessionStart = null;
    _remainingSeconds = _durationFor(_phase) * 60;
    notifyListeners();
  }

  void skip() {
    _timer?.cancel();
    _running = false;
    _onPhaseComplete();
  }

  void _tick() {
    if (_remainingSeconds > 0) {
      _remainingSeconds--;
      notifyListeners();
    } else {
      _onPhaseComplete();
    }
  }

  Future<void> _onPhaseComplete() async {
    if (_phase == TimerPhase.focus) {
      _pomodoroCount++;
      if (_activeSubjectId != null && _sessionStart != null) {
        final elapsed =
            DateTime.now().difference(_sessionStart!).inMinutes.clamp(1, 60);
        await _repo.saveSession(StudySession(
          id: const Uuid().v4(),
          subjectId: _activeSubjectId!,
          startTime: _sessionStart!,
          durationMinutes: elapsed,
          isPomodoro: true,
        ));
      }
      _sessionStart = null;
      _phase = (_pomodoroCount % 4 == 0)
          ? TimerPhase.longBreak
          : TimerPhase.shortBreak;
    } else {
      _phase = TimerPhase.focus;
    }
    _remainingSeconds = _durationFor(_phase) * 60;
    _running = false;
    notifyListeners();
  }

  int _durationFor(TimerPhase p) => switch (p) {
        TimerPhase.focus => _focusMinutes,
        TimerPhase.shortBreak => _shortBreakMinutes,
        TimerPhase.longBreak => _longBreakMinutes,
      };

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
