// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final int userId;
  final String username;
  final String role;
  final int? branchId;
  final String? branchName;

  const UserModel({
    required this.userId,
    required this.username,
    required this.role,
    this.branchId,
    this.branchName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson()=>_$UserModelToJson(this);

  @override
  List<Object?> get props => [userId, username, role, branchId, branchName];
}


