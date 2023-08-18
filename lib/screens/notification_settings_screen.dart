import 'package:flutter/material.dart';

class NotificationSettings extends StatefulWidget {
  static const routeName = '/notification_settings_screen.dart';
  const NotificationSettings({Key? key}) : super(key: key);

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  var _emailNotValue = false;
  var _pushNotValue = false;
  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: _deviceHeight * 0.03,
              ),
              Row(
                children: [
                  const Text(
                    'Email Notification',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  Switch.adaptive(
                      value: _emailNotValue,
                      onChanged: (value) {
                        setState(() {
                          _emailNotValue = value;
                        });
                      })
                ],
              ),
              const Divider(thickness: 1),
              Row(
                children: [
                  const Text(
                    'Push Notification',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  Switch.adaptive(
                      value: _pushNotValue,
                      onChanged: (value) {
                        setState(() {
                          _pushNotValue = value;
                        });
                      })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
