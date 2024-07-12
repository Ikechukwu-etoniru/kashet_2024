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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                          fontSize: 12,
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
                        thickness: 1.5,
                        width: 15,
                      ),
                    ),
                    TextButton(
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
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
    final userIdStatus = Provider.of<AuthProvider>(context).userVerified;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(userData.imageUrl!),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) {
                              return const UpdateImageScreen(
                                id: 1,
                              );
                            }));
                          },
                          child: const Text(
                            'Change Image',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          // Fix first last name
                          userData.firstName,
                          maxLines: 2,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          userData.emailAddress,
                          style: const TextStyle(fontSize: 11),
                        ),
                        Text(
                          userIdStatus == IDStatus.notSubmitted ||
                                  userIdStatus == IDStatus.declined
                              ? 'Unverified'
                              : userIdStatus == IDStatus.pending
                                  ? 'Verification Pending'
                                  : 'Verified',
                          style: TextStyle(
                            color: userIdStatus == IDStatus.notSubmitted ||
                                    userIdStatus == IDStatus.declined
                                ? Colors.red
                                : userIdStatus == IDStatus.pending
                                    ? Colors.blue
                                    : Colors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ProfileContainer(
                title: 'User Settings',
                option1: 'Personal Details',
                option2: 'Security Settings',
                option1F: () {
                  Navigator.of(context)
                      .pushNamed(PersonalDetailScreen.routeName);
                },
                option2F: () {
                  Navigator.of(context)
                      .pushNamed(SecuritySettingsScreen.routeName);
                },
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const Divider(),
          Row(
            children: [
              Text(
                option1,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: option1F,
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          Row(
            children: [
              Text(
                option2,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: option2F,
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
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
