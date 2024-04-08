import 'package:flutter/material.dart';
import 'package:user_app/screens/account/account_screen.dart';
import 'package:user_app/screens/event/add_event_screen.dart';
import 'package:user_app/screens/event/events_screen.dart';
import 'package:user_app/screens/polls/polls_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorProvider.deepSaffron,
        title: const Text('Polmitra'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedIconTheme: const IconThemeData(color: ColorProvider.softSaffron),
        selectedItemColor: ColorProvider.softSaffron,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        backgroundColor: ColorProvider.deepSaffron,
        items: _labelsMap.entries.map((e) => BottomNavigationBarItem(icon: Icon(e.value), label: e.key)).toList(),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
