import 'package:flutter/material.dart';

class DialogRow extends StatelessWidget {
  final String title;
  final String content;
  const DialogRow({required this.title, required this.content, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            content,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12, fontFamily: ''),
          )
        ],
      ),
    );
  }
}
