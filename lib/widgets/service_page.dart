import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kasheto_flutter/widgets/service_icon.dart';


import '/screens/notification_screen.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          margin:
              const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
          height: _deviceHeight * 0.1,
          width: _deviceWidth,
          child: Row(
            children: [
              const Text(
                'Services',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 1),
              ),
              const Spacer(),
              Center(
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(NotificationScreen.routeName);
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.bell,
                    size: 18,
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              itemCount: 8,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.7),
              itemBuilder: (context, index) {
                return ServiceIcons(
                  index: index,
                );
              }),
        )
      ],
    );
  }
}

