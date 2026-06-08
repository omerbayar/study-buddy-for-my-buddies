import 'package:hive/hive.dart';

part 'study_session.g.dart';

@HiveType(typeId: 1)
class StudySession extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String subjectId;

  @HiveField(2)
  late DateTime startTime;

  @HiveField(3)
  late int durationMinutes;

  @HiveField(4)
  late bool isPomodoro;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.startTime,
    required this.durationMinutes,
    required this.isPomodoro,
  });
}
