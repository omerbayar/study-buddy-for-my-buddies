import 'package:hive/hive.dart';

part 'daily_goal.g.dart';

@HiveType(typeId: 2)
class DailyGoal extends HiveObject {
  @HiveField(0)
  late String dateKey; // 'yyyy-MM-dd' formatında

  @HiveField(1)
  late int targetMinutes;

  @HiveField(2)
  late int targetQuestions;

  DailyGoal({
    required this.dateKey,
    required this.targetMinutes,
    required this.targetQuestions,
  });
}
