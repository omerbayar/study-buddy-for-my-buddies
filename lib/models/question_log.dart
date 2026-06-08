import 'package:hive/hive.dart';

part 'question_log.g.dart';

@HiveType(typeId: 3)
class QuestionLog extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String subjectId;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late int correct;

  @HiveField(4)
  late int wrong;

  @HiveField(5)
  late int blank;

  QuestionLog({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.correct,
    required this.wrong,
    required this.blank,
  });

  int get total => correct + wrong + blank;
  int get net => correct - (wrong ~/ 4);
}
