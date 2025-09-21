// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_calculation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalaryCalculationModel _$SalaryCalculationModelFromJson(
        Map<String, dynamic> json) =>
    SalaryCalculationModel(
      teacherId: (json['teacherId'] as num).toInt(),
      teacherName: json['teacherName'] as String,
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      baseSalary: (json['baseSalary'] as num).toDouble(),
      paymentBasedSalary: (json['paymentBasedSalary'] as num).toDouble(),
      totalSalary: (json['totalSalary'] as num).toDouble(),
      totalStudentPayments: (json['totalStudentPayments'] as num).toDouble(),
      totalStudents: (json['totalStudents'] as num).toInt(),
      alreadyPaid: (json['alreadyPaid'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      branchId: (json['branchId'] as num).toInt(),
      branchName: json['branchName'] as String,
      groups: (json['groups'] as List<dynamic>)
          .map((e) => GroupSalaryInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SalaryCalculationModelToJson(
        SalaryCalculationModel instance) =>
    <String, dynamic>{
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'year': instance.year,
      'month': instance.month,
      'baseSalary': instance.baseSalary,
      'paymentBasedSalary': instance.paymentBasedSalary,
      'totalSalary': instance.totalSalary,
      'totalStudentPayments': instance.totalStudentPayments,
      'totalStudents': instance.totalStudents,
      'alreadyPaid': instance.alreadyPaid,
      'remainingAmount': instance.remainingAmount,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'groups': instance.groups,
    };

GroupSalaryInfo _$GroupSalaryInfoFromJson(Map<String, dynamic> json) =>
    GroupSalaryInfo(
      groupId: (json['groupId'] as num).toInt(),
      groupName: json['groupName'] as String,
      courseName: json['courseName'] as String,
      studentCount: (json['studentCount'] as num).toInt(),
      totalGroupPayments: (json['totalGroupPayments'] as num).toDouble(),
      totalStudentsInGroup: (json['totalStudentsInGroup'] as num).toInt(),
      coursePrice: (json['coursePrice'] as num).toDouble(),
    );

Map<String, dynamic> _$GroupSalaryInfoToJson(GroupSalaryInfo instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'courseName': instance.courseName,
      'studentCount': instance.studentCount,
      'totalGroupPayments': instance.totalGroupPayments,
      'totalStudentsInGroup': instance.totalStudentsInGroup,
      'coursePrice': instance.coursePrice,
    };

TeacherSalaryPaymentModel _$TeacherSalaryPaymentModelFromJson(
        Map<String, dynamic> json) =>
    TeacherSalaryPaymentModel(
      id: (json['id'] as num).toInt(),
      teacherId: (json['teacherId'] as num).toInt(),
      teacherName: json['teacherName'] as String,
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      branchId: (json['branchId'] as num).toInt(),
      branchName: json['branchName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TeacherSalaryPaymentModelToJson(
        TeacherSalaryPaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'year': instance.year,
      'month': instance.month,
      'amount': instance.amount,
      'description': instance.description,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'createdAt': instance.createdAt.toIso8601String(),
    };

TeacherSalaryHistoryModel _$TeacherSalaryHistoryModelFromJson(
        Map<String, dynamic> json) =>
    TeacherSalaryHistoryModel(
      teacherId: (json['teacherId'] as num).toInt(),
      teacherName: json['teacherName'] as String,
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      totalSalary: (json['totalSalary'] as num).toDouble(),
      totalPaid: (json['totalPaid'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      isFullyPaid: json['isFullyPaid'] as bool,
      lastPaymentDate: json['lastPaymentDate'] == null
          ? null
          : DateTime.parse(json['lastPaymentDate'] as String),
      paymentCount: (json['paymentCount'] as num).toInt(),
    );

Map<String, dynamic> _$TeacherSalaryHistoryModelToJson(
        TeacherSalaryHistoryModel instance) =>
    <String, dynamic>{
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'year': instance.year,
      'month': instance.month,
      'totalSalary': instance.totalSalary,
      'totalPaid': instance.totalPaid,
      'remainingAmount': instance.remainingAmount,
      'isFullyPaid': instance.isFullyPaid,
      'lastPaymentDate': instance.lastPaymentDate?.toIso8601String(),
      'paymentCount': instance.paymentCount,
    };
