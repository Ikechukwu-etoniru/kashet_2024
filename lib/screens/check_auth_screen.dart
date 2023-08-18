import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:kasheto_flutter/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kasheto_flutter/screens/login_screen.dart';
import 'package:kasheto_flutter/screens/onboarding_screen.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({Key? key}) : super(key: key);

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  Future<int> _checkForToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final _isValid = localStorage.containsKey('token');
    final _oldUser = localStorage.containsKey('old user');
    if (_isValid && _oldUser) {
      return 1;
    } else if (!_isValid && _oldUser) {
      return 2;
    } else {
      return 3;
    }
  }

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Allow Notifications'),
              content:
                  const Text('Our app would like to send you notifications'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Don\'t Allow',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () => AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context)),
                  child: const Text(
                    'Allow',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkForToken(),
      builder: ((context, snapshot) {
        return snapshot.connectionState == ConnectionState.waiting
            ?  const  SafeArea(
              child: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            )
            : snapshot.data == 1
                ? const LoginScreen()
                : snapshot.data == 2
                    ? const SignupScreen()
                    : const OnboardingScreen();
      }),
    );
  }
}
