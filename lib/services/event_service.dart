import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/models/event.dart';
import 'package:user_app/models/user.dart';

class EventService {
  final FirebaseFirestore _firestore;

  EventService(this._firestore);

  Future<List<Event>> getAllEvents() async {
    try {
      final querySnapshot = await _firestore.collection('events').get();

      final events = querySnapshot.docs.map((doc) => Event.fromDocument(doc)).toList();
      return events;
    } catch (e) {
      // Handle errors (e.g., print error message, throw exception)
      print("Error fetching events: $e");
      return []; // Return empty list on error
    }
  }

  Future<List<Event>> getAllEventsByKaryakartaId(PolmitraUser karyakarta) async {
    try {
      final querySnapshot = await _firestore.collection('events').where('karyakarta', isEqualTo: karyakarta).get();

      final events = querySnapshot.docs.map((doc) => Event.fromDocument(doc)).toList();
      return events;
    } catch (e) {
      // Handle errors (e.g., print error message, throw exception)
      print("Error fetching events: $e");
      return []; // Return empty list on error
    }
  }

  Future<List<Event>> getEventsByNetaId(String netaId) async {
    try {
      final querySnapshot = await _firestore.collection('events').where('netaId', isEqualTo: netaId).get();

      final events = querySnapshot.docs.map((doc) => Event.fromDocument(doc)).toList();
      return events;
    } catch (e) {
      // Handle errors (e.g., print error message, throw exception)
      print("Error fetching events: $e");
      return []; // Return empty list on error
    }
  }

}
