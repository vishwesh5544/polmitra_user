import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_app/bloc/polmitra_event/pevent_bloc.dart';
import 'package:user_app/bloc/polmitra_event/pevent_event.dart';
import 'package:user_app/bloc/polmitra_event/pevent_state.dart';
import 'package:user_app/enums/user_enums.dart';
import 'package:user_app/models/event.dart';
import 'package:user_app/screens/event/add_event_screen.dart';
import 'package:user_app/screens/common/event_details_screen.dart';
import 'package:user_app/services/preferences_service.dart';
import 'package:user_app/utils/text_builder.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  PersistentBottomSheetController? _addEventBottomSheetController;
  PersistentBottomSheetController? _eventBottomSheetController;
  String? netaId;
  String? userRole;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadNetaIdEvents();
    _loadUserRole();
  }

  Future<void> _loadNetaIdEvents() async {
    final bloc = BlocProvider.of<EventBloc>(context);
    final role = await PrefsService.getRole();
    userId = await PrefsService.getUserId();
    if (role == UserRole.neta.toString()) {
      netaId = await PrefsService.getUserId();
    } else if (role == UserRole.karyakarta.toString()) {
      netaId = await PrefsService.getNetaId();
    }

    if (netaId != null) {
      bloc.add(LoadEvents(netaId: netaId!));
    }
  }

  Future<void> _loadUserRole() async {
    var role = await PrefsService.getRole();
    setState(() {
      userRole = role;
    });
  }



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, PolmitraEventState>(
      buildWhen: (previous, current) {
        return current is EventLoading ||
            current is EventsLoaded ||
            current is EventError ||
            current is AddEventSuccess;
      },
      builder: (context, state) {
        /// Show loading indicator
        if (state is EventLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        /// Show events list
        else if (state is EventsLoaded) {
          return Scaffold(
            floatingActionButton: userRole == UserRole.karyakarta.toString()
                ? FloatingActionButton(
                    onPressed: _navigateToAddEventScreen,
                    child: const Icon(Icons.add),
                  )
                : null,
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: state.events.length,
                itemBuilder: (context, index) {
                  final event = state.events[index];
                  return ListTile(
                    title: TextBuilder.getText(text: event.eventName, color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                    subtitle: TextBuilder.getText(text: event.description, color: Colors.black, fontSize: 12),
                    leading: SizedBox(
                      width: 100,
                      child: CachedNetworkImage(
                        imageUrl: event.images.isNotEmpty ? event.images.first : 'https://via.placeholder.com/150',
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        fit: BoxFit.cover,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () => _showEventBottomSheet(event),
                  );
                },
              ),
            ),
          );
        }

        /// Show error message
        else if (state is EventError) {
          return Center(
            child: Text(state.message),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _navigateToAddEventScreen() {
    _addEventBottomSheetController = showBottomSheet(
      // isScrollControlled: true,
      context: context,
      builder: (context) {
        return const AddEventScreen();
      },
    );
  }

  void _showEventBottomSheet(Event event) {
    _eventBottomSheetController = showBottomSheet(
      context: context,
      builder: (context) {
        return EventDetailsScreen(event: event);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _addEventBottomSheetController?.close();
    _eventBottomSheetController?.close();
  }
}
