import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:user_app/enums/user_enums.dart';
import 'package:user_app/models/user.dart';
import 'package:user_app/screens/login/login_screen.dart';
import 'package:user_app/services/preferences_service.dart';
import 'package:user_app/services/user_service.dart';
import 'package:user_app/utils/border_provider.dart';
import 'package:user_app/utils/color_provider.dart';
import 'package:user_app/utils/text_builder.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final UserService _userService;
  PolmitraUser? _user;
  PolmitraUser? _selectedNeta;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _netaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userService = context.read<UserService>();
    _fetchUser();
  }

  void _fetchUser() async {
    var user = await PrefsService.getUser();
    setState(() {
      _user = user;
    });
  }

  Future<List<PolmitraUser>> _getNetas() async {
    return await _userService.getUsersByRole(UserRole.neta);
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Account'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTileTheme(
                textColor: Colors.black,
                iconColor: Colors.black,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Edit Profile'),
                      leading: const Icon(Icons.edit),
                      onTap: () {
                        showAdaptiveDialog(
                          context: context,
                          builder: (context) {
                            /// Edit profile dialog

                            print("current user: ${_user?.toMap()}");

                            return AlertDialog(
                              title: const Text('Edit Profile'),
                              content: FutureBuilder<List<PolmitraUser>>(
                                builder: (context, snapshot) {
                                  /// Handle future builder states
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  /// Handle future builder data
                                  final netas = snapshot.data as List<PolmitraUser>;
                                  print('current user: ${_user?.toMap()}');
                                  return FormBuilder(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        /// current neta
                                        RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                            text: 'Current Neta: ',
                                            style: TextBuilder.getTextStyle(
                                                fontSize: 15, color: ColorProvider.vibrantSaffron),
                                          ),
                                          TextSpan(
                                            text: _user?.neta?.name,
                                            style: TextBuilder.getTextStyle(fontSize: 15),
                                          ),
                                        ])),
                                        const SizedBox(height: 10.0),

                                        /// full name text field
                                        FormBuilderTextField(
                                          name: 'fullName',
                                          controller: _fullNameController,
                                          decoration: InputDecoration(
                                            labelText: 'Full name',
                                            enabledBorder: BorderProvider.createUnderlineBorder(),
                                            focusedBorder: BorderProvider.createUnderlineBorder(),
                                            floatingLabelStyle: TextBuilder.getTextStyle(
                                                color: ColorProvider.vibrantSaffron, fontSize: 15.0),
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),

                                        /// select neta dropdown
                                        FormBuilderDropdown(
                                            name: 'selectedNeta',
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedNeta = value as PolmitraUser;
                                              });
                                            },
                                            initialValue: _user?.neta,
                                            decoration: InputDecoration(
                                              labelText: 'Select neta',
                                              enabledBorder: BorderProvider.createUnderlineBorder(),
                                              focusedBorder: BorderProvider.createUnderlineBorder(),
                                              floatingLabelStyle: TextBuilder.getTextStyle(
                                                  color: ColorProvider.vibrantSaffron, fontSize: 15.0),
                                            ),
                                            items: netas
                                                .map((neta) => DropdownMenuItem(value: neta, child: Text(neta.name)))
                                                .toList()),
                                      ],
                                    ),
                                  );
                                },
                                future: _getNetas(),
                              ),
                              actions: [
                                /// close button
                                TextButton(
                                  onPressed: () {
                                    _closeDialog();
                                  },
                                  child: const Text('Cancel'),
                                ),

                                /// save action button
                                TextButton(
                                  onPressed: () async {
                                    var updatedUser = _user?.copyWith(
                                      neta: _selectedNeta,
                                      name: _fullNameController.text,
                                      netaId: _selectedNeta?.uid,
                                    );

                                    if (updatedUser != null) {
                                      await _userService.updateUser(updatedUser);
                                      await PrefsService.saveUser(updatedUser);
                                    }

                                    setState(() {
                                      _user = updatedUser;
                                    });

                                    _closeDialog();
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                        // Handle edit profile action (navigation, etc.)
                      },
                    ),
                    ListTile(
                      title: const Text('Change Password'),
                      leading: const Icon(Icons.lock),
                      onTap: () {
                        // Handle change password action (navigation, etc.)
                      },
                    ),
                    ListTile(
                      title: const Text('Logout'),
                      leading: const Icon(Icons.exit_to_app),
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        // Logout logic
                        await FirebaseAuth.instance.signOut();
                        await PrefsService.clear();
                        // Navigate back to login screen or main screen
                        navigator.pushReplacement(MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
