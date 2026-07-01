// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LinkModelAdapter extends TypeAdapter<LinkModel> {
  @override
  final int typeId = 0;

  @override
  LinkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LinkModel(
      id: fields[0] as String,
      url: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      previewImageUrl: fields[4] as String?,
      faviconUrl: fields[5] as String?,
      domainName: fields[6] as String,
      categoryId: fields[7] as String?,
      isFavorite: fields[8] as bool,
      isLocked: fields[9] as bool,
      createdAt: fields[10] as DateTime,
      lastOpenedAt: fields[11] as DateTime,
      openCount: fields[12] as int,
      orderIndex: fields[13] == null ? 0 : fields[13] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LinkModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.previewImageUrl)
      ..writeByte(5)
      ..write(obj.faviconUrl)
      ..writeByte(6)
      ..write(obj.domainName)
      ..writeByte(7)
      ..write(obj.categoryId)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.isLocked)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.lastOpenedAt)
      ..writeByte(12)
      ..write(obj.openCount)
      ..writeByte(13)
      ..write(obj.orderIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
