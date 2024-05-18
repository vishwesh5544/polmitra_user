import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_app/bloc/auth/auth_event.dart';
import 'package:user_app/bloc/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/enums/user_enums.dart';
import 'package:user_app/extensions/string_extensions.dart';
import 'package:user_app/models/user.dart';
import 'package:user_app/services/user_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final UserService _userService;

  AuthBloc(this._firebaseAuth, this._firestore, this._userService) : super(AuthInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<LoginRequested>(_onLoginRequested);
  }

  FutureOr<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email.asPolmitraEmail,
        password: event.password,
      );

      final neta = event.netaId != null ? await _userService.getUserById(event.netaId!) : null;

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': event.name,
          'email': user.email,
          'role': event.role.toString(),
          'languagePreference': event.languagePreference.toString(),
          'netaId': event.netaId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'neta': neta?.toMap(),
          'isActive': event.role == UserRole.neta ? false : true,
        });

        emit(SignUpSuccess(user: user, role: event.role.toString()));
      } else {
        emit(AuthFailure('Failed to sign up'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  FutureOr<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email.asPolmitraEmail,
        password: event.password,
      );

      final user = userCredential.user;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final retrievedUser = PolmitraUser.fromDocument(docSnapshot);

        // if user is not active, return
        if (!retrievedUser.isActive) {
          emit(AuthFailure('User is not active'));
          return;
        }

        emit(AuthSuccess(user: retrievedUser));
      } else {
        emit(AuthFailure('Failed to login'));
        return;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(AuthFailure('User not found'));
        return;
      } else if (e.code == 'wrong-password') {
        emit(AuthFailure('Wrong password'));
        return;
      } else if(e.code == 'invalid-credential') {
        emit(AuthFailure('Invalid credentials provided'));
        return;
      } else if(e.code == 'invalid-email') {
        emit(AuthFailure('Invalid email. Only phone number is allowed'));
        return;
      }
      else {
        print("*** BLOC => ${e.toString()}");
        emit(AuthFailure(e.toString()));
        return;
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
      return;
    }
  }
}
