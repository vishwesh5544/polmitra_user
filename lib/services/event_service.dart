import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_app/models/event.dart';
import 'package:user_app/models/user.dart';

class EventService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage storage;

  EventService(this._firestore, this.storage);

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

  Future<bool> updateEventImages(String netaId, String eventId, List<XFile> images, List<String> imageUrls) async {
    try {

      for (var image in images) {
        String fileName = 'events/$netaId/${DateTime.now().millisecondsSinceEpoch}.${image.path.split('.').last}';
        TaskSnapshot snapshot = await storage.ref(fileName).putFile(File(image.path));
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      await _firestore.collection('events').doc(eventId).update({'images': imageUrls});
      return true;
    } catch (e) {
      // Handle errors (e.g., print error message, throw exception)
      print("Error updating event images: $e");
      return false;
    }
  }
}
