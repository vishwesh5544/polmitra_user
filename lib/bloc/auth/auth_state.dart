import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_app/models/user.dart';


abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final PolmitraUser user;

  AuthSuccess({required this.user});
}

class SignUpSuccess extends AuthState {
  final User user;
  final String role;

  SignUpSuccess({required this.user, required this.role});

}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure(this.error);
}
