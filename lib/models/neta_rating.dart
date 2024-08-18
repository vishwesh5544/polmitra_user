import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:user_app/models/user.dart';

class NetaRating {
  final String? id;
  final String netaId;
  final String karyakartaId;
  final PolmitraUser karyakarta;
  final String rating;
  final String? reason;
  final Timestamp? createAt;
  final Timestamp? updatedAt;

  NetaRating(
      {this.id,
      required this.netaId,
      required this.karyakartaId,
      required this.rating,
      required this.createAt,
      required this.updatedAt,
      this.reason,
      required this.karyakarta});

  factory NetaRating.fromMap(Map<String, dynamic> data) {
    return NetaRating(
        id: data['id'] ?? '',
        netaId: data['netaId'] ?? '',
        karyakartaId: data['karyakartaId'] ?? '',
        karyakarta: PolmitraUser.fromMap(data['karyakarta']),
        rating: data['rating'] ?? '',
        reason: data['reason'],
        createAt: data['createAt'] ?? '',
        updatedAt: data['updatedAt'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'netaId': netaId,
      'karyakartaId': karyakartaId,
      'rating': rating,
      'reason': reason,
      'createAt': createAt,
      'updatedAt': updatedAt,
      'karyakarta': karyakarta.toMap(),
    };
  }
}
