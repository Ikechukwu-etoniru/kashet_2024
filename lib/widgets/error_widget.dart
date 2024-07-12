import 'package:flutter/material.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';

class IsErrorScreen extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  const IsErrorScreen({this.onPressed, this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: MyPadding.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: SizedBox(
                  height: 100,
                ),
              ),
              SizedBox(
                height: 120,
                width: 120,
                child: Image.asset(
                  'images/unavailable_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                text ?? 'An error occured',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onPressed ??
                    () {
                      Navigator.of(context).pop();
                    },
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    color: MyColors.primaryColor,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
