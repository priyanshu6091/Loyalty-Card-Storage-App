// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoyaltyCardAdapter extends TypeAdapter<LoyaltyCard> {
  @override
  final int typeId = 0;

  @override
  LoyaltyCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoyaltyCard(
      id: fields[0] as String?,
      name: fields[1] as String,
      cardNumber: fields[2] as String,
      barcodeType: fields[3] as String?,
      expiryDate: fields[4] as DateTime?,
      logoImagePath: fields[5] as String?,
      colorValue: fields[6] as int,
      notes: fields[7] as String?,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
      isSynced: fields[10] as bool,
      isDeleted: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LoyaltyCard obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.cardNumber)
      ..writeByte(3)
      ..write(obj.barcodeType)
      ..writeByte(4)
      ..write(obj.expiryDate)
      ..writeByte(5)
      ..write(obj.logoImagePath)
      ..writeByte(6)
      ..write(obj.colorValue)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.isSynced)
      ..writeByte(11)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoyaltyCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
