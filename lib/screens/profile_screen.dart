import 'package:flutter/material.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/login_screen.dart';
import 'package:kasheto_flutter/screens/personal_details_screen.dart';
import 'package:kasheto_flutter/screens/security_settings_screen.dart';
import 'package:kasheto_flutter/screens/update_image_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile_screen.dart';
  const ProfileScreen({Key? key}) : super(key: key);

  Future _logout(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        elevation: 30,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: Colors.transparent,
        builder: (_) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            // height: MediaQuery.of(context).size.height * 0.2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'Do you want to logout ?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(
                      height: 35,
                      child: VerticalDivider(
                        color: Colors.grey,
                        thickness: 2,
                        width: 20,
                      ),
                    ),
                    TextButton(
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        SharedPreferences localStorage =
                            await SharedPreferences.getInstance();
                        if (localStorage.containsKey('token')) {
                          localStorage.remove('token');
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              LoginScreen.routeName, (route) => false);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<AuthProvider>(context).userList[0];
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                width: double.infinity,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(userData.imageUrl!),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                          return const  UpdateImageScreen(id: 1,);
                        }));
                      },
                      child: const Text('Change Image'),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      userData.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(userData.emailAddress),
                  ],
                ),
              ),
              ProfileContainer(
                title: 'User Settings',
                option1: 'Personal Details',
                option2: 'Security Settings',
                option1F: () {
                  Navigator.of(context).pushNamed(PersonalDetailScreen.routeName);
                },
                option2F: () {
                  Navigator.of(context)
                      .pushNamed(SecuritySettingsScreen.routeName);
                },
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: TextButton(
                  onPressed: () async {
                    await _logout(context);
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileContainer extends StatelessWidget {
  final String title;
  final String option1;
  final String option2;
  final VoidCallback option1F;
  final VoidCallback option2F;
  const ProfileContainer(
      {required this.title,
      required this.option1,
      required this.option2,
      required this.option1F,
      required this.option2F,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),
          Row(
            children: [
              Text(option1),
              const Spacer(),
              IconButton(
                onPressed: option1F,
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 17,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          const Divider(),
          Row(
            children: [
              Text(option2),
              const Spacer(),
              IconButton(
                onPressed: option2F,
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 17,
                  color: Colors.grey,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
