// ignore_for_file: public_member_api_docs, sort_constructors_first


import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest extends Equatable {
  final String username;
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json)=> _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson()=> _$LoginRequestToJson(this);

  @override
  List<Object?> get props => [username, password];
}
