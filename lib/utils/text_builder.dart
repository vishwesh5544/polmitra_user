import 'package:flutter/material.dart';
import 'package:user_app/utils/color_provider.dart';

class TextBuilder {
  static Text getText(
      {required String text,
      double fontSize = 20,
      Color color = ColorProvider.normalBlack,
      FontWeight fontWeight = FontWeight.normal,
      TextAlign textAlign = TextAlign.start,
      TextOverflow overflow = TextOverflow.ellipsis, int? maxLines}) {
    return Text(text, maxLines: maxLines, style: TextStyle(fontSize: fontSize, color: color, overflow: overflow, fontWeight: fontWeight));
  }

  static TextStyle getTextStyle(
      {double fontSize = 20,
      Color color = ColorProvider.normalBlack,
      FontWeight fontWeight = FontWeight.normal,
      TextAlign textAlign = TextAlign.start,
      TextOverflow overflow = TextOverflow.ellipsis}) {
    return TextStyle(fontSize: fontSize, color: color, overflow: overflow, fontWeight: fontWeight);
  }
}
