import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_app/models/indian_city.dart';
import 'package:user_app/models/indian_state.dart';
import 'package:user_app/utils/city_state_provider.dart';

abstract class PolmitraEvent {}

class LoadEvents extends PolmitraEvent {
  String netaId;

  LoadEvents({required this.netaId});
}

class UploadDataEvent extends PolmitraEvent {
  final String eventName;
  final String description;
  final String date;
  final String time;
  final String address;
  final List<XFile> images;
  final String netaId;
  final String karyakartaId;
  final IndianState state;
  final IndianCity city;

  UploadDataEvent({
    required this.eventName,
    required this.description,
    required this.date,
    required this.time,
    required this.netaId,
    required this.karyakartaId,
    required this.address,
    required this.images,
    required this.state,
    required this.city,
  });
}



