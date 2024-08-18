import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:user_app/bloc/auth/auth_bloc.dart';
import 'package:user_app/bloc/poll/poll_bloc.dart';
import 'package:user_app/bloc/polmitra_event/pevent_bloc.dart';
import 'package:user_app/screens/login/login_screen.dart';
import 'package:user_app/services/event_service.dart';
import 'package:user_app/services/neta_rating_service.dart';
import 'package:user_app/services/poll_event.dart';
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
  final firestore = FirebaseFirestore.instance;
  final userService = UserService(firestore);
  runApp(MyApp(
    userService: userService,
    firestore: firestore,
  ));
}

class MyApp extends StatelessWidget {
  final UserService userService;
  final FirebaseFirestore firestore;

  const MyApp({required this.userService, required this.firestore, super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseauth = FirebaseAuth.instance;
    final firebaseStorage = FirebaseStorage.instance;

    return MultiProvider(
      providers: [
        Provider<UserService>.value(value: userService),
        Provider<PollService>(create: (context) => PollService(firestore)),
        Provider<EventService>(create: (context) => EventService(firestore, firebaseStorage)),
        Provider<NetaRatingService>(create: (context) => NetaRatingService(firestore)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) {
              final userService = Provider.of<UserService>(context, listen: false);
              return AuthBloc(firebaseauth, firestore, userService);
            },
            lazy: true,
          ),
          BlocProvider<PollBloc>(
            create: (context) {
              final userService = Provider.of<UserService>(context, listen: false);
              return PollBloc(firestore, userService);
            },
            lazy: true,
          ),
          BlocProvider<EventBloc>(
            create: (context) {
              final userService = Provider.of<UserService>(context, listen: false);
              return EventBloc(firestore, firebaseStorage, userService);
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
