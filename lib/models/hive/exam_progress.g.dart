part of 'exam_progress.dart';

class ExamProgressAdapter extends TypeAdapter<ExamProgress> {
  @override
  final int typeId = 3;

  @override
  ExamProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamProgress(
      examId: fields[0] as String,
      licenseTypeCode: fields[1] as String,
      isPassed: fields[2] as bool,
      totalCorrectQuizzes: fields[3] as int,
      totalIncorrectQuizzes: fields[4] as int,
      completedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ExamProgress obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.examId)
      ..writeByte(1)
      ..write(obj.licenseTypeCode)
      ..writeByte(2)
      ..write(obj.isPassed)
      ..writeByte(3)
      ..write(obj.totalCorrectQuizzes)
      ..writeByte(4)
      ..write(obj.totalIncorrectQuizzes)
      ..writeByte(5)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
} 