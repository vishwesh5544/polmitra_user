import 'package:firebase_core/firebase_core.dart';

class NetaRating {
  final String netaId;
  final String karyakartaId;
  final String rating;
  final String? reason;
  final String createAt;
  final String updatedAt;

  NetaRating(
      {required this.netaId,
      required this.karyakartaId,
      required this.rating,
      required this.createAt,
      required this.updatedAt,
      this.reason});

  factory NetaRating.fromMap(Map<String, dynamic> data) {
    return NetaRating(
        netaId: data['netaId'] ?? '',
        karyakartaId: data['karyakartaId'] ?? '',
        rating: data['rating'] ?? '',
        reason: data['reason'],
        createAt: data['createAt'] ?? '',
        updatedAt: data['updatedAt'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'netaId': netaId,
      'karyakartaId': karyakartaId,
      'rating': rating,
      'reason': reason,
      'createAt': createAt,
      'updatedAt': updatedAt
    };
  }
}
