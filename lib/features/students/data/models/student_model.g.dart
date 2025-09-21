// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentModel _$StudentModelFromJson(Map<String, dynamic> json) => StudentModel(
      id: (json['id'] as num).toInt(),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      parentPhoneNumber: json['parentPhoneNumber'] as String?,
      branchId: (json['branchId'] as num).toInt(),
      branchName: json['branchName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      hasPaidInMonth: json['hasPaidInMonth'] as bool?,
      totalPaidInMonth: (json['totalPaidInMonth'] as num?)?.toDouble(),
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble(),
      paymentStatus: json['paymentStatus'] as String?,
      lastPaymentDate: json['lastPaymentDate'] == null
          ? null
          : DateTime.parse(json['lastPaymentDate'] as String),
      groupIds: (json['groupIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$StudentModelToJson(StudentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'parentPhoneNumber': instance.parentPhoneNumber,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'createdAt': instance.createdAt.toIso8601String(),
      'hasPaidInMonth': instance.hasPaidInMonth,
      'totalPaidInMonth': instance.totalPaidInMonth,
      'remainingAmount': instance.remainingAmount,
      'paymentStatus': instance.paymentStatus,
      'lastPaymentDate': instance.lastPaymentDate?.toIso8601String(),
      'groupIds': instance.groupIds,
    };

CreateStudentRequest _$CreateStudentRequestFromJson(
        Map<String, dynamic> json) =>
    CreateStudentRequest(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      parentPhoneNumber: json['parentPhoneNumber'] as String,
      branchId: (json['branchId'] as num).toInt(),
      groupIds: (json['groupIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$CreateStudentRequestToJson(
        CreateStudentRequest instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'parentPhoneNumber': instance.parentPhoneNumber,
      'branchId': instance.branchId,
      'groupIds': instance.groupIds,
    };
