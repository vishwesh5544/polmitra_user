import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/event.dart';
import 'package:user_app/models/indian_city.dart';
import 'package:user_app/models/indian_state.dart';
import 'package:user_app/models/user.dart';
import 'package:user_app/screens/event_report/by_date.dart';
import 'package:user_app/screens/event_report/by_location.dart';
import 'package:user_app/screens/event_report/by_status.dart';
import 'package:user_app/screens/event_report/by_user.dart';
import 'package:user_app/screens/event_report/event_app_bar.dart';
import 'package:user_app/services/event_service.dart';
import 'package:user_app/services/preferences_service.dart';
import 'package:user_app/services/user_service.dart';
import 'package:user_app/utils/city_state_provider.dart';
import 'package:user_app/utils/color_provider.dart';
import 'package:user_app/utils/text_builder.dart';

class EventReportScreen extends StatefulWidget {
  const EventReportScreen({super.key});

  @override
  State<EventReportScreen> createState() => _EventReportScreenState();
}

class _EventReportScreenState extends State<EventReportScreen> with TickerProviderStateMixin {
  late final UserService _userService;
  late final EventService _eventService;
  late final TabController _tabController;
  List<PolmitraUser> karyakartaList = [];
  PolmitraUser? user;

  List<Event> eventList = [];

  List<String> tabs = ['By Date', 'By Location', 'By Status', 'By User'];

  @override
  void initState() {
    super.initState();
    _userService = Provider.of<UserService>(context, listen: false);
    _eventService = Provider.of<EventService>(context, listen: false);
    _tabController = TabController(length: tabs.length, vsync: this);

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
        appBar: EventsReportAppBar(
          tabs: tabs,
          tabController: _tabController,
          initialize: initialize,
        ),
        body: MultiProvider(
          providers: [
            Provider<List<PolmitraUser>>.value(value: karyakartaList),
            Provider<PolmitraUser?>.value(value: user),
            Provider<List<Event>>.value(value: eventList)
          ],
          child: TabBarView(
            controller: _tabController,
            children: const [
              ByDateTab(),
              ByLocationTab(),
              ByStatusTab(),
              ByUserTab(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
