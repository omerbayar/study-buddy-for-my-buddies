import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/translations.dart';
import '../models/question_log.dart';
import '../models/subject.dart';
import '../repositories/study_repository.dart';

class QuestionsPanel extends StatefulWidget {
  const QuestionsPanel({super.key});

  @override
  State<QuestionsPanel> createState() => _QuestionsPanelState();
}

class _QuestionsPanelState extends State<QuestionsPanel> {
  Subject? _selectedSubject;
  int _correct = 0;
  int _wrong = 0;
  int _blank = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final subjects = context.read<StudyRepository>().getSubjects();
    if (subjects.isNotEmpty) _selectedSubject = subjects.first;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  int get _net => _correct - (_wrong ~/ 4);

  @override
  Widget build(BuildContext context) {
    final repo = context.read<StudyRepository>();
    final subjects = repo.getSubjects();
    final todayLogs = repo.getQuestionsForDate(DateTime.now());

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (e) {
        if (e is! KeyDownEvent) return;
        final meta = HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed;
        if (meta) return;
        final k = e.logicalKey;
        if (k == LogicalKeyboardKey.arrowRight ||
            k == LogicalKeyboardKey.keyD) {
          setState(() => _correct++);
        } else if (k == LogicalKeyboardKey.arrowLeft ||
            k == LogicalKeyboardKey.keyA) {
          setState(() => _wrong++);
        } else if (k == LogicalKeyboardKey.arrowDown ||
            k == LogicalKeyboardKey.keyX) {
          setState(() => _blank++);
        } else if (k == LogicalKeyboardKey.keyZ) {
          _undo();
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (subjects.isNotEmpty)
                  DropdownButtonFormField<Subject>(
                    initialValue: _selectedSubject,
                    decoration: InputDecoration(
                      labelText: translate('questions.field_subject'),
                      border: const OutlineInputBorder(),
                    ),
                    items: subjects
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Row(children: [
                                Text(s.emoji),
                                const SizedBox(width: 8),
                                Text(s.name),
                              ]),
                            ))
                        .toList(),
                    onChanged: (s) => setState(() => _selectedSubject = s),
                  ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          translate('questions.net_label', {'net': _net}),
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          translate('questions.counter_detail', {
                            'correct': _correct,
                            'wrong': _wrong,
                            'blank': _blank,
                          }),
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _CounterButton(
                      label: translate('questions.label_correct'),
                      emoji: '✅',
                      count: _correct,
                      color: Colors.green,
                      onTap: () => setState(() => _correct++),
                      onLongPress: () =>
                          setState(() => _correct = (_correct - 1).clamp(0, 9999)),
                    ),
                    const SizedBox(width: 8),
                    _CounterButton(
                      label: translate('questions.label_wrong'),
                      emoji: '❌',
                      count: _wrong,
                      color: Colors.red,
                      onTap: () => setState(() => _wrong++),
                      onLongPress: () =>
                          setState(() => _wrong = (_wrong - 1).clamp(0, 9999)),
                    ),
                    const SizedBox(width: 8),
                    _CounterButton(
                      label: translate('questions.label_blank'),
                      emoji: '⬜',
                      count: _blank,
                      color: Colors.grey,
                      onTap: () => setState(() => _blank++),
                      onLongPress: () =>
                          setState(() => _blank = (_blank - 1).clamp(0, 9999)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  translate('questions.shortcut_hint'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        child: Text(translate('questions.btn_reset')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _selectedSubject == null
                            ? null
                            : () => _save(repo),
                        child: Text(translate('questions.btn_save')),
                      ),
                    ),
                  ],
                ),
                if (todayLogs.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(translate('questions.today_header'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...todayLogs.map((log) =>
                      _LogTile(log: log, subjects: subjects)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _undo() {
    setState(() {
      if (_correct > 0) {
        _correct--;
      } else if (_wrong > 0) {
        _wrong--;
      } else if (_blank > 0) {
        _blank--;
      }
    });
  }

  void _reset() => setState(() {
        _correct = 0;
        _wrong = 0;
        _blank = 0;
      });

  Future<void> _save(StudyRepository repo) async {
    if (_selectedSubject == null) return;
    await repo.saveQuestionLog(QuestionLog(
      id: const Uuid().v4(),
      subjectId: _selectedSubject!.id,
      date: DateTime.now(),
      correct: _correct,
      wrong: _wrong,
      blank: _blank,
    ));
    _reset();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('questions.snack_saved'))),
      );
    }
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.label,
    required this.emoji,
    required this.count,
    required this.color,
    required this.onTap,
    required this.onLongPress,
  });

  final String label;
  final String emoji;
  final int count;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Card(
          color: color.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(label,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log, required this.subjects});
  final QuestionLog log;
  final List<Subject> subjects;

  @override
  Widget build(BuildContext context) {
    final subject =
        subjects.where((s) => s.id == log.subjectId).firstOrNull;
    return ListTile(
      leading: Text(subject?.emoji ?? '📝',
          style: const TextStyle(fontSize: 24)),
      title: Text(subject?.name ??
          translate('questions.unknown_subject')),
      subtitle: Text(translate('questions.log_detail', {
        'correct': log.correct,
        'wrong': log.wrong,
        'blank': log.blank,
      })),
      trailing: Text(
        translate('questions.net_label', {'net': log.net}),
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: log.net > 0 ? Colors.green : Colors.red),
      ),
    );
  }
}
