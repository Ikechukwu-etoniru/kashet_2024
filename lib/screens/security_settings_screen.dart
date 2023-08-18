import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/main_screen.dart';
import 'package:kasheto_flutter/screens/support_screen.dart';
import 'package:kasheto_flutter/screens/update_password_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:provider/provider.dart';

class SecuritySettingsScreen extends StatefulWidget {
  static const routeName = '/security_settings_screen.dart';
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  var _isLoading = false;
  // Using this value to direct the user to initialization screen
  // Only if auth status is changed
  var _isAuthChanged = false;

  

  Future _changeAuthStatus(bool value) async {
    _isAuthChanged = true;
    setState(() {
      _isLoading = true;
    });
    try {
      final url =
          Uri.parse('${ApiUrl.baseURL}user/profile/change-two-fa-state');
      final _header = await ApiUrl.setHeaders();
      final _body = json.encode({"two_fa_status": value ? 1 : 0});
      final response = await http.post(url, body: _body, headers: _header);
      final res = json.decode(response.body);

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: res['message'], context: context));
        Provider.of<AuthProvider>(context, listen: false)
            .changeFaStatus(res['New State']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: ApiUrl.errorString, context: context));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message: 'An error occurred, 2FA status wasn\'t changed successfully',
          context: context));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool auth2faValueBool = Provider.of<AuthProvider>(context).faStatus == 1 ? true : false;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Security Settings'),
          leading: IconButton(
            onPressed: () {
              if (_isAuthChanged) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    MainScreen.routeName, (route) => false);
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 15,
              ),
              SecuritySettingsBox(
                  title: 'Update Password',
                  action: () {
                    Navigator.of(context)
                        .pushNamed(UpdatePasswordScreen.routeName);
                  }),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1),
                ]),
                child: Row(
                  children: [
                    Text(auth2faValueBool == true ? '2FA Enabled' : '2FA Disabled'),
                    const Spacer(),
                    if (_isLoading)
                      const SpinKitDoubleBounce(
                        color: MyColors.primaryColor,
                        size: 50,
                      ),
                    if (!_isLoading)
                      Switch.adaptive(
                          value: auth2faValueBool,
                          onChanged: (value) {
                            _changeAuthStatus(value);
                          })
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SecuritySettingsBox(
                  title: 'Support',
                  action: () {
                    Navigator.of(context).pushNamed(SupportScreen.routeName);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class SecuritySettingsBox extends StatelessWidget {
  final String title;
  final VoidCallback action;
  const SecuritySettingsBox(
      {required this.title, required this.action, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1),
      ]),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          IconButton(
            onPressed: action,
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 17,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}
