// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseModel _$CourseModelFromJson(Map<String, dynamic> json) => CourseModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  durationMonths: (json['durationMonths'] as num?)?.toInt(),
  branchId: (json['branchId'] as num).toInt(),
  branchName: json['branchName'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  groups: (json['groups'] as List<dynamic>?)
      ?.map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CourseModelToJson(CourseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'durationMonths': instance.durationMonths,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'createdAt': instance.createdAt.toIso8601String(),
      'groups': instance.groups,
    };
