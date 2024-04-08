import 'package:flutter/material.dart';

import '../../models/event.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({required this.event, super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late final Event _event;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      setState(() {
        _event = widget.event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // adding comment for testing workflow
    return const Placeholder();
  }
}
