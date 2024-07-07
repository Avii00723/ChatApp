import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final double height;
  final RegExp validationRegExp;
  final bool obscureText;
  final void Function(String?) onSaved;
  const CustomFormField({
    super.key,
    required this.hintText, required this.height, required this.validationRegExp,this.obscureText=false, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        onSaved: onSaved,
        validator: (value){
          if(value!=null && validationRegExp.hasMatch(value)){
            return null;
          }
          return "Enter a valid ${hintText.toLowerCase()}";
        },
       decoration: InputDecoration(
         border: const OutlineInputBorder(),
         hintText: hintText,
       ),
      ),
    );
  }
}
