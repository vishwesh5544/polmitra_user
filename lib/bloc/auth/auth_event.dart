import 'package:user_app/enums/user_enums.dart';

abstract class AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? netaId;
  final UserRole role;
  final LanguagePreference languagePreference;
  final String name;

  SignUpRequested({
    required this.email,
    required this.role,
    required this.password,
    this.languagePreference = LanguagePreference.english,
    this.netaId,
    required this.name
  });
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({
    required this.email,
    required this.password,
  });
}
