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