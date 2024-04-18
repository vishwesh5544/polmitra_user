import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/event.dart';
import 'package:user_app/models/user.dart';
import 'package:user_app/screens/event_report/event_app_bar.dart';
import 'package:user_app/services/event_service.dart';
import 'package:user_app/services/preferences_service.dart';
import 'package:user_app/services/user_service.dart';
import 'package:user_app/utils/color_provider.dart';

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

  List<Event> allEventsList = [];
  List<Event> eventList = [];
  List<Event> byDateEventList = [];
  List<Event> byLocationEventList = [];
  List<Event> byStatusEventList = [];
  List<Event> byUserEventList = [];


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
      allEventsList = events;
      byDateEventList = events;
      byLocationEventList = events;
      byStatusEventList = events;
      byUserEventList = events;
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
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildByDate(),
            _buildByLocation(),
            Text(' Poll Reports'),
            Text(' Poll Reports'),
          ],
        ),
      ),
    );
  }

  Widget _buildByLocation() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: byLocationEventList.length,
            itemBuilder: (context, index) {
              final event = eventList[index];
              return ListTile(
                title: Text(event.eventName),
                subtitle: Text(event.description),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildByDate() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
    const format = 'dd/MM/yyyy';

    return Column(
      children: [
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    byDateEventList = allEventsList;
                  });
                },
                child: const Text('All'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    byDateEventList = allEventsList.where((event) => DateFormat(format).parse(event.date) == today).toList();
                  });
                },
                child: const Text('Today'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    byDateEventList = allEventsList.where((event) {
                      DateTime eventDate = DateFormat(format).parse(event.date);
                      return eventDate.isAfter(startOfWeek) && eventDate.isBefore(endOfWeek);
                    }).toList();
                  });
                },
                child: const Text('This Week'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    byDateEventList = allEventsList.where((event) {
                      DateTime eventDate = DateFormat(format).parse(event.date);
                      return eventDate.isAfter(startOfMonth) && eventDate.isBefore(endOfMonth);
                    }).toList();
                  });
                },
                child: const Text('This Month'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: byDateEventList.length,
            itemBuilder: (context, index) {
              final event = byDateEventList[index];
              return ListTile(
                title: Text(event.eventName),
                subtitle: Text(event.description),
                trailing: Text(event.date),
              );
            },
          ),
        ),
      ],
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      backgroundColor: ColorProvider.deepSaffron,
      title: const InkWell(
        child: Text('Reports'),
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: tabs.map((e) => Tab(text: e)).toList(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: initialize,
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
