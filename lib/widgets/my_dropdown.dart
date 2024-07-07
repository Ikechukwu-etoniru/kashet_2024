import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class MyDropDown extends StatelessWidget {
  Object? value;

  List<DropdownMenuItem<Object>>? items;
  void Function(Object?)? onChanged;
  Widget? hint;
  String? Function(Object?)? validator;
  MyDropDown(
      {required this.items,
      required this.onChanged,
      required this.hint,
      required this.validator,
      this.value,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2(
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 10,
        ),
        isDense: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
      ),
      items: items,
      onChanged: onChanged,
      hint: hint,
    );
  }
}
