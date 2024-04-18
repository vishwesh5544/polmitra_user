import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/event.dart';
import 'package:user_app/models/indian_state.dart';
import 'package:user_app/screens/common/event_details_screen.dart';
import 'package:user_app/utils/city_state_provider.dart';
import 'package:user_app/utils/text_builder.dart';

class ByLocationTab extends StatefulWidget {
  const ByLocationTab({ super.key});

  @override
  State<ByLocationTab> createState() => _ByLocationTabState();
}

class _ByLocationTabState extends State<ByLocationTab> {
  List<Event> byLocationEventList = [];
  List<Event> events = [];
  IndianState? selectedState;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      events = Provider.of<List<Event>>(context);
      byLocationEventList = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildStatesDropdown(),
              const SizedBox(width: 10),
              // _buildCitiesDropdown(),
              IconButton(
                  onPressed: () {
                    setState(() {
                      selectedState = null;
                      byLocationEventList = events;
                    });
                  },
                  icon: const Icon(Icons.close))
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: byLocationEventList.length,
            itemBuilder: (context, index) {
              final event = byLocationEventList[index];
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatesDropdown() {
    var states = CityStateProvider().states;
    return Expanded(
      child: DropdownButtonFormField<IndianState>(
        hint: TextBuilder.getText(text: 'Select State', fontSize: 16),
        menuMaxHeight: 350,
        value: selectedState,
        onChanged: (IndianState? newValue) {
          setState(() {
            selectedState = newValue;
            byLocationEventList =
                events.where((element) => element.state.statename == newValue!.statename).toList();
          });
        },
        items: states.map<DropdownMenuItem<IndianState>>((IndianState state) {
          return DropdownMenuItem<IndianState>(
            value: state,
            child: SizedBox(width: 120, child: TextBuilder.getText(text: state.statename, fontSize: 16)),
          );
        }).toList(),
      ),
    );
  }
}
