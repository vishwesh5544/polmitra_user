import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/event.dart';

class ByDateTab extends StatefulWidget {
  const ByDateTab({super.key});

  @override
  State<ByDateTab> createState() => _ByDateTabState();
}

class _ByDateTabState extends State<ByDateTab> {
  List<Event> byDateEventList = [];
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
      byDateEventList = events;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    byDateEventList = events;
                  });
                },
                child: const Text('All'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    byDateEventList =
                        events.where((event) => DateFormat(format).parse(event.date) == today).toList();
                  });
                },
                child: const Text('Today'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    byDateEventList = events.where((event) {
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
                    byDateEventList = events.where((event) {
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
}
