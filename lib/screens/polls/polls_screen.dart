import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_app/bloc/poll/poll_bloc.dart';
import 'package:user_app/bloc/poll/poll_event.dart';
import 'package:user_app/bloc/poll/poll_state.dart';
import 'package:user_app/enums/user_enums.dart';
import 'package:user_app/models/poll.dart';
import 'package:user_app/screens/polls/add_poll_screen.dart';
import 'package:user_app/services/preferences_service.dart';
import 'package:user_app/utils/color_provider.dart';
import 'package:user_app/utils/text_builder.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  PersistentBottomSheetController? _bottomSheetController;
  String? netaId;
  String? userRole;
  String? userId;
  TextEditingController _searchController = TextEditingController();
  List<Poll> filteredPolls = [];

  @override
  void initState() {
    super.initState();
    _loadNetaIdandPolls();
    _loadUserRole();
    _searchController.addListener(_filterPolls);
  }

  Future<void> _loadNetaIdandPolls() async {
    final bloc = BlocProvider.of<PollBloc>(context);
    final role = await PrefsService.getRole();
    userId = await PrefsService.getUserId();
    if (role == UserRole.neta.toString()) {
      netaId = await PrefsService.getUserId();
    } else if (role == UserRole.karyakarta.toString()) {
      netaId = await PrefsService.getNetaId();
    }

    if (netaId != null) {
      bloc.add(LoadPolls(netaId: netaId!));
    }
  }

  Future<void> _loadUserRole() async {
    var role = await PrefsService.getRole();
    setState(() {
      userRole = role;
    });
  }

  void _navigateToAddPollScreen() {
    _bottomSheetController = showBottomSheet(
      context: context,
      builder: (context) {
        return const AddPollScreen();
      },
    );
  }

  void _filterPolls() {
    if (context.read<PollBloc>().state is PollsLoaded) {
      final polls = (context.read<PollBloc>().state as PollsLoaded).polls;
      final text = _searchController.text.toLowerCase();
      setState(() {
        filteredPolls =
        text.isEmpty ? polls : polls.where((poll) => poll.question.toLowerCase().contains(text)).toList();
      });
    }
  }

  void _updateFilteredPolls(List<Poll> polls) {
    if (filteredPolls.isEmpty && _searchController.text.isEmpty) {
      filteredPolls = polls;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: userRole == UserRole.neta.toString()
          ? FloatingActionButton(
        onPressed: _navigateToAddPollScreen,
        child: const Icon(Icons.add),
      )
          : null,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: "Search polls...",
            suffixIcon: Icon(Icons.search),
          ),
        ),
      ),
      body: BlocBuilder<PollBloc, PollState>(
        builder: (context, state) {
          /// polls loading state
          if (state is PollLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// polls loaded state
          else if (state is PollsLoaded) {
            _updateFilteredPolls(state.polls);
            final polls = state.polls;
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: filteredPolls.length,
                itemBuilder: (context, index) {
                  final poll = filteredPolls[index];
                  print(poll.toMap());
                  final isPollSubmitted = poll.responders.any((responder) => responder.uid == userId);
                  final totalVotes = poll.responses.values.reduce((sum, element) => sum + element);

                  /// if user is neta show percentage
                  if (isPollSubmitted || userRole == UserRole.neta.toString()) {
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextBuilder.getText(
                                text: poll.question,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                          ...poll.options.asMap().entries.map((entry) {
                            final option = entry.value;
                            final voteCount = poll.responses[option] ?? 0;
                            final percentage = totalVotes > 0 ? (voteCount / totalVotes) * 100 : 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("$option: ${(percentage).toStringAsFixed(2)}%"),
                                  LinearProgressIndicator(
                                    borderRadius: BorderRadius.circular(10),
                                    minHeight: 10,
                                    value: totalVotes - voteCount > 0 ? percentage / 100 : 1.0,
                                    backgroundColor: ColorProvider.lightAccentOrange,
                                    valueColor: const AlwaysStoppedAnimation<Color>(ColorProvider.softOrange),
                                  ),
                                  const SizedBox(height: 10), // Spacing between bars
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }

                  /// if user is karyakarta show radio buttons
                  if (userRole == UserRole.karyakarta.toString()) {
                    return Card(
                      child: Column(
                        children: [
                          Text(poll.question),
                          ...poll.options.map(
                                (option) => RadioListTile(
                              title: Text(option),
                              value: option,
                              groupValue: null,
                              onChanged: (value) {
                                if (userId != null && netaId != null) {
                                  final bloc = BlocProvider.of<PollBloc>(context);
                                  bloc.add(UpdatePollResponse(
                                      pollId: poll.id, option: option, karyakartaId: userId!, netaId: netaId!));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('User id or neta id is null'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  /// if user is neither neta nor karyakarta
                  return const SizedBox.shrink();
                },
              ),
            );
          } else if (state is PollError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _bottomSheetController?.close();
  }
}
