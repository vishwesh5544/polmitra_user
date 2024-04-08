import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:user_app/bloc/auth/auth_bloc.dart';
import 'package:user_app/bloc/poll/poll_bloc.dart';
import 'package:user_app/bloc/polmitra_event/pevent_bloc.dart';
import 'package:user_app/screens/home_screen/home_screen.dart';
import 'package:user_app/screens/login/login_screen.dart';
import 'package:user_app/services/preferences_service.dart';
import 'package:user_app/services/user_service.dart';
import 'package:user_app/utils/city_state_provider.dart';
import 'package:user_app/utils/color_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PrefsService.init();
  // initialize the provider to trigger the data loading
  CityStateProvider();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserService>(create: (context) => UserService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) {
              final userService = Provider.of<UserService>(context, listen: false);
              return AuthBloc(FirebaseAuth.instance, FirebaseFirestore.instance, userService);
            },
            lazy: true,
          ),
          BlocProvider<PollBloc>(
            create: (context) {
              final userService = Provider.of<UserService>(context, listen: false);
              return PollBloc(FirebaseFirestore.instance, userService);
            },
            lazy: true,
          ),
          BlocProvider<EventBloc>(
            create: (context) {
              final userService = Provider.of<UserService>(context, listen: false);
              return EventBloc(FirebaseFirestore.instance, FirebaseStorage.instance, userService);
            },
            lazy: true,
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Polmitra App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(backgroundColor: ColorProvider.normalWhite),
          ),
          home: const LoginScreen(),
        ),
      ),
    );
  }
}
