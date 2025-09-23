import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<bool>? _authStateSubscription;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthTokenExpired>(_onTokenExpired);
    on<AuthSessionValidationRequested>(_onSessionValidationRequested);

    // Listen to auth state changes from repository
    _authStateSubscription = _authRepository.authStateStream.listen((isAuthenticated) {
      if (!isAuthenticated && state is AuthAuthenticated) {
        // Auto logout when token refresh fails
        add(AuthTokenExpired());
      }
    });
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.login(event.username, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      print('Login error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Show loading only if not already unauthenticated
    if (state is! AuthUnauthenticated) {
      emit(AuthLoading());
    }

    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Always logout even if API fails
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Check if tokens exist
      if (!await _authRepository.isTokenValid()) {
        emit(AuthUnauthenticated());
        return;
      }

      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
        
        // Optionally validate session with server
        if (event.validateWithServer) {
          add(AuthSessionValidationRequested());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('Auth check error: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onTokenExpired(
    AuthTokenExpired event,
    Emitter<AuthState> emit,
  ) async {
    // Don't show loading for auto-logout
    emit(AuthUnauthenticated());
  }

  Future<void> _onSessionValidationRequested(
    AuthSessionValidationRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Only validate if currently authenticated
    if (state is! AuthAuthenticated) return;

    try {
      final isValid = await _authRepository.validateCurrentSession();
      if (!isValid) {
        // Session invalid, trigger logout
        add(AuthTokenExpired());
      }
    } catch (e) {
      // If validation fails, assume session is invalid
      print('Session validation failed: $e');
      add(AuthTokenExpired());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    _authRepository.dispose();
    return super.close();
  }
}