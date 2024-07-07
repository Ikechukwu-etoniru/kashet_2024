import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/http_exceptions.dart';
import 'package:kasheto_flutter/models/user.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/initialization_screen.dart';
import 'package:kasheto_flutter/screens/login_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/widgets/error_widget.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth2FaScreen extends StatefulWidget {
  static const routeName = '/auth_2fa_screen.dart';
  const Auth2FaScreen({Key? key}) : super(key: key);

  @override
  State<Auth2FaScreen> createState() => _Auth2FaScreenState();
}

class _Auth2FaScreenState extends State<Auth2FaScreen> {
  var _isLoading = false;
  var _isButtonLoading = false;
  var _isSendingLoading = false;
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isError = false;
  var _delayResendCode = false;
  String? errorMessage;
  User get getUser {
    return Provider.of<AuthProvider>(context, listen: false).userList[0];
  }

  @override
  void initState() {
    super.initState();
    _getUSerDetails();
  }

  Future _delayPressingResendCode() async {
    setState(() {
      _delayResendCode = true;
    });

    await Future.delayed(const Duration(minutes: 1), () {
      setState(() {
        _delayResendCode = false;
      });
    });
  }

  Future _sendOtp() async {
    if (_delayResendCode) {
      ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message: 'Wait for a minute before you can resend otp',
          context: context));
    } else {
      try {
        setState(() {
          _isSendingLoading = true;
        });
        await Provider.of<AuthProvider>(context, listen: false)
            .sendAuthOtp(isResend: true);
        ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
            message: 'Code has been sent to your phone number',
            context: context));
        _delayPressingResendCode();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
            message: '${ApiUrl.errorString} sending otp', context: context));
      } finally {
        setState(() {
          _isSendingLoading = false;
        });
      }
    }
  }

  Future<void> _getUSerDetails() async {
    setState(() {
      _isError = false;
      _isLoading = true;
    });
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .fetchUserDetails();
    } catch (error) {
      setState(() {
        _isError = true;
        errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getDeviceInfo() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.model} - ${androidInfo.id}';
    } else if (Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return '${iosInfo.model} - ${iosInfo.identifierForVendor}';
    } else {
      throw AppException('An error ocured getting device info');
    }
  }

  Future _checkAuth() async {
    final _isValid = _formKey.currentState!.validate();
    if (_isValid) {
      setState(() {
        _isButtonLoading = true;
      });
      try {
        final url = Uri.parse('${ApiUrl.baseURL}user/verify-two-fa-code');
        final _header = await ApiUrl.setHeaders();
        final _deviceInfo = await _getDeviceInfo();
        final _body = json
            .encode({"code": _textController.text, "ip_address": _deviceInfo});
        final response = await http.post(url, headers: _header, body: _body);
        final res = json.decode(response.body);

        if (response.statusCode == 200 && res['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
              Alert.snackBar(message: res['message'], context: context));
          Navigator.of(context).pushNamedAndRemoveUntil(
              InitializationScreen.routeName, (route) => false);
        } else if (response.statusCode == 200 && res['success'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
              Alert.snackBar(message: res['message'], context: context));
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: 'An error occured', context: context));
      } finally {
        setState(() {
          _isButtonLoading = false;
        });
      }
    }
  }

  Future<bool> _goBackToLogin() async {
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
                content:
                    const Text('Are you sure you want to go back to login'),
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
    final _deviceHeight = MediaQuery.of(context).size.height;
    return _isLoading
        ? const LoadingSpinnerWithScaffold()
        : _isError
            ? const IsErrorScreen()
            : WillPopScope(
                onWillPop: _goBackToLogin,
                child: SafeArea(
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: AppBar(),
                    body: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: _deviceHeight * 0.2,
                              child: Center(
                                child: SizedBox(
                                  height: (_deviceHeight * 0.2) * 0.7,
                                  child: Image.asset('images/auth_pic.png'),
                                ),
                              ),
                            ),
                            const Text(
                              'Two Factor Authentication',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Raleway',
                                  fontSize: 25),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'You seem to have changed your device !!!. Please confirm your account by entering the authorization code we will send to the number below',
                              textAlign: TextAlign.center,
                              style: TextStyle(),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              getUser.phoneNumber
                                  .replaceRange(4, 10, '*******'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                _sendOtp();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _delayResendCode
                                      ? Colors.grey
                                      : MyColors.primaryColor,
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                ),
                                child: Text(
                                  _isSendingLoading
                                      ? 'Sending'
                                      : _delayResendCode
                                          ? 'Code sent'
                                          : 'Send Code',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: PinCodeTextField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter the code sent to you';
                                  } else if (value.length != 4) {
                                    return 'Enter the four pin ode sent to you';
                                  } else {
                                    return null;
                                  }
                                },
                                errorTextSpace: 25,
                                appContext: context,
                                length: 4,
                                onChanged: (value) {},
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(10),
                                  selectedColor: Colors.green[300],
                                  activeColor: Colors.green[700],
                                  inactiveColor: Colors.grey[200],
                                ),
                                animationDuration:
                                    const Duration(milliseconds: 200),
                                animationType: AnimationType.fade,
                                keyboardType: TextInputType.number,
                                hapticFeedbackTypes: HapticFeedbackTypes.medium,
                                controller: _textController,
                              ),
                            ),
                            const Spacer(),
                            if (_isButtonLoading)
                              const LoadingSpinnerWithMargin(),
                            if (!_isButtonLoading)
                              SubmitButton(
                                action: () {
                                  _checkAuth();
                                },
                                title: 'Authenticate',
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
  }
}
