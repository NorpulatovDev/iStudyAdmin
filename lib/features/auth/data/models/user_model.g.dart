// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  userId: (json['userId'] as num).toInt(),
  username: json['username'] as String,
  role: json['role'] as String,
  branchId: (json['branchId'] as num?)?.toInt(),
  branchName: json['branchName'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'role': instance.role,
  'branchId': instance.branchId,
  'branchName': instance.branchName,
};
