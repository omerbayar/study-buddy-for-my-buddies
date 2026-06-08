import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 0)
class Subject extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int colorValue;

  @HiveField(3)
  late String emoji;

  Subject({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.emoji,
  });
}
