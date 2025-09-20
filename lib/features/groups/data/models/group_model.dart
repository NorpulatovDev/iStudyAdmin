// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:istudyadmin/features/students/data/models/student_model.dart';

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
  final String startTime;
  final String endTime;
  final List<String> daysOfWeek;
  final List<StudentInfo>? studentPayments;

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
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    this.studentPayments,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);

  int get studentCount => studentPayments?.length ?? 0;

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
        startTime,
        endTime,
        daysOfWeek,
        studentPayments,
      ];
}

@JsonSerializable()
class StudentInfo extends Equatable {
  final int? studentId;
  final String? studentName;
  final String? phoneNumber;
  final String? parentPhoneNumber;
  final double? totalPaidInMonth;
  final double? coursePrice;
  final double? remainingAmount;
  final String? paymentStatus;

  const StudentInfo({
    this.studentId,
    this.studentName,
    this.phoneNumber,
    this.parentPhoneNumber,
    this.totalPaidInMonth,
    this.coursePrice,
    this.remainingAmount,
    this.paymentStatus,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) =>
      _$StudentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$StudentInfoToJson(this);

  @override
  List<Object?> get props => [
    studentId,
    studentName,
    phoneNumber,
    parentPhoneNumber,
    totalPaidInMonth,
    coursePrice,
    remainingAmount,
    paymentStatus,
  ];
}
