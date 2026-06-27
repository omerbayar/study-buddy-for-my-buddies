// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bullet_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BulletItemAdapter extends TypeAdapter<BulletItem> {
  @override
  final int typeId = 6;

  @override
  BulletItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BulletItem(
      id: fields[0] as String,
      label: fields[1] as String,
      done: fields[2] as bool,
      number: fields[3] as int?,
      note: fields[4] as String?,
      order: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BulletItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.done)
      ..writeByte(3)
      ..write(obj.number)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BulletItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
