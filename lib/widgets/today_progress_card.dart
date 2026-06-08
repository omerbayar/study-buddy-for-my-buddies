import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bugünkü hedef',
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Düzenle'),
                  onPressed: () => _editGoal(context, repo, targetMin,
                      goal?.targetQuestions ?? 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${todayMin}dk',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold),
                ),
                Text(' / ${targetMin}dk',
                    style: TextStyle(color: colorScheme.onSurfaceVariant)),
                const Spacer(),
                Text(
                  '${(progress * 100).round()}%',
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
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text('Tebrikler! Hedefine ulaştın 🎉',
                      style: TextStyle(color: Colors.green)),
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
        title: const Text('Günlük hedef'),
        content: TextField(
          controller: minCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Hedef (dakika)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal')),
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
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

