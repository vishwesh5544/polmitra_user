import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/models/indian_city.dart';
import 'package:user_app/models/indian_state.dart';
import 'package:user_app/models/user.dart';
import 'package:user_app/utils/city_state_provider.dart';

class Event {
  final String id;
  final String eventName;
  final String description;
  final String date;
  final String time;
  final String address;
  final List<String> images;
  final String karyakartaId;
  final PolmitraUser? karyakarta;
  final String netaId;
  final PolmitraUser? neta;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final IndianState state;
  final IndianCity city;

  String get netaDisplayName => neta?.name ?? neta?.email ?? netaId;

  String get karyakartaDisplayName => karyakarta?.name ?? karyakarta?.email ?? karyakartaId;

  Event(
      {required this.id,
      required this.eventName,
      required this.description,
      required this.date,
      required this.time,
      required this.address,
      required this.images,
      required this.karyakartaId,
      required this.netaId,
      required this.isActive,
      this.karyakarta,
      this.neta,
      this.createdAt,
      this.updatedAt,
      required this.state,
      required this.city});

  factory Event.fromDocument(DocumentSnapshot doc) {
    return Event(
        id: doc.id,
        eventName: doc['eventName'] ?? '',
        description: doc['description'] ?? '',
        date: doc['date'] ?? '',
        time: doc['time'] ?? '',
        address: doc['address'] ?? '',
        images: List<String>.from(doc['images'] ?? []),
        karyakartaId: doc['karyakartaId'] ?? '',
        netaId: doc['netaId'] ?? '',
        isActive: doc['isActive'] ?? true,
        createdAt: doc['createdAt'],
        updatedAt: doc['updatedAt'],
        karyakarta: doc['karyakarta'] != null ? PolmitraUser.fromMap(doc['karyakarta']) : null,
        neta: doc['neta'] != null
            ? PolmitraUser.fromMap(
                doc['neta'],
              )
            : null,
        state: IndianState.fromMap(doc['state']),
        city: IndianCity.fromMap(doc['city']));
  }

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'description': description,
      'date': date,
      'time': time,
      'location': address,
      'images': images,
      'karyakartaId': karyakartaId,
      'netaId': netaId,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'neta': neta?.toMap(),
      'karyakarta': karyakarta?.toMap(),
      'state': state?.toMap(),
      'city': city?.toMap(),
    };
  }

  Event copyWith(
      {String? id,
      String? eventName,
      String? description,
      String? date,
      String? time,
      String? address,
      List<String>? images,
      String? karyakartaId,
      String? netaId,
      bool? isActive,
      PolmitraUser? karyakarta,
      PolmitraUser? neta,
      Timestamp? updatedAt,
      IndianState? state,
      IndianCity? city}) {
    return Event(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      address: address ?? this.address,
      images: images ?? this.images,
      karyakartaId: karyakartaId ?? this.karyakartaId,
      netaId: netaId ?? this.netaId,
      isActive: isActive ?? this.isActive,
      karyakarta: karyakarta ?? this.karyakarta,
      neta: neta ?? this.neta,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      state: state ?? this.state,
      city: city ?? this.city,
    );
  }
}
