import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/event.dart';

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
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    byStatusEventList = events;
                  });
                },
                child: const Text('All'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    byStatusEventList = events.where((event) => event.isActive).toList();
                  });
                },
                child: const Text('Active'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    byStatusEventList = events.where((event) => !event.isActive).toList();
                  });
                },
                child: const Text('Inactive'),
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
}
