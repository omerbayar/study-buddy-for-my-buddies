import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 4)
class Note extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String content;

  @HiveField(2)
  late DateTime createdAt;

  @HiveField(3)
  late List<String> tags;

  Note({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.tags,
  });
}
