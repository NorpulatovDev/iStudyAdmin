part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {
  final bool validateWithServer;

  const AuthCheckRequested({this.validateWithServer = false});

  @override
  List<Object> get props => [validateWithServer];
}

class AuthTokenExpired extends AuthEvent {}

class AuthSessionValidationRequested extends AuthEvent {}