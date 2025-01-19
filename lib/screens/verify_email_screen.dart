import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/screens/initialization_screen.dart';
import 'package:kasheto_flutter/screens/login_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';

import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  static const routeName = '/verify_email_screen.dart';
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _textController = TextEditingController();
  var _isLoading = false;
  var _isButtonLoading = false;
  String? _otp;
  var _isTimer = false;
  Timer? _timer;
  int _start = 59;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  void _startTimer() {
    setState(() {
      _isTimer = true;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _start = 59;
            timer.cancel();
            setState(() {
              _isTimer = false;
            });
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future _sendOtp() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final url = Uri.parse('${ApiUrl.baseURL}user/profile/send-otp-email');
      final header = await ApiUrl.setHeaders();
      final body = json.encode({"email": _email});
      final response = await http.post(url, body: body, headers: header);
      final res = json.decode(response.body);
      if (response.statusCode == 200 && res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: res["message"], context: context),
        );
        _startTimer();
        _otp = res['otp']['otp'].toString();
      } else if (response.statusCode == 200 &&
          res['success'] == true &&
          res['otp'] == 'wait') {
        ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
            message: 'Wait for some minutes and try again', context: context));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
            message: 'An error occured. Try again', context: context));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message: 'An error occured. Try again', context: context));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _verifyOtp() async {
    final _isValid = _formKey.currentState!.validate();
    if (_isValid) {
      setState(() {
        _isButtonLoading = true;
      });
      try {
        final url = Uri.parse('${ApiUrl.baseURL}user/profile/verify-otp-email');
        final header = await ApiUrl.setHeaders();
        final body = json.encode({"email": _email, "otp": _otp});
        final response = await http.post(url, body: body, headers: header);
        final res = json.decode(response.body);

        if (response.statusCode == 200 && res['success'] == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(
              Alert.snackBar(message: res['message'], context: context));
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
              message: 'An error occurred try again.', context: context));
          return false;
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: error.toString(), context: context));
        return false;
      } finally {
        setState(() {
          _isButtonLoading = false;
        });
      }
    } else {
      return false;
    }
  }

  String get _email {
    return Provider.of<AuthProvider>(context, listen: false)
        .userList[0]
        .emailAddress;
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
                      Navigator.of(context)
                          .pushReplacementNamed(LoginScreen.routeName);
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

    return WillPopScope(
      onWillPop: _closeApp,
      child: SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: const Text('Verify Email'),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: _deviceHeight * 0.3,
                        child: Center(
                          child: SizedBox(
                            height: (_deviceHeight * 0.3) * 0.7,
                            child: Image.asset('images/email_pic.png'),
                          ),
                        ),
                      ),
                      if (_isLoading) const LoadingSpinnerWithMargin(),
                      if (!_isLoading)
                        TextButton(
                          onPressed: _sendOtp,
                          child: _isLoading
                              ? const LoadingSpinnerWithMargin()
                              : _isTimer
                                  ? Text(
                                      _start.toString(),
                                      style: const TextStyle(
                                        color: MyColors.primaryColor,
                                      ),
                                    )
                                  : const Text(
                                      'Send OTP',
                                      style: TextStyle(
                                        color: MyColors.primaryColor,
                                      ),
                                    ),
                        ),
                      const Text(
                        'We will send you a verification link to this email',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        _email,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: PinCodeTextField(
                          validator: (value) {
                            if (value == null) {
                              return 'Enter OTP sent to your email';
                            } else if (value.length != 4) {
                              return 'Enter complete OTP';
                            } else if (value != _otp) {
                              return 'Enter correct OTP sent to your email';
                            } else {
                              return null;
                            }
                          },
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
                          animationDuration: const Duration(milliseconds: 200),
                          animationType: AnimationType.fade,
                          keyboardType: TextInputType.number,
                          hapticFeedbackTypes: HapticFeedbackTypes.medium,
                          controller: _textController,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      // const Spacer(),
                      if (_isButtonLoading) const LoadingSpinnerWithMargin(),
                      if (!_isButtonLoading)
                        SubmitButton(
                            action: () async {
                              if (_otp == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    Alert.snackBar(
                                        message:
                                            'You have not received an otp yet. Click "Send OTP"',
                                        context: context));
                              } else {
                                final _isVerified = await _verifyOtp();
                                if (_isVerified) {
                                  Navigator.pushReplacementNamed(
                                      context, InitializationScreen.routeName);
                                }
                              }
                            },
                            title: 'Verify')
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
