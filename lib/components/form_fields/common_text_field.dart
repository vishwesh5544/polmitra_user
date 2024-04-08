import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:user_app/utils/color_provider.dart';
import 'package:user_app/utils/data_store.dart';
import 'package:user_app/utils/text_utility.dart';
import 'package:user_app/utils/utils.dart';

class CommonTextField extends StatelessWidget {
  Function onChange;
  Function? onSubmit;
  TextEditingController controller;
  String hintText;
  String title;
  final bool showTitle;
  final List<TextInputFormatter>? inputFormatters;
  final List<FormFieldValidator<String>>? validators;
  final String name;
  final bool readOnly;
  final bool required;
  bool obscureText;
  final BoxConstraints? boxConstraints;

  CommonTextField({
    required this.name,
    required this.onChange,
    required this.title,
    this.onSubmit,
    this.boxConstraints,
    this.showTitle = true,
    this.obscureText = false,
    required this.controller,
    required this.hintText,
    this.inputFormatters,
    this.validators,
    this.readOnly = false,
    this.required = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
            visible: showTitle,
            maintainSize: false,
            maintainAnimation: false,
            maintainState: true,
            child: Text(title, style: TextUtility.getStyle(13))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.8), // Shadow color and opacity
                spreadRadius: 0.5,
                blurRadius: 3,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: FormBuilderTextField(
            name: name,
            readOnly: readOnly,
            obscureText: obscureText,
            validator: FormBuilderValidators.compose([
              if (required) FormBuilderValidators.required(),
              if (validators != null) ...validators!,
            ]),
            controller: controller,
            style: TextUtility.getStyle(14, color: ColorProvider.darkGreyColor),
            onChanged: (value) {
              onChange.call(value);
            },
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
                hintStyle: TextUtility.getStyle(14, color: ColorProvider.darkGreyColor),
                constraints: boxConstraints ?? DataStore.commonTextFieldConstraints,
                border: getOutLineBorder(),
                focusedErrorBorder: getOutLineBorder(),
                errorBorder: getOutLineBorder(),
                disabledBorder: getOutLineBorder(),
                enabledBorder: getOutLineBorder(),
                focusedBorder: getOutLineBorder(),
                hintText: hintText),
          ),
        )
      ],
    );
  }

// getBorder(){
//   return OutlineInputBorder(borderSide: BorderSide(color: ColourProvider.greyColor, width: 0.2),);
// }
}
