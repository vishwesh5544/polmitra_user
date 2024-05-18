// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_app/bloc/auth/auth_bloc.dart';
import 'package:user_app/bloc/auth/auth_event.dart';
import 'package:user_app/bloc/auth/auth_state.dart';
import 'package:user_app/screens/home_screen/home_screen.dart';
import 'package:user_app/screens/signup/signup.dart';
import 'package:user_app/services/preferences_service.dart';
import 'package:user_app/utils/border_provider.dart';
import 'package:user_app/utils/color_provider.dart';
import 'package:user_app/utils/text_builder.dart';
import 'package:user_app/utils/text_utility.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';
  final double _formLabelFontSize = 16.0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? lastFailureSnackBarTime;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthSuccess || current is AuthFailure,
      listener: (context, state) async {
        if (state is AuthSuccess) {
          await PrefsService.setUserId(state.user.uid);
          await PrefsService.setLoginStatus(true);
          await PrefsService.setRole(state.user.role);
          await PrefsService.setNetaId(state.user.netaId);
          await PrefsService.saveUser(state.user);

          _navigateToHomeScreen();
        } else if (state is AuthFailure) {
          // debounce snackbar to avoid multiple snackbar
          final currentTime = DateTime.now();
          if (lastFailureSnackBarTime == null ||
              currentTime.difference(lastFailureSnackBarTime!) > Duration(seconds: 3)) {
            lastFailureSnackBarTime = currentTime;

            print("Error: ${state.error}");

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(state.error),
                ),
              );
          }
        }
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // FlutterLogo(size: 100),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('assets/polmitra.jpg'),
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextBuilder.getTextStyle(fontSize: _formLabelFontSize),
                      border: BorderProvider.createBorder(),
                      enabledBorder: BorderProvider.createBorder(),
                      focusedBorder: BorderProvider.createBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                    onSaved: (value) => _email = value!,
                    controller: _emailController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextBuilder.getTextStyle(fontSize: _formLabelFontSize),
                      border: BorderProvider.createBorder(),
                      enabledBorder: BorderProvider.createBorder(),
                      focusedBorder: BorderProvider.createBorder(),
                    ),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
                    onSaved: (value) => _password = value!,
                    controller: _passwordController,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(10),
                      fixedSize: Size(150, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      backgroundColor: ColorProvider.vibrantSaffron,
                    ),
                    child: TextBuilder.getText(
                        text: "Login", color: ColorProvider.normalWhite, fontSize: 18, fontWeight: FontWeight.bold),
                    onPressed: () async {
                      // if (_formKey.currentState!.validate()) {
                      //   _formKey.currentState!.save();
                      //   // Perform login action
                      //   print('Email: $_email, Password: $_password');
                      // }
                      final bloc = context.read<AuthBloc>();
                      await PrefsService.clear();

                      bloc.add(LoginRequested(email: _emailController.text, password: _passwordController.text));
                      // _navigateToHomeScreen();
                    },
                  ),
                  SizedBox(height: 20),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'Don\'t have an account? ',
                        style: TextBuilder.getTextStyle(fontSize: 16, color: ColorProvider.normalBlack),
                        recognizer: TapGestureRecognizer()..onTap = _navigateToSignUpScreen,
                      ),
                      // WidgetSpan(child: SizedBox(width: 2)),
                      TextSpan(
                        text: 'Register',
                        style: TextBuilder.getTextStyle(fontSize: 16, color: ColorProvider.normalBlack),
                        recognizer: TapGestureRecognizer()..onTap = _navigateToSignUpScreen,
                      ),
                    ]),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSignUpScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
  }

  void _navigateToHomeScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }
}
