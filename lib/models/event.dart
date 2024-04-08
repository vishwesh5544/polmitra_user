import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/models/user.dart';

class Event {
  final String id;
  final String eventName;
  final String description;
  final String date;
  final String time;
  final String location;
  final List<String> images;
  final String karyakartaId;
  final PolmitraUser? karyakarta;
  final String netaId;
  final PolmitraUser? neta;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  String get netaDisplayName => neta?.name ?? neta?.email ?? netaId;
  String get karyakartaDisplayName => karyakarta?.name ?? karyakarta?.email ?? karyakartaId;

  Event(
      {required this.id,
      required this.eventName,
      required this.description,
      required this.date,
      required this.time,
      required this.location,
      required this.images,
      required this.karyakartaId,
      required this.netaId,
      required this.isActive,
      this.karyakarta,
      this.neta,
      this.createdAt,
      this.updatedAt});

  factory Event.fromDocument(DocumentSnapshot doc) {
    return Event(
        id: doc.id,
        eventName: doc['eventName'] ?? '',
        description: doc['description'] ?? '',
        date: doc['date'] ?? '',
        time: doc['time'] ?? '',
        location: doc['location'] ?? '',
        images: List<String>.from(doc['images'] ?? []),
        karyakartaId: doc['karyakartaId'] ?? '',
        netaId: doc['netaId'] ?? '',
        isActive: doc['isActive'] ?? true,
        createdAt: doc['createdAt'],
        updatedAt: doc['updatedAt'],
        karyakarta: doc['karyakarta'] != null ? PolmitraUser.fromMap(doc['karyakarta']) : null,
        neta: doc['neta'] != null ? PolmitraUser.fromMap(doc['neta']) : null);
  }

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'description': description,
      'date': date,
      'time': time,
      'location': location,
      'images': images,
      'karyakartaId': karyakartaId,
      'netaId': netaId,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'neta': neta?.toMap(),
      'karyakarta': karyakarta?.toMap()
    };
  }

  Event copyWith(
      {String? id,
      String? eventName,
      String? description,
      String? date,
      String? time,
      String? location,
      List<String>? images,
      String? karyakartaId,
      String? netaId,
      bool? isActive,
      PolmitraUser? karyakarta,
      PolmitraUser? neta,
      Timestamp? updatedAt}) {
    return Event(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      images: images ?? this.images,
      karyakartaId: karyakartaId ?? this.karyakartaId,
      netaId: netaId ?? this.netaId,
      isActive: isActive ?? this.isActive,
      karyakarta: karyakarta ?? this.karyakarta,
      neta: neta ?? this.neta,
      createdAt: createdAt,
    );
  }
}
