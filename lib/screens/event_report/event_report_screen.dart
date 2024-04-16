import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/event.dart';
import 'package:user_app/models/user.dart';
import 'package:user_app/services/event_service.dart';
import 'package:user_app/services/preferences_service.dart';
import 'package:user_app/services/user_service.dart';
import 'package:user_app/utils/color_provider.dart';

class EventReportScreen extends StatefulWidget {
  const EventReportScreen({super.key});

  @override
  State<EventReportScreen> createState() => _EventReportScreenState();
}

class _EventReportScreenState extends State<EventReportScreen> {
  late final UserService _userService;
  late final EventService _eventService;
  List<PolmitraUser> karyakartaList = [];
  List<Event> eventList = [];
  PolmitraUser? user;

  @override
  void initState() {
    super.initState();
    _userService = Provider.of<UserService>(context, listen: false);
    _eventService = Provider.of<EventService>(context, listen: false);

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      initialize();
    });
  }

  Future<void> initialize() async {
    await _fetchUserId();
    await _fetchKaryakartas();
    await _fetchEvents();
  }

  Future<void> _fetchUserId() async {
    var fetched = await PrefsService.getUser();
    setState(() {
      user = fetched;
    });
  }

  Future<void> _fetchKaryakartas() async {
    if (user == null) {
      return;
    }
    final karyakartas = await _userService.getKaryakartasByNetaId(user!.uid);
    setState(() {
      karyakartaList = karyakartas;
    });
  }

  Future<void> _fetchEvents() async {
    if (user == null) {
      return;
    }
    final events = await _eventService.getEventsByNetaId(user!.uid);
    setState(() {
      eventList = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorProvider.deepSaffron,
          title: const InkWell(
            child: Text('Reports'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: initialize,
            ),
          ],
        ),
        body: const Center(
          child: Text('Event Report Screen'),
        ),
      ),
    );
  }
}
