import 'package:flutter/material.dart';

class TextFieldText extends StatelessWidget {
  final String text;
  const TextFieldText({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        fontSize: 12,
      ),
    );
  }
}
