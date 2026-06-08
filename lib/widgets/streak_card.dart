import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stats_provider.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    final streak = context.watch<StatsProvider>().streak;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Text(
              streak > 0 ? '🔥' : '❄️',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak gün',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: streak > 0
                            ? Colors.orange
                            : colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  'Seri',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
