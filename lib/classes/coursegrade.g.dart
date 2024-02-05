// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coursegrade.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseGradeAdapter extends TypeAdapter<CourseGrade> {
  @override
  final int typeId = 1;

  @override
  CourseGrade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseGrade(
      course: fields[0] as String,
      grade: fields[1] as String,
      semester: fields[2] as int,
      dateString: fields[3] as String,
      ECTS: fields[4] as int,
      gradeFreqs: (fields[5] as List).cast<int>(),
      amount: fields[6] as int,
      gradeLabels: (fields[7] as List).cast<String>(),
      include: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CourseGrade obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.course)
      ..writeByte(1)
      ..write(obj.grade)
      ..writeByte(2)
      ..write(obj.semester)
      ..writeByte(3)
      ..write(obj.dateString)
      ..writeByte(4)
      ..write(obj.ECTS)
      ..writeByte(5)
      ..write(obj.gradeFreqs)
      ..writeByte(6)
      ..write(obj.amount)
      ..writeByte(7)
      ..write(obj.gradeLabels)
      ..writeByte(8)
      ..write(obj.include);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseGradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
