import 'package:flutter/material.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  static const routeName = 'support_screen.dart';
  const SupportScreen({Key? key}) : super(key: key);

  Future openwhatsapp(BuildContext context) async {
    var whatsapp = "+19455420315";
    var whatsappURlAndroid =
        Uri.parse("whatsapp://send?phone=" + whatsapp + "&text=hello");

    if (await canLaunchUrl(whatsappURlAndroid)) {
      await launchUrl(whatsappURlAndroid);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: 'Whatsapp not installed', context: context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Support'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: _deviceHeight * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // color: MyColors.primaryColor.withOpacity(0.3),
                ),
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset(
                    'images/support_icon.png',
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Tell Us How We Can Help You',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Our crew is standing by for service and support',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  openwhatsapp(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: MyColors.primaryColor),
                        height: 40,
                        width: 40,
                        child: const Icon(
                          Icons.support_agent,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chat',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Start a conversation now',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.ads_click_outlined,
                        color: MyColors.primaryColor,
                      )
                    ],
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
