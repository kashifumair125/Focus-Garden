// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantAdapter extends TypeAdapter<Plant> {
  @override
  final int typeId = 1;

  @override
  Plant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plant(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      imagePath: fields[3] as String,
      unlockedAt: fields[4] as DateTime,
      requiredMinutes: fields[5] as int,
      rarity: fields[6] as PlantRarity,
      animationPath: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Plant obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.unlockedAt)
      ..writeByte(5)
      ..write(obj.requiredMinutes)
      ..writeByte(6)
      ..write(obj.rarity)
      ..writeByte(7)
      ..write(obj.animationPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlantRarityAdapter extends TypeAdapter<PlantRarity> {
  @override
  final int typeId = 2;

  @override
  PlantRarity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlantRarity.common;
      case 1:
        return PlantRarity.uncommon;
      case 2:
        return PlantRarity.rare;
      case 3:
        return PlantRarity.epic;
      case 4:
        return PlantRarity.legendary;
      default:
        return PlantRarity.common;
    }
  }

  @override
  void write(BinaryWriter writer, PlantRarity obj) {
    switch (obj) {
      case PlantRarity.common:
        writer.writeByte(0);
        break;
      case PlantRarity.uncommon:
        writer.writeByte(1);
        break;
      case PlantRarity.rare:
        writer.writeByte(2);
        break;
      case PlantRarity.epic:
        writer.writeByte(3);
        break;
      case PlantRarity.legendary:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantRarityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
