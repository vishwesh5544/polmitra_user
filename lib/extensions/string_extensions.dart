extension StringExt on String {
  String get capitalize => this[0].toUpperCase() + substring(1);

  String get asPolmitraEmail => '$this@polmitra.com';
}