import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/translations.dart';
import '../models/subject.dart';
import '../providers/timer_provider.dart';
import '../repositories/study_repository.dart';

class PomodoroWidget extends StatelessWidget {
  const PomodoroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    final repo = context.read<StudyRepository>();
    final subjects = repo.getSubjects();

    final minutes = timer.remainingSeconds ~/ 60;
    final seconds = timer.remainingSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final phaseLabel = switch (timer.phase) {
      TimerPhase.focus => translate('pomodoro.phase_focus'),
      TimerPhase.shortBreak => translate('pomodoro.phase_short_break'),
      TimerPhase.longBreak => translate('pomodoro.phase_long_break'),
    };

    final phaseColor = switch (timer.phase) {
      TimerPhase.focus => Theme.of(context).colorScheme.primary,
      TimerPhase.shortBreak => Colors.green,
      TimerPhase.longBreak => Colors.teal,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(phaseLabel,
                      style: TextStyle(color: phaseColor)),
                  backgroundColor: phaseColor.withAlpha(25),
                  side: BorderSide(color: phaseColor.withAlpha(60)),
                ),
                Text('${timer.pomodoroCount} 🍅',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: timer.progress,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(timeStr,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (subjects.isNotEmpty) ...[
              _SubjectSelector(subjects: subjects, timer: timer),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  tooltip: translate('pomodoro.reset_tooltip'),
                  onPressed: timer.reset,
                  icon: const Icon(Icons.replay),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: timer.startPause,
                    child: Icon(
                      timer.running ? Icons.pause : Icons.play_arrow,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton.filledTonal(
                  tooltip: translate('pomodoro.skip_tooltip'),
                  onPressed: timer.skip,
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectSelector extends StatelessWidget {
  const _SubjectSelector({required this.subjects, required this.timer});

  final List<Subject> subjects;
  final TimerProvider timer;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: timer.activeSubjectId,
      hint: Text(translate('pomodoro.select_subject')),
      isExpanded: true,
      items: subjects
          .map((s) => DropdownMenuItem(
                value: s.id,
                child: Row(
                  children: [
                    Text(s.emoji),
                    const SizedBox(width: 8),
                    Text(s.name),
                  ],
                ),
              ))
          .toList(),
      onChanged: timer.selectSubject,
    );
  }
}
