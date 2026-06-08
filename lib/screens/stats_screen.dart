import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/translations.dart';
import '../providers/stats_provider.dart';
import '../repositories/study_repository.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(translate('stats.title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WeeklyBarChart(),
                SizedBox(height: 16),
                _SubjectPieChart(),
                SizedBox(height: 16),
                _SummaryStats(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart();

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final minutes = stats.weeklyMinutes();
    final maxY = minutes.reduce((a, b) => a > b ? a : b).toDouble();
    final now = DateTime.now();
    final locale = Translations.instance.current.languageCode;

    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateFormat('E', locale).format(d);
    });

    final minUnit = translate('stats.minute_unit');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translate('stats.last7days'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: maxY == 0
                  ? Center(child: Text(translate('stats.no_data')))
                  : BarChart(
                      BarChartData(
                        maxY: maxY + 10,
                        barGroups: List.generate(
                          7,
                          (i) => BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: minutes[i].toDouble(),
                                color: Theme.of(context).colorScheme.primary,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) => Text(
                                dayLabels[v.toInt()],
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (v, _) => Text(
                                '${v.toInt()}$minUnit',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectPieChart extends StatelessWidget {
  const _SubjectPieChart();

  static const _colors = [
    Color(0xFF6C63FF),
    Color(0xFF4CAF50),
    Color(0xFFFF5722),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final repo = context.read<StudyRepository>();
    final distribution = stats.subjectMinutesToday();
    final subjects = repo.getSubjects();
    final minUnit = translate('stats.minute_unit');

    if (distribution.isEmpty) return const SizedBox.shrink();

    final sections = distribution.entries.toList().asMap().entries.map((entry) {
      final i = entry.key;
      final mapEntry = entry.value;
      return PieChartSectionData(
        value: mapEntry.value.toDouble(),
        color: _colors[i % _colors.length],
        title: '${mapEntry.value}$minUnit',
        radius: 60,
        titleStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translate('stats.today_distribution'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: PieChart(PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  )),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: distribution.entries.toList().asMap().entries.map(
                      (entry) {
                        final i = entry.key;
                        final mapEntry = entry.value;
                        final subject = subjects
                            .where((s) => s.id == mapEntry.key)
                            .firstOrNull;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _colors[i % _colors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  '${subject?.emoji ?? ''} ${subject?.name ?? mapEntry.key}'),
                            ],
                          ),
                        );
                      },
                    ).toList(),
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

class _SummaryStats extends StatelessWidget {
  const _SummaryStats();

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final repo = context.read<StudyRepository>();
    final weekMin = stats.weeklyMinutes().fold(0, (a, b) => a + b);
    final allSessions = repo.getSessions();
    final totalMin = allSessions.fold(0, (s, e) => s + e.durationMinutes);
    final streak = stats.streak;
    final minUnit = translate('stats.minute_unit');
    final hrUnit = translate('stats.hour_unit');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translate('stats.general'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _StatRow(
                icon: '📅',
                label: translate('stats.this_week'),
                value:
                    '$weekMin$minUnit (${(weekMin / 60).toStringAsFixed(1)}$hrUnit)'),
            _StatRow(
                icon: '📊',
                label: translate('stats.total'),
                value:
                    '$totalMin$minUnit (${(totalMin / 60).toStringAsFixed(1)}$hrUnit)'),
            _StatRow(
                icon: '🔥',
                label: translate('stats.longest_streak'),
                value: translate('streak.days', {'count': streak})),
            _StatRow(
                icon: '🍅',
                label: translate('stats.total_sessions'),
                value: '${allSessions.length}'),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(
      {required this.icon, required this.label, required this.value});

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
