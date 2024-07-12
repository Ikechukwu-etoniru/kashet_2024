import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/notification_screen.dart';
import 'package:kasheto_flutter/screens/profile_screen.dart';
import 'package:provider/provider.dart';

class HomeTopWidget extends StatelessWidget {
  const HomeTopWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userList[0];
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
        bottom: 10,
        left: 10,
        right: 10,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green,
            radius: 21,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(ProfileScreen.routeName);
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(user.imageUrl!),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi,  ${user.firstName}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'What would you like to do today?',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(NotificationScreen.routeName);
              },
              icon: const FaIcon(
                FontAwesomeIcons.bell,
                size: 15,
              ),
            ),
          )
        ],
      ),
    );
  }
}
