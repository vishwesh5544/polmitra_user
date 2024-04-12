import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/services/user_service.dart';

class EventReportScreen extends StatefulWidget {
  const EventReportScreen({super.key});

  @override
  State<EventReportScreen> createState() => _EventReportScreenState();
}

class _EventReportScreenState extends State<EventReportScreen> {
  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = Provider.of<UserService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: const Scaffold(
        body: Center(
          child: Text('Event Report Screen'),
        ),
      ),
    );
  }
}
