import 'package:flutter/material.dart';
import 'package:user_app/utils/color_provider.dart';

class IconBuilder {
  static IconButton buildButton({
    required IconData icon,
    Color color = ColorProvider.normalBlack,
    void Function()? onPressed,
    double size = 15,
    ButtonStyle? buttonStyle,
  }) {
    return IconButton(
      style: buttonStyle,
      onPressed: onPressed ?? () {},
      icon: Icon(icon, color: color, size: size),
    );
  }
}
