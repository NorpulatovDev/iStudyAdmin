// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => GroupModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      courseId: (json['courseId'] as num).toInt(),
      courseName: json['courseName'] as String,
      teacherId: (json['teacherId'] as num?)?.toInt(),
      teacherName: json['teacherName'] as String?,
      branchId: (json['branchId'] as num).toInt(),
      branchName: json['branchName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      students: (json['students'] as List<dynamic>?)
          ?.map((e) => StudentInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'courseId': instance.courseId,
      'courseName': instance.courseName,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'createdAt': instance.createdAt.toIso8601String(),
      'students': instance.students,
    };

StudentInfo _$StudentInfoFromJson(Map<String, dynamic> json) => StudentInfo(
      studentId: (json['studentId'] as num?)?.toInt(),
      studentName: json['studentName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      parentPhoneNumber: json['parentPhoneNumber'] as String?,
      totalPaidInMonth: (json['totalPaidInMonth'] as num?)?.toDouble(),
      coursePrice: (json['coursePrice'] as num?)?.toDouble(),
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble(),
      paymentStatus: json['paymentStatus'] as String?,
    );

Map<String, dynamic> _$StudentInfoToJson(StudentInfo instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'phoneNumber': instance.phoneNumber,
      'parentPhoneNumber': instance.parentPhoneNumber,
      'totalPaidInMonth': instance.totalPaidInMonth,
      'coursePrice': instance.coursePrice,
      'remainingAmount': instance.remainingAmount,
      'paymentStatus': instance.paymentStatus,
    };
