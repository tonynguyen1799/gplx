part of 'quiz_progress.dart';

class QuizProgressAdapter extends TypeAdapter<QuizProgress> {
  @override
  final int typeId = 2;

  @override
  QuizProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizProgress(
      isPracticed: fields[0] as bool,
      isCorrect: fields[1] as bool,
      isSaved: fields[2] as bool,
      selectedIdx: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizProgress obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.isPracticed)
      ..writeByte(1)
      ..write(obj.isCorrect)
      ..writeByte(2)
      ..write(obj.isSaved)
      ..writeByte(3)
      ..write(obj.selectedIdx);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
} 