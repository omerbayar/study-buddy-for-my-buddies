// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bullet_list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BulletListModelAdapter extends TypeAdapter<BulletListModel> {
  @override
  final int typeId = 5;

  @override
  BulletListModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BulletListModel(
      id: fields[0] as String,
      name: fields[1] as String,
      createdAt: fields[2] as DateTime,
      items: (fields[3] as List).cast<BulletItem>(),
      rangeStart: fields[4] as int?,
      rangeEnd: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, BulletListModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.rangeStart)
      ..writeByte(5)
      ..write(obj.rangeEnd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BulletListModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
