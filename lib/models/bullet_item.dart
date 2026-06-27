import 'package:hive/hive.dart';

part 'bullet_item.g.dart';

@HiveType(typeId: 6)
class BulletItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String label;

  @HiveField(2)
  final bool done;

  @HiveField(3)
  final int? number;

  @HiveField(4)
  final String? note;

  @HiveField(5)
  final int order;

  const BulletItem({
    required this.id,
    required this.label,
    required this.done,
    this.number,
    this.note,
    required this.order,
  });

  BulletItem copyWith({String? label, bool? done, String? note, bool clearNote = false}) {
    return BulletItem(
      id: id,
      label: label ?? this.label,
      done: done ?? this.done,
      number: number,
      note: clearNote ? null : (note ?? this.note),
      order: order,
    );
  }
}
