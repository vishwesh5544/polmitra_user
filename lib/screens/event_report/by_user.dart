import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/event.dart';
import 'package:user_app/models/user.dart';
import 'package:user_app/screens/common/event_details_screen.dart';

class ByUserTab extends StatefulWidget {
  const ByUserTab({super.key});

  @override
  State<ByUserTab> createState() => _ByUserTabState();
}

class _ByUserTabState extends State<ByUserTab> {
  List<Event> events = [];
  PolmitraUser? user;
  List<PolmitraUser> karyakartas = [];
  List<PolmitraUser> filteredkaryakartas = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      user = Provider.of<PolmitraUser>(context);
      karyakartas = Provider.of<List<PolmitraUser>>(context);
      events = Provider.of<List<Event>>(context);
      filteredkaryakartas = karyakartas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      filteredkaryakartas = karyakartas;
                    });
                  },
                  child: const Text('Clear Filter'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      filteredkaryakartas.sort((a, b) {
                        int aPoints = a.points ?? 0;
                        int bPoints = b.points ?? 0;
                        return aPoints.compareTo(bPoints);
                      });
                    });
                  },
                  child: const Text('Highest Points'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      filteredkaryakartas.sort((a, b) {
                        int aPoints = a.points ?? 0;
                        int bPoints = b.points ?? 0;
                        return bPoints.compareTo(aPoints);
                      });
                    });
                  },
                  child: const Text('Lowest Points'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: karyakartas.length,
            itemBuilder: (context, index) {
              final karyakarta = karyakartas[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(karyakarta.name[0]),
                ),
                title: Text(karyakarta.name),
                subtitle: Text(karyakarta.email),
                trailing: Text(karyakarta.points.toString()),
                onTap: () {
                  final byUserEvents = events.where((event) => event.karyakartaId == karyakarta.uid).toList();

                  showModalBottomSheet(
                    isDismissible: true,
                    enableDrag: true,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: byUserEvents.length,
                                itemBuilder: (context, index) {
                                  final event = byUserEvents[index];
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
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
