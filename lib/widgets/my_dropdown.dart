import 'package:flutter/material.dart';

// ignore: must_be_immutable
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
    return DropdownButtonFormField(
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
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
