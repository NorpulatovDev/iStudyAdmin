// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeacherModel _$TeacherModelFromJson(Map<String, dynamic> json) => TeacherModel(
      id: (json['id'] as num).toInt(),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      baseSalary: (json['baseSalary'] as num).toDouble(),
      paymentPercentage: (json['paymentPercentage'] as num).toDouble(),
      salaryType: json['salaryType'] as String,
      branchId: (json['branchId'] as num).toInt(),
      branchName: json['branchName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TeacherModelToJson(TeacherModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'baseSalary': instance.baseSalary,
      'paymentPercentage': instance.paymentPercentage,
      'salaryType': instance.salaryType,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'createdAt': instance.createdAt.toIso8601String(),
    };
