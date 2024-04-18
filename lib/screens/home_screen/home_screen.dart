import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/enums/user_enums.dart';
import 'package:user_app/screens/account/account_screen.dart';
import 'package:user_app/screens/event/add_event_screen.dart';
import 'package:user_app/screens/event/events_screen.dart';
import 'package:user_app/screens/event_report/event_report_screen.dart';
import 'package:user_app/screens/polls/polls_screen.dart';
import 'package:user_app/services/preferences_service.dart';
import 'package:user_app/utils/color_provider.dart';

import '../polls/add_poll_screen.dart';

typedef LabelsMap = Map<String, IconData>;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Add this line

  final List<Widget> _screens = [
    const EventsScreen(),
    const PollsScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final LabelsMap _labelsMap = {
    'Events': Icons.home,
    'Polls': Icons.work,
    'Profile': Icons.person,
  };

  @override
  void initState() {
    super.initState();
  }

  void _toggleEndDrawer() {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      Navigator.of(context).pop(); // Close the drawer if it is open
    } else {
      _scaffoldKey.currentState?.openEndDrawer(); // Open the drawer if it is closed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _screens[_selectedIndex],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorProvider.lightLemon,
        title: InkWell(
          onTap: _toggleEndDrawer,
          child: const Text('User'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _toggleEndDrawer,
          ),
        ],
      ),
      endDrawerEnableOpenDragGesture: true,
      endDrawer: Drawer(
        child: FutureBuilder(
          future: _getDrawerOptions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading drawer options'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data found'));
            } else {
              return ListView(
                padding: EdgeInsets.zero,
                children: snapshot.data as List<Widget>,
              );
            }
          },
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: ColorProvider.lightLemon,
        ),
        child: BottomNavigationBar(
          selectedIconTheme: const IconThemeData(color: ColorProvider.deepSaffron),
          selectedItemColor: ColorProvider.deepSaffron,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          unselectedIconTheme: const IconThemeData(color: ColorProvider.darkSaffron),
          unselectedItemColor: ColorProvider.darkSaffron,
          items: _labelsMap.entries.map((e) => BottomNavigationBarItem(icon: Icon(e.value), label: e.key)).toList(),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _wrapWithSafeArea(Widget widget) {
    return SafeArea(
      child: widget,
    );
  }

  Future<List<Widget>> _getDrawerOptions() async {
    final user = await PrefsService.getRole();
    if (user == null) {
      return <Widget>[
        _getDrawerHeader(),
      ];
    }

    if (user == UserRole.neta.toString()) {
      return <Widget>[
        _getDrawerHeader(),
        ListTile(
          title: const Text('Events Report'),
          onTap: () {
            _scaffoldKey.currentState?.closeEndDrawer();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EventReportScreen()));
          },
        ),
      ];
    } else if (user == UserRole.karyakarta.toString()) {
      return <Widget>[
        _getDrawerHeader(),
        ListTile(
          title: const Text('Add Event'),
          onTap: () {
            _scaffoldKey.currentState?.closeEndDrawer();
            Navigator.push(context, MaterialPageRoute(builder: (context) => _wrapWithSafeArea(const AddEventScreen())));
          },
        )
      ];
    }

    return <Widget>[
      _getDrawerHeader(),
    ];
  }

  DrawerHeader _getDrawerHeader() {
    return const DrawerHeader(
      decoration: BoxDecoration(
        color: ColorProvider.lightLemon,
      ),
      child: Text('User'),
    );
  }
}
