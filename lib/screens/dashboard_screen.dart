import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/stats_provider.dart';
import '../providers/timer_provider.dart';
import '../repositories/study_repository.dart';
import '../widgets/pomodoro_widget.dart';
import '../widgets/streak_card.dart';
import '../widgets/today_progress_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.read<TimerProvider>();
    final repo = context.read<StudyRepository>();
    final subjects = repo.getSubjects();

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (e) {
        if (e is! KeyDownEvent) return;
        final key = e.logicalKey;
        final meta = HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed;
        if (meta) return;

        if (key == LogicalKeyboardKey.space) {
          timer.startPause();
        } else if (key == LogicalKeyboardKey.keyS) {
          timer.skip();
        } else if (key == LogicalKeyboardKey.keyR) {
          timer.reset();
        } else {
          final digit = _digitFromKey(key);
          if (digit != null && digit > 0 && digit <= subjects.length) {
            timer.selectSubject(subjects[digit - 1].id);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Study Buddy'),
          actions: [
            _TodayMinutesBadge(),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: StreakCard()),
                      const SizedBox(width: 12),
                      Expanded(child: _QuestionNetCard()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const TodayProgressCard(),
                  const SizedBox(height: 12),
                  const PomodoroWidget(),
                  if (subjects.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SubjectQuickSelect(subjects: subjects),
                  ],
                  const SizedBox(height: 24),
                  _ShortcutHint(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int? _digitFromKey(LogicalKeyboardKey key) {
    const keys = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit7,
      LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.digit9,
    ];
    final idx = keys.indexOf(key);
    return idx >= 0 ? idx + 1 : null;
  }
}

class _TodayMinutesBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final minutes = context.watch<StatsProvider>().todayMinutes;
    return Chip(
      label: Text('${minutes}dk bugün'),
      avatar: const Icon(Icons.access_time, size: 16),
    );
  }
}

class _QuestionNetCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repo = context.read<StudyRepository>();
    final logs = repo.getQuestionsForDate(DateTime.now());
    final totalNet = logs.fold(0, (sum, q) => sum + q.net);
    final totalSolved = logs.fold(0, (sum, q) => sum + q.total);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const Text('📝', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalNet net',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$totalSolved soru',
                  style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectQuickSelect extends StatelessWidget {
  const _SubjectQuickSelect({required this.subjects});
  final List subjects;

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Hızlı ders seçimi',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(subjects.length, (i) {
            final s = subjects[i];
            final selected = timer.activeSubjectId == s.id;
            return InputChip(
              avatar: Text(s.emoji),
              label: Text(
                  '${i < 9 ? '${i + 1}. ' : ''}${s.name}'),
              selected: selected,
              onPressed: () => timer.selectSubject(s.id),
            );
          }),
        ),
      ],
    );
  }
}

class _ShortcutHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Space: başlat/durdur  •  S: atla  •  R: sıfırla  •  1-9: ders seç',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}
