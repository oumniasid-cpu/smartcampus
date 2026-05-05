<<<<<<< HEAD
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  registered,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? message;
  final bool emailVerified;

  const AuthState({
    this.status = AuthStatus.initial,
    this.message,
    this.emailVerified = false,
  });

  bool get isLoading => status == AuthStatus.loading;

  @override
  List<Object?> get props => [status, message, emailVerified];
}

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final user = await _authService.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthState(
        status: AuthStatus.authenticated,
        emailVerified: user.emailVerified,
      ));
    } catch (error) {
      String message;
      if (error is AuthFailure) {
        message = error.message;
      } else {
        message = 'An unexpected error occurred: $error';
      }
      emit(AuthState(status: AuthStatus.failure, message: message));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final user = await _authService.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(AuthState(
        status: AuthStatus.registered,
        message: 'Account created. Please verify your email when you can.',
        emailVerified: user.emailVerified,
      ));
    } catch (error) {
      String message;
      if (error is AuthFailure) {
        message = error.message;
      } else {
        message = 'Registration failed: $error';
      }
      emit(AuthState(status: AuthStatus.failure, message: message));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
=======
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';

// States
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
class AuthFailure extends AuthState { final String error; AuthFailure(this.error); }

// Events
abstract class AuthEvent {}
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  LoginSubmitted(this.email, this.password);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
  on<LoginSubmitted>((event, emit) async {
  emit(AuthLoading()); // This makes the spinner appear
  try {
    final result = await repository.signIn(event.email, event.password);
    if (result.user != null) {
      emit(AuthSuccess()); // This triggers the redirect
    }
  } catch (e) {
    emit(AuthFailure(e.toString()));
  }
});
  }
}
>>>>>>> 55257309b465a51d2e8d452d68d4bde3a6c546eb
