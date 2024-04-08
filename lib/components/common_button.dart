import "package:flutter/material.dart";
import "package:user_app/utils/color_provider.dart";
import "package:user_app/utils/text_utility.dart";

class CommonButton extends StatefulWidget {
  const CommonButton(
      {super.key, required this.buttonText, required this.onClick, this.width = 150, this.height = 42, this.icon,  this.buttonStyle});

  final double width;
  final double height;
  final String buttonText;
  final Function onClick;
  final Icon? icon;
  final ButtonStyle? buttonStyle;

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        style: widget.buttonStyle ?? ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(10),
            fixedSize: Size(widget.width, widget.height),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            backgroundColor: ColorProvider.burningRed),
        icon: widget.icon ?? Container(),
        label: Text(widget.buttonText, style: TextUtility.getStyle(18, color: Colors.white)),
        onPressed: () {
          widget.onClick.call();
          // Navigator.pushNamed(context, routeName);
        });
  }
}
