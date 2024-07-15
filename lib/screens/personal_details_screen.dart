import 'package:flutter/material.dart';
import 'package:kasheto_flutter/provider/location_provider.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/edit_personal_details_screen.dart';
import 'package:kasheto_flutter/screens/user_bank_list.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:provider/provider.dart';

class PersonalDetailScreen extends StatefulWidget {
  static const routeName = '/personal_detail_screen.dart';

  const PersonalDetailScreen({Key? key}) : super(key: key);

  @override
  State<PersonalDetailScreen> createState() => _PersonalDetailScreenState();
}

class _PersonalDetailScreenState extends State<PersonalDetailScreen> {
  Future<void> _errorDialog() async {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return Dialog(
            elevation: 30,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: Image.asset(
                      'images/unavailable_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'Unfortunately !!!!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'You need to set your personal details before you can set your bank details',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: InkWell(
                      onTap: (() {
                        Navigator.of(context).pop();
                      }),
                      child: Chip(
                        backgroundColor: Colors.green[500],
                        label: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
                        elevation: 15,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<AuthProvider>(context, listen: false).userList[0];
    final userIdStatus = Provider.of<AuthProvider>(context).userVerified;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileContainer(
                  child: [
                    Row(
                      children: [
                        const Text(
                          'Personal Details',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Spacer(),
                        if (userIdStatus != IDStatus.approved)
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                  EditPersonalDetailsScreen.routeName);
                            },
                            icon: const Icon(
                              Icons.mode_edit,
                              size: 18,
                              color: MyColors.primaryColor,
                            ),
                          )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (userIdStatus != IDStatus.approved)
                      const Text(
                        'Note - When your identity card is verified, you would not be able to change these details',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    if (userIdStatus == IDStatus.approved)
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Identity Verified',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 14,
                          )
                        ],
                      ),
                    const SizedBox(
                      height: 5,
                    ),
                    ProfileRow(
                        title: 'Name',
                        content: '${_user.firstName} ${_user.lastName}'),
                    ProfileRow(
                        title: 'Date of Birth',
                        content: _user.dob ?? 'Not Set'),
                    ProfileRow(
                        title: 'Address', content: _user.address ?? 'Not Set'),
                    ProfileRow(title: 'City', content: _user.city ?? 'Not Set'),
                    ProfileRow(
                      title: 'State',
                      content: _user.state == 'null' || _user.state == null
                          ? 'Not Set'
                          : Provider.of<LocationProvider>(context,
                                  listen: false)
                              .getStateById(
                              int.parse(_user.state!),
                            ),
                    ),
                    ProfileRow(
                      title: 'Country',
                      content: _user.country == null || _user.country == 'null'
                          ? 'Not Set'
                          : Provider.of<LocationProvider>(context,
                                  listen: false)
                              .getCountryById(
                              int.parse(_user.country!),
                            ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (Provider.of<AuthProvider>(context, listen: false)
                            .userList
                            .first
                            .country ==
                        null) {
                      _errorDialog();
                    } else {
                      Navigator.of(context).pushNamed(UserBankList.routeName);
                    }
                  },
                  child: const ProfileContainer(child: [
                    Row(children: [
                      Text(
                        'Bank Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: MyColors.primaryColor,
                      ),
                    ]),
                  ]),
                ),
                ProfileContainer(
                  child: [
                    const Row(
                      children: [
                        Text(
                          'Email Address',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Spacer(),
                      ],
                    ),
                    ProfileRow(title: 'Email', content: _user.emailAddress),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
                ProfileContainer(child: [
                  const Row(
                    children: [
                      Text(
                        'Phone Number',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Spacer(),
                    ],
                  ),
                  ProfileRow(title: 'Primary', content: _user.phoneNumber),
                  const SizedBox(
                    height: 10,
                  ),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileContainer extends StatelessWidget {
  final dynamic child;

  const ProfileContainer({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 1,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 12,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: child,
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  final String title;
  final String content;

  const ProfileRow({required this.title, required this.content, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11),
        ),

        const SizedBox(
          width: 3,
        ),
        const Text('-'),
        const SizedBox(
          width: 3,
        ),

        Expanded(
          child: Text(
            content,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ),

        // )
      ]),
    );
  }
}
