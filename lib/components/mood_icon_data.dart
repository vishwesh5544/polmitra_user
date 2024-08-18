import 'package:flutter/material.dart';

class MoodIconData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  MoodIconData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
