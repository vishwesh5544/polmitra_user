import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/models/poll.dart';
import '../../services/user_service.dart';
import 'poll_event.dart';
import 'poll_state.dart';

class PollBloc extends Bloc<PollEvent, PollState> {
  final FirebaseFirestore firestore;
  final UserService _userService;

  PollBloc(this.firestore, this._userService) : super(PollInitial()) {
    on<AddPollEvent>(_onAddPoll);
    on<LoadPolls>(_onLoadPolls);
    on<UpdatePollResponse>(_onUpdatePollResponse);
  }

  Future<void> _onAddPoll(AddPollEvent event, Emitter<PollState> emit) async {
    emit(PollLoading());
    try {
      final neta = await _userService.getUserById(event.userId);
      final createdBy = await _userService.getUserById(event.userId);

      final request = {
        'question': event.question,
        'options': event.options,
        'netaId': event.userId,
        'responses': { for (var option in event.options) option : 0 },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true, // isActive is set to false by default when a poll is created
        'neta': neta?.toMap(),
        'createdBy': createdBy?.toMap(),
      };
      final docRef = await firestore.collection('polls').add(request);
      final snapshot = await docRef.get();
      final poll = Poll.fromDocument(snapshot);
      emit(PollAdded(poll));
      add(LoadPolls(netaId: event.userId));
    } catch (e) {
      emit(PollError(e.toString()));
    }
  }

  FutureOr<void> _onLoadPolls(LoadPolls event, Emitter<PollState> emit) async {
    emit(PollLoading());
    try {
      final querySnapshot = await firestore.collection('polls').where('netaId', isEqualTo: event.netaId).get();

      final polls = querySnapshot.docs.map((doc) => Poll.fromDocument(doc)).toList();
      polls.removeWhere((poll) => !poll.isActive);
      emit(PollsLoaded(polls));
    } catch (e) {
      emit(PollError(e.toString()));
    }
  }

  FutureOr<void> _onUpdatePollResponse(UpdatePollResponse event, Emitter<PollState> emit) async {
    emit(PollLoading());
    try {

      final karyaKarta = await _userService.getUserById(event.karyakartaId);

      await firestore.collection('polls').doc(event.pollId).update({
        'responses.${event.option}': FieldValue.increment(1),
        'responders': FieldValue.arrayUnion([karyaKarta?.toMap()])
      });
      add(LoadPolls(netaId: event.netaId));
    } catch (e) {
      emit(PollError(e.toString()));
    }
  }
}
