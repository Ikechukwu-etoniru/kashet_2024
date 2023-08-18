import 'package:flutter/material.dart';

class DialogChip extends StatelessWidget {
  final void Function() onTap;
  final String text;
  final Color color;
  const DialogChip(
      {required this.onTap, required this.text, required this.color, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        backgroundColor: color,
        label: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 15,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }
}