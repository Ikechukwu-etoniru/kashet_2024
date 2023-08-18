import 'package:flutter/material.dart';

class LanguageLocationScreen extends StatefulWidget {
  static const routeName = '/language_location_screen.dart';
  const LanguageLocationScreen({Key? key}) : super(key: key);

  @override
  State<LanguageLocationScreen> createState() => _LanguageLocationScreenState();
}

class _LanguageLocationScreenState extends State<LanguageLocationScreen> {
  var _acctStatusValue = false;
  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Language & Location'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: _deviceHeight * 0.03,
              ),
              const Text(
                'Language',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20, right: 20),
                      hintText: 'English(Uited States)',
                      border: InputBorder.none),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Time Zone',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20, right: 20),
                      hintText: 'Africa/Lagos',
                      border: InputBorder.none),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  const Text(
                    'Push Notification',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  Switch.adaptive(
                      value: _acctStatusValue,
                      onChanged: (value) {
                        setState(() {
                          _acctStatusValue = value;
                        });
                      })
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: _deviceHeight * 0.07,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white),
                    ),
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
