import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kasheto_flutter/screens/login_screen.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/widgets/home_page.dart';
// import '/widgets/mycard_page.dart';
import '/widgets/service_page.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main_screen.dart';
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List _pages = [
    const HomePage(),
    const ServicePage(),
    // const MyCardPage()
  ];
  int selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  Future<bool> _closeApp() async {
    return await (showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                title: const Text(
                  'Confirm Exit...!!!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                content: const Text('Are you sure you want to logout'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      SharedPreferences localStorage =
                          await SharedPreferences.getInstance();
                      if (localStorage.containsKey('token')) {
                        localStorage.remove('token');
                      }
                      Navigator.of(context).pop(true);

                      Navigator.of(context).pushNamedAndRemoveUntil(
                          LoginScreen.routeName, (route) => false);
                    },
                    child: const Text('Yes'),
                  )
                ],
              );
            })) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _closeApp,
      child: SafeArea(
        child: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
                selectedIconTheme: const IconThemeData(
                  color: MyColors.primaryColor,
                ),
                selectedLabelStyle: const TextStyle(
                  color: MyColors.primaryColor,
                ),
                currentIndex: selectedPageIndex,
                onTap: _selectPage,
                items: const [
                  BottomNavigationBarItem(
                    icon: FaIcon(
                      FontAwesomeIcons.house,
                      size: 12,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.paperPlane, size: 12),
                    label: 'Services',
                  ),
                ]),
            appBar: AppBar(
              toolbarHeight: 0,
              elevation: 0,
            ),
            body: _pages[selectedPageIndex]),
      ),
    );
  }
}
