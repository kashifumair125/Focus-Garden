// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusSessionAdapter extends TypeAdapter<FocusSession> {
  @override
  final int typeId = 0;

  @override
  FocusSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusSession(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime,
      durationMinutes: fields[2] as int,
      actualMinutes: fields[3] as int,
      completed: fields[4] as bool,
      plantUnlocked: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FocusSession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj.durationMinutes)
      ..writeByte(3)
      ..write(obj.actualMinutes)
      ..writeByte(4)
      ..write(obj.completed)
      ..writeByte(5)
      ..write(obj.plantUnlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
