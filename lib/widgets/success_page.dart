import 'package:flutter/material.dart';
import 'package:kasheto_flutter/screens/initialization_screen.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: SizedBox(
            height: 200,
            width: 200,
            child: Image.asset(
              'images/happy_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          'Your transaction was successful',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 25, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 15,
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                InitializationScreen.routeName, (route) => false);
          },
          child: const Text('Return to home'),
        ),
      ],
    );
  }
}
