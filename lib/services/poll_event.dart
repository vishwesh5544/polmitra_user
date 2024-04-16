import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/models/poll.dart';

class PollService {
  final FirebaseFirestore _firestore;

  PollService(this._firestore);

  Future<List<Poll>> getPolls() async {
    try {
      var querySnapshot = await _firestore.collection('polls').get();

      return querySnapshot.docs.map((doc) => Poll.fromDocument(doc)).toList();
    } on Exception catch (e) {
      log("Error fetching polls: $e");
      return [];
    }
  }

  Future<List<Poll>> getPollsByKaryakartaId(String netaId) async {
    try {
      var querySnapshot = await _firestore.collection('polls').where('neta.netaid', isEqualTo: netaId).get();

      return querySnapshot.docs.map((doc) => Poll.fromDocument(doc)).toList();
    } on Exception catch (e) {
      log("Error fetching polls: $e");
      return [];
    }
  }

}
