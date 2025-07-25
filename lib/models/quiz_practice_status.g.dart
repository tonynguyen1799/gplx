// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_practice_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizPracticeStatusAdapter extends TypeAdapter<QuizPracticeStatus> {
  @override
  final int typeId = 2;

  @override
  QuizPracticeStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizPracticeStatus(
      practiced: fields[0] as bool,
      correct: fields[1] as bool,
      saved: fields[2] as bool,
      selectedIndex: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizPracticeStatus obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.practiced)
      ..writeByte(1)
      ..write(obj.correct)
      ..writeByte(2)
      ..write(obj.saved)
      ..writeByte(3)
      ..write(obj.selectedIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizPracticeStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
