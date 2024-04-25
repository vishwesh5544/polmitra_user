import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/event.dart';
import 'package:user_app/screens/common/event_details_screen.dart';

class ByDateTab extends StatefulWidget {
  const ByDateTab({super.key});

  @override
  State<ByDateTab> createState() => _ByDateTabState();
}

class _ByDateTabState extends State<ByDateTab> {
  List<Event> byDateEventList = [];
  List<Event> events = [];
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

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

  void _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: selectedStartDate ?? DateTime.now(),
        end: selectedEndDate ?? DateTime.now().add(Duration(days: 7)),
      ),
    );
    if (picked != null) {
      setState(() {
        selectedStartDate = picked.start;
        selectedEndDate = picked.end;
        _filterEventsByDateRange();
      });
    }
  }

  void _filterEventsByDateRange() {
    setState(() {
      byDateEventList = events.where((event) {
        DateTime eventDate = DateFormat('dd/MM/yyyy').parse(event.date);
        return eventDate.isAfter(selectedStartDate!.subtract(Duration(days: 1))) &&
            eventDate.isBefore(selectedEndDate!.add(Duration(days: 1)));
      }).toList();
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _pickDateRange,
                  child: const Text('Pick Date Range'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      byDateEventList = events;
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
                      byDateEventList = events.where((event) => DateFormat(format).parse(event.date) == today).toList();
                    });
                  },
                  child: const Text('Today'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
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
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
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
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(
                        event: event,
                        isUploadEnabled: false,
                      ),
                    )),
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
