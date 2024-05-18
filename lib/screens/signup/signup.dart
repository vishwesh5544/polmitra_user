import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:user_app/bloc/auth/auth_bloc.dart';
import 'package:user_app/bloc/auth/auth_event.dart';
import 'package:user_app/bloc/auth/auth_state.dart';
import 'package:user_app/components/common_button.dart';
import 'package:user_app/enums/user_enums.dart';
import 'package:user_app/models/user.dart';
import 'package:user_app/screens/login/login_screen.dart';
import 'package:user_app/services/user_service.dart';
import 'package:user_app/utils/border_provider.dart';
import 'package:user_app/utils/color_provider.dart';
import 'package:user_app/utils/text_builder.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isKaryakarta = false;
  late final UserService _userService;
  List<PolmitraUser> _netas = [];
  List<UserRole> _roles = [];


  @override
  void initState() {
    super.initState();
    _userService = Provider.of<UserService>(context, listen: false);
    _fetchNetas();
    _initRoles();
  }

  void _initRoles() {
    setState(() {
      _roles = UserRole.values.where((value) => value != UserRole.superadmin).toList();
    });
  }

  Future<void> _fetchNetas() async {
    try {
      final netas = await _userService.getUsersByRole(UserRole.neta);
      setState(() {
        _netas = netas;
      });
    } catch (e) {
      print("Error fetching netas: $e");
    }
  }

  void _onRoleChanged(UserRole? value) {
    setState(() {
      isKaryakarta = value == UserRole.karyakarta;
    });

    if (isKaryakarta) {
      _formKey.currentState?.fields['selectedNeta']?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign Up'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FormBuilderTextField(
                  name: 'name',
                  decoration: InputDecoration(
                    labelText: 'Name',
                    enabledBorder: BorderProvider.createUnderlineBorder(),
                    focusedBorder: BorderProvider.createUnderlineBorder(),
                    floatingLabelStyle: TextBuilder.getTextStyle(color: ColorProvider.vibrantSaffron, fontSize: 15.0),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                FormBuilderTextField(
                  name: 'email',
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    enabledBorder: BorderProvider.createUnderlineBorder(),
                    focusedBorder: BorderProvider.createUnderlineBorder(),
                    floatingLabelStyle: TextBuilder.getTextStyle(color: ColorProvider.vibrantSaffron, fontSize: 15.0),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.integer(),
                  ]),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                FormBuilderTextField(
                  name: 'password',
                  decoration: InputDecoration(
                    labelText: 'Password',
                    enabledBorder: BorderProvider.createUnderlineBorder(),
                    focusedBorder: BorderProvider.createUnderlineBorder(),
                    floatingLabelStyle: TextBuilder.getTextStyle(color: ColorProvider.vibrantSaffron, fontSize: 15.0),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(6),
                  ]),
                  obscureText: true,
                ),
                FormBuilderDropdown(
                  name: 'role',
                  decoration: InputDecoration(
                    labelText: 'Select Role',
                    enabledBorder: BorderProvider.createUnderlineBorder(),
                    focusedBorder: BorderProvider.createUnderlineBorder(),
                    floatingLabelStyle: TextBuilder.getTextStyle(color: ColorProvider.vibrantSaffron, fontSize: 15.0),
                  ),
                  onChanged: _onRoleChanged,
                  validator: FormBuilderValidators.required(),
                  items: _roles.map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.toString().split('.').last),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                Visibility(
                  visible: isKaryakarta, // Show this dropdown only if 'Karyakarta' is selected
                  child: FormBuilderDropdown(
                      name: 'selectedNeta',
                      decoration: InputDecoration(
                        labelText: 'Select Neta',
                        enabledBorder: BorderProvider.createUnderlineBorder(),
                        focusedBorder: BorderProvider.createUnderlineBorder(),
                        floatingLabelStyle:
                            TextBuilder.getTextStyle(color: ColorProvider.vibrantSaffron, fontSize: 15.0),
                      ),
                      validator: (value) {
                        if (isKaryakarta && value == null) {
                          return 'Please select Karyakarta type';
                        }
                        return null;
                      },
                      items: _netas.map((neta) => DropdownMenuItem(
                                value: neta.uid,
                                child: Text(neta.email ?? ''),
                              ))
                          .toList()),
                ),
                const SizedBox(height: 20),
                CommonButton(
                    buttonText: "Sign up",
                    onClick: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        final values = _formKey.currentState!.value;
                        context.read<AuthBloc>().add(SignUpRequested(
                              email: values['email'],
                              password: values['password'],
                              role: values['role'],
                              netaId: values['selectedNeta'],
                              name: values['name'],
                            ));
                      }
                    },
                    buttonStyle: ElevatedButton.styleFrom(
                      backgroundColor: ColorProvider.vibrantSaffron,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
