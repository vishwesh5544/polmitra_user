import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final String location;
  final List<XFile> images;
  final String netaId;
  final String karyakartaId;

  UploadDataEvent({
    required this.eventName,
    required this.description,
    required this.date,
    required this.time,
    required this.netaId,
    required this.karyakartaId,
    required this.location,
    required this.images,
  });
}



