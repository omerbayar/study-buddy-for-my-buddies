import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/translations.dart';
import '../models/daily_goal.dart';
import '../providers/stats_provider.dart';
import '../repositories/study_repository.dart';

class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final repo = context.read<StudyRepository>();
    final goal = repo.getGoalForDate(DateTime.now());
    final targetMin = goal?.targetMinutes ?? 60;
    final todayMin = stats.todayMinutes;
    final progress = (todayMin / targetMin).clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;
    final minUnit = translate('today_progress.minute_unit');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(translate('today_progress.title'),
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(translate('today_progress.edit_label')),
                  onPressed: () => _editGoal(context, repo, targetMin,
                      goal?.targetQuestions ?? 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$todayMin$minUnit',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold),
                ),
                Text(' / $targetMin$minUnit',
                    style: TextStyle(color: colorScheme.onSurfaceVariant)),
                const Spacer(),
                Text(
                  translate('today_progress.percent',
                      {'percent': (progress * 100).round()}),
                  style: TextStyle(
                      color: progress >= 1
                          ? Colors.green
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                    progress >= 1 ? Colors.green : colorScheme.primary),
              ),
            ),
            if (progress >= 1) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(translate('today_progress.congrats'),
                      style: const TextStyle(color: Colors.green)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _editGoal(
    BuildContext context,
    StudyRepository repo,
    int currentMinutes,
    int currentQuestions,
  ) {
    final minCtrl =
        TextEditingController(text: currentMinutes.toString());
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translate('today_progress.dialog_title')),
        content: TextField(
          controller: minCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: translate('today_progress.dialog_field'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(translate('common.cancel'))),
          FilledButton(
            onPressed: () async {
              final min = int.tryParse(minCtrl.text) ?? currentMinutes;
              final today = DateTime.now();
              final key =
                  '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
              await repo.saveGoal(DailyGoal(
                dateKey: key,
                targetMinutes: min,
                targetQuestions: currentQuestions,
              ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(translate('common.save')),
          ),
        ],
      ),
    );
  }
}
