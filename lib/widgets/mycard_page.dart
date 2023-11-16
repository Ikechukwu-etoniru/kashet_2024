import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kasheto_flutter/widgets/card_container.dart';
import 'package:provider/provider.dart';
import '/provider/user_card_provider.dart';
import '/screens/notification_screen.dart';

class MyCardPage extends StatefulWidget {
  const MyCardPage({Key? key}) : super(key: key);

  @override
  State<MyCardPage> createState() => _MyCardPageState();
}

class _MyCardPageState extends State<MyCardPage> {
  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    final _usercardList = Provider.of<UserCardProvider>(context).userCardList;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(
            height: _deviceHeight * 0.1,
            width: _deviceWidth,
            child: Row(
              children: [
                const Text(
                  'My Cards',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
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
          if (_usercardList.isNotEmpty)
            SizedBox(
                height: _deviceHeight * 0.1,
                width: _deviceWidth,
                child: const Text(
                    'The following card(s) are available for you to use when completing your transactions.')),
          Expanded(
            child: Column(
              children: [
                if (_usercardList.isEmpty)
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.faceMeh,
                          color: Colors.grey,
                          size: 50,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'You have no cards yet, Add some.',
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  ),
                if (_usercardList.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                        itemCount: _usercardList.length,
                        itemBuilder: (context, index) {
                          return WCardContainer(
                              action: () {},
                              card: _usercardList[index],
                              width: _deviceWidth);
                        }),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
