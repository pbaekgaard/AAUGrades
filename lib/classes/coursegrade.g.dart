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
    );
  }

  @override
  void write(BinaryWriter writer, CourseGrade obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.course)
      ..writeByte(1)
      ..write(obj.grade);
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
