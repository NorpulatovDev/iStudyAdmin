// lib/features/teacher_salaries/data/models/salary_calculation_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'salary_calculation_model.g.dart';

@JsonSerializable()
class SalaryCalculationModel extends Equatable {
  final int teacherId;
  final String teacherName;
  final int year;
  final int month;
  final double baseSalary;
  final double paymentBasedSalary;
  final double totalSalary;
  final double totalStudentPayments;
  final int totalStudents;
  final double alreadyPaid;
  final double remainingAmount;
  final int branchId;
  final String branchName;
  final List<GroupSalaryInfo> groups;

  const SalaryCalculationModel({
    required this.teacherId,
    required this.teacherName,
    required this.year,
    required this.month,
    required this.baseSalary,
    required this.paymentBasedSalary,
    required this.totalSalary,
    required this.totalStudentPayments,
    required this.totalStudents,
    required this.alreadyPaid,
    required this.remainingAmount,
    required this.branchId,
    required this.branchName,
    required this.groups,
  });

  factory SalaryCalculationModel.fromJson(Map<String, dynamic> json) =>
      _$SalaryCalculationModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalaryCalculationModelToJson(this);

  @override
  List<Object?> get props => [
        teacherId,
        teacherName,
        year,
        month,
        baseSalary,
        paymentBasedSalary,
        totalSalary,
        totalStudentPayments,
        totalStudents,
        alreadyPaid,
        remainingAmount,
        branchId,
        branchName,
        groups,
      ];
}

@JsonSerializable()
class GroupSalaryInfo extends Equatable {
  final int groupId;
  final String groupName;
  final String courseName;
  final int studentCount;
  final double totalGroupPayments;
  final int totalStudentsInGroup;
  final double coursePrice;

  const GroupSalaryInfo({
    required this.groupId,
    required this.groupName,
    required this.courseName,
    required this.studentCount,
    required this.totalGroupPayments,
    required this.totalStudentsInGroup,
    required this.coursePrice,
  });

  factory GroupSalaryInfo.fromJson(Map<String, dynamic> json) =>
      _$GroupSalaryInfoFromJson(json);

  Map<String, dynamic> toJson() => _$GroupSalaryInfoToJson(this);

  @override
  List<Object?> get props => [
        groupId,
        groupName,
        courseName,
        studentCount,
        totalGroupPayments,
        totalStudentsInGroup,
        coursePrice,
      ];
}

@JsonSerializable()
class TeacherSalaryPaymentModel extends Equatable {
  final int id;
  final int teacherId;
  final String teacherName;
  final int year;
  final int month;
  final double amount;
  final String? description;
  final int branchId;
  final String branchName;
  final DateTime createdAt;

  const TeacherSalaryPaymentModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.year,
    required this.month,
    required this.amount,
    this.description,
    required this.branchId,
    required this.branchName,
    required this.createdAt,
  });

  factory TeacherSalaryPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherSalaryPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherSalaryPaymentModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        teacherId,
        teacherName,
        year,
        month,
        amount,
        description,
        branchId,
        branchName,
        createdAt,
      ];
}

@JsonSerializable()
class TeacherSalaryHistoryModel extends Equatable {
  final int teacherId;
  final String teacherName;
  final int year;
  final int month;
  final double totalSalary;
  final double totalPaid;
  final double remainingAmount;
  final bool isFullyPaid;
  final DateTime? lastPaymentDate;
  final int paymentCount;

  const TeacherSalaryHistoryModel({
    required this.teacherId,
    required this.teacherName,
    required this.year,
    required this.month,
    required this.totalSalary,
    required this.totalPaid,
    required this.remainingAmount,
    required this.isFullyPaid,
    this.lastPaymentDate,
    required this.paymentCount,
  });

  factory TeacherSalaryHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherSalaryHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherSalaryHistoryModelToJson(this);

  @override
  List<Object?> get props => [
        teacherId,
        teacherName,
        year,
        month,
        totalSalary,
        totalPaid,
        remainingAmount,
        isFullyPaid,
        lastPaymentDate,
        paymentCount,
      ];
}