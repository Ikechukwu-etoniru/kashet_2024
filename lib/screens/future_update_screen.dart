import 'package:flutter/material.dart';

class FutureUpdate extends StatelessWidget {
  static const routeName = '/future_update_screen.dart';
  const FutureUpdate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Image.asset(
                    'images/unavailable_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'This feature will be added with future update',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Go Back',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
