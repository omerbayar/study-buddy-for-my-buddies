import 'package:hive/hive.dart';

import 'bullet_item.dart';

part 'bullet_list_model.g.dart';

@HiveType(typeId: 5)
class BulletListModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late DateTime createdAt;

  @HiveField(3)
  late List<BulletItem> items;

  @HiveField(4)
  int? rangeStart;

  @HiveField(5)
  int? rangeEnd;

  BulletListModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.items,
    this.rangeStart,
    this.rangeEnd,
  });

  bool get isRanged => rangeStart != null && rangeEnd != null;
}
