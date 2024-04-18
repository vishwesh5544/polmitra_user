import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/event.dart';
import 'package:user_app/screens/common/event_details_screen.dart';

class ByStatusTab extends StatefulWidget {
  const ByStatusTab({super.key});

  @override
  State<ByStatusTab> createState() => _ByStatusTabState();
}

class _ByStatusTabState extends State<ByStatusTab> {
  List<Event> byStatusEventList = [];
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      events = Provider.of<List<Event>>(context);
      byStatusEventList = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      byStatusEventList = events;
                    });
                  },
                  child: const Text('All'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      byStatusEventList = events.where((event) => event.isActive).toList();
                    });
                  },
                  child: const Text('Active'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      byStatusEventList = events.where((event) => !event.isActive).toList();
                    });
                  },
                  child: const Text('Inactive'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: byStatusEventList.length,
            itemBuilder: (context, index) {
              final event = byStatusEventList[index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(event: event),
                    ),
                  );
                },
                leading: CircleAvatar(
                  child: Text(event.eventName[0]),
                ),
                title: Text(event.eventName),
                subtitle: Text(event.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(event.date),
              );
            },
          ),
        ),
      ],
    );
  }
}
