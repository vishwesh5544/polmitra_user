import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_app/bloc/polmitra_event/pevent_event.dart';
import 'package:user_app/bloc/polmitra_event/pevent_state.dart';
import 'package:user_app/models/event.dart';
import 'package:user_app/services/user_service.dart';

class EventBloc extends Bloc<PolmitraEvent, PolmitraEventState> {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final UserService _userService;

  EventBloc(this.firestore, this.storage, this._userService) : super(AddEventInitial()) {
    on<UploadDataEvent>(_uploadEventData);
    on<LoadEvents>(_loadEvents);
  }

  FutureOr<void> _uploadEventData(UploadDataEvent event, Emitter<PolmitraEventState> emit) async {
    emit(AddEventLoading());
    try {
      List<String> imageUrls = [];

      for (var image in event.images) {
        String fileName =
            'events/${event.netaId}/${DateTime.now().millisecondsSinceEpoch}.${image.path.split('.').last}';
        TaskSnapshot snapshot = await storage.ref(fileName).putFile(File(image.path));
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      final karyaKarta = await _userService.getUserById(event.karyakartaId);
      final neta = await _userService.getUserById(event.netaId);

      final request = {
        'eventName': event.eventName,
        'description': event.description,
        'date': event.date,
        'time': event.time,
        'address': event.address,
        'images': imageUrls,
        'netaId': event.netaId,
        'karyakartaId': event.karyakartaId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'karyakarta': karyaKarta?.toMap(),
        'neta': neta?.toMap(),
        "state": event.state.toMap(),
        "city": event.city.toMap(),
      };

      final docRef = await firestore.collection('events').add(request);
      final snapshot = await docRef.get();
      emit(AddEventSuccess());
      add(LoadEvents(netaId: event.netaId));
    } catch (e) {
      emit(AddEventFailure(e.toString()));
    }
  }

  FutureOr<void> _loadEvents(LoadEvents event, Emitter<PolmitraEventState> emit) async {
    emit(EventLoading());
    try {
      final snapshot = await firestore.collection('events').where('netaId', isEqualTo: event.netaId).get();
      final events = snapshot.docs.map((e) => Event.fromDocument(e)).toList();
      events.removeWhere((event) => !event.isActive);
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
}
