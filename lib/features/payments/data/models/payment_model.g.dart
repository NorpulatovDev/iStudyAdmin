// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  id: (json['id'] as num).toInt(),
  studentId: (json['studentId'] as num).toInt(),
  studentName: json['studentName'] as String,
  courseId: (json['courseId'] as num).toInt(),
  courseName: json['courseName'] as String,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String?,
  status: json['status'] as String,
  branchId: (json['branchId'] as num).toInt(),
  branchName: json['branchName'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'courseId': instance.courseId,
      'courseName': instance.courseName,
      'amount': instance.amount,
      'description': instance.description,
      'status': instance.status,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'createdAt': instance.createdAt.toIso8601String(),
    };
