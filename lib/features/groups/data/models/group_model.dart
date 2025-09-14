// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';
import 'package:istudyadmin/features/students/data/models/student_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'group_model.g.dart';

@JsonSerializable()
class GroupModel extends Equatable {
  final int id;
  final String name;
  final int courseId;
  final String courseName;
  final int? teacherId;
  final String? teacherName;
  final int branchId;
  final String branchName;
  final DateTime createdAt;
  final List<StudentModel>? students;

  const GroupModel({
    required this.id,
    required this.name,
    required this.courseId,
    required this.courseName,
    this.teacherId,
    this.teacherName,
    required this.branchId,
    required this.branchName,
    required this.createdAt,
    this.students,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);

  int get studentCount => students?.length ?? 0;

  @override
  List<Object?> get props => [
        id,
        name,
        courseId,
        courseName,
        teacherId,
        teacherName,
        branchId,
        branchName,
        createdAt,
        students,
      ];
}