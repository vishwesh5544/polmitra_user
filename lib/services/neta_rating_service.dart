import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/models/neta_rating.dart';

class NetaRatingService {
  final FirebaseFirestore _firestore;

  NetaRatingService(this._firestore);

  Future<NetaRating> addNetaRatings(NetaRating netaRating) async {
    try {
      await _firestore.collection('neta_ratings').add(netaRating.toMap());
      return netaRating;
    } catch (e) {
      // Handle errors (e.g., print error message, throw exception)
      print("Error adding neta_rating: $e");
      throw Exception('Failed to add neta_rating: $e');
    }
  }

  Future<List<NetaRating>> getAllRatingsForNeta(String netaId) async {
    try {
      final querySnapshot = await _firestore.collection('neta_ratings').where('netaId', isEqualTo: netaId).get();
      final ratings = querySnapshot.docs.map((doc) => NetaRating.fromMap(doc.data())).toList();
      return ratings;
    } catch (e) {
      // Handle errors (e.g., print error message, throw exception)
      print("Error fetching ratings: $e");
      throw Exception('Failed to fetch ratings: $e');
    }
  }

  Future<List<NetaRating>> findAllRatingsByKaryakarta(String userId) async {
    try {
      final querySnapshot = await _firestore.collection('neta_ratings').where('karyakartaId', isEqualTo: userId).get();
      final ratings = querySnapshot.docs.map((doc) => NetaRating.fromMap(doc.data())).toList();
      return ratings;
    } catch (e) {
      // Handle errors (e.g., print error message, throw exception)
      print("Error fetching ratings: $e");
      throw Exception('Failed to fetch ratings: $e');
    }
  }
}
