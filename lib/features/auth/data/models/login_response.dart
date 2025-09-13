// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';
import 'package:istudyadmin/features/auth/data/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int userId;
  final String username;
  final String role;
  final int? branchId;
  final String? branchName;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.userId,
    required this.username,
    required this.role,
    this.branchId,
    this.branchName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  UserModel toUserModel() {
    return UserModel(
      userId: userId,
      username: username,
      role: role,
      branchId: branchId,
      branchName: branchName,
    );
  }

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    tokenType,
    userId,
    username,
    role,
    branchId,
    branchName,
  ];
}
