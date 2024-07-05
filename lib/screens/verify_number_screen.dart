import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/initialization_screen.dart';
import 'package:kasheto_flutter/screens/login_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyNumberScreen extends StatefulWidget {
  static const routeName = '/verify_number_screen.dart';

  const VerifyNumberScreen({Key? key}) : super(key: key);

  @override
  State<VerifyNumberScreen> createState() => _VerifyNumberScreenState();
}

class _VerifyNumberScreenState extends State<VerifyNumberScreen> {
  var _isLoading = false;
  var _isLoading1 = false;
  final _textController = TextEditingController();
  var _isTimer = false;
  Timer? _timer;
  int _start = 59;
  String? _otp;
  final _formKey = GlobalKey<FormState>();

  //
  var _isResend = false;

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

  String _phoneNumber() {
    return Provider.of<AuthProvider>(context, listen: false)
        .userList[0]
        .phoneNumber;
  }

  SnackBar _snackBar({required String message}) {
    return SnackBar(
      elevation: 100,
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
          }),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }

  Future _sendOtp() async {
    if (_isTimer) {
      return;
    }

    final _userNumber = Provider.of<AuthProvider>(context, listen: false)
        .userList[0]
        .phoneNumber;
    setState(() {
      _isLoading = true;
    });
    try {
      final _url = Uri.parse('${ApiUrl.baseURL}v1/enter-phone-code');
      final _header = await ApiUrl.setHeaders();
      final _body = _isResend
          ? json.encode({'phone': _userNumber, 'resend': true})
          : json.encode({'phone': _userNumber, 'resend': false});
      final httpResponse = await http.post(_url, body: _body, headers: _header);

      final response = json.decode(httpResponse.body);
      if (httpResponse.statusCode == 200 && response['success'] == true) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar(message: response['message']),
        );
        _startTimer();
        _otp = response['otp'].toString();
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar(message: 'An error occurred sending OTP'),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar(message: 'An error occured'),
      );
    } finally {
      if (_isResend == false) {
        _isResend = true;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _verifyNumber() async {
    if (_otp == null) {
      ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message: 'You have not received an OTP, Click send OTP',
          context: context));
      return false;
    } else {
      final _isValid = _formKey.currentState!.validate();
      if (_isValid == false) {
        return false;
      }
      final _userNumber = Provider.of<AuthProvider>(context, listen: false)
          .userList[0]
          .phoneNumber;
      setState(() {
        _isLoading1 = true;
      });
      try {
        const url = '${ApiUrl.baseURL}v1/verify-phone-code';
        final _header = await ApiUrl.setHeaders();
        final httpResponse = await http.post(Uri.parse(url),
            body: json
                .encode({"phone": _userNumber, "code": _textController.text}),
            headers: _header);
        final response = json.decode(httpResponse.body);
        if (httpResponse.statusCode == 200 && response["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            _snackBar(message: response['message']),
          );
          return true;
        } else if (httpResponse.statusCode == 200 &&
            response["success"] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            _snackBar(message: response['message']),
          );
          return false;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              Alert.snackBar(message: ApiUrl.errorString, context: context));
          return false;
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar(message: 'An error occured'),
        );
        return false;
      } finally {
        setState(() {
          _isLoading1 = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }

    super.dispose();
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
            title: const Text('Verify Phone Number'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: _deviceHeight * 0.25,
                    child: Center(
                      child: SizedBox(
                        height: (_deviceHeight * 0.25) * 0.7,
                        child: Image.asset('images/call_pic.png'),
                      ),
                    ),
                  ),
                  const Text(
                    'We will send you a one time password to this number',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    _phoneNumber(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  TextButton(
                    onPressed: _sendOtp,
                    child: _isLoading
                        ? const LoadingSpinnerWithMargin()
                        : _isTimer
                            ? Text(_start.toString())
                            : _isResend
                                ? const Text('Resend OTP')
                                : const Text('Send OTP'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 40),
                  //   child: PinCodeTextField(
                  //     validator: (value) {
                  //       if (value == null) {
                  //         return 'Enter OTP sent to your email';
                  //       } else if (value.length != 4) {
                  //         return 'Enter complete OTP';
                  //       } else if (value != _otp) {
                  //         return 'Enter correct OTP sent to your email';
                  //       } else {
                  //         return null;
                  //       }
                  //     },
                  //     appContext: context,
                  //     length: 4,
                  //     onChanged: (value) {},
                  //     pinTheme: PinTheme(
                  //       shape: PinCodeFieldShape.box,
                  //       borderRadius: BorderRadius.circular(10),
                  //       selectedColor: Colors.green[300],
                  //       activeColor: Colors.green[700],
                  //       inactiveColor: Colors.grey[200],
                  //     ),
                  //     animationDuration: const Duration(milliseconds: 200),
                  //     animationType: AnimationType.fade,
                  //     keyboardType: TextInputType.number,
                  //     hapticFeedbackTypes: HapticFeedbackTypes.medium,
                  //     controller: _textController,
                  //   ),
                  // ),
                  const Spacer(),
                  if (_isLoading1) const LoadingSpinnerWithMargin(),
                  if (!_isLoading1)
                    SubmitButton(
                      action: () async {
                        final _isVerified = await _verifyNumber();
                        if (_isVerified) {
                          Navigator.of(context).pushReplacementNamed(
                              InitializationScreen.routeName);
                        }
                      },
                      title: 'Verify',
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
