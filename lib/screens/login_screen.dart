import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/auth_screen.dart';
import 'package:kasheto_flutter/screens/forgot_password_screen.dart';
import 'package:kasheto_flutter/screens/initialization_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login_screen.dart';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textFieldContentPadding = const EdgeInsets.symmetric(
    vertical: 13,
    horizontal: 15,
  );
  final _textFieldColor = Colors.grey[200];
  var _hidePassword = true;
  var _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  SnackBar errorSnackBar(
      {required String errorMessage, required BuildContext context}) {
    return SnackBar(
      elevation: 100,
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      content: Text(errorMessage),
      action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
          }),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }

  Future _logUserIn() async {
    bool _isValid = _formKey.currentState!.validate();
    if (!_isValid) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      const _signInEndpoint = '${ApiUrl.baseURL}v1/login';
      final _uri = Uri.parse(_signInEndpoint);
      final header = ApiUrl.setNoTokenHeaders();
      final _deviceInfo =
          await Provider.of<AuthProvider>(context, listen: false)
              .getDeviceInfo();
      final response = await http.post(
        _uri,
        body: json.encode({
          "email": _emailController.text,
          "password": _passwordController.text,
          "ip_address": _deviceInfo,
          "device_name": _deviceInfo,
        }),
        headers: header,
      );
      final res = json.decode(response.body);
      print(res);
      //  Sign in was successful and Auth device was used
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (res["success"] == true || res["success"] == false)) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.remove('token');
        localStorage.setString('token', res['token']['token']);
        Navigator.of(context)
            .pushReplacementNamed(InitializationScreen.routeName);
      } else if ((response.statusCode == 200 || response.statusCode == 201) &&
          res["success"] == false &&
          res["user"]["two_fa_status"].toString() == '1') {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.remove('token');
        localStorage.setString('token', res['token']['token']);
        // Remember
        Navigator.of(context).pushReplacementNamed(Auth2FaScreen.routeName);
        // Navigator.of(context)
        //     .pushReplacementNamed(InitializationScreen.routeName);
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: res['message'], context: context),
        );
      } else if (response.statusCode == 422) {
        Alert.showerrorDialog(
            context: context,
            text: res['message'] ?? 'An error occured',
            onPressed: (() {
              Navigator.of(context).pop();
            }));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          errorSnackBar(
            errorMessage: 'Login unsuccessful, An error occured',
            context: context,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        errorSnackBar(errorMessage: error.toString(), context: context),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: deviceHeight * 0.1,
                ),
                SizedBox(
                  width: double.infinity,
                  height: deviceHeight * 0.05,
                  child: const Text(
                    'Welcome Back !',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: deviceHeight * 0.05,
                  child: const FittedBox(
                    child: Text(
                      'Please provide your details to continue using Kasheto.',
                    ),
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.05,
                ),
                const TextFieldText(text: 'Email Address'),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field can\'t be empty';
                    } else if (!value.contains('@')) {
                      return 'Enter a valid email';
                    } else {
                      return null;
                    }
                  },
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: _textFieldContentPadding,
                    filled: true,
                    fillColor: _textFieldColor,
                    hintText: 'sample@mail.com',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const TextFieldText(text: 'Password'),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field can\'t be empty';
                    } else {
                      return null;
                    }
                  },
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: !_hidePassword
                          ? null
                          : () async {
                              setState(() {
                                _hidePassword = false;
                              });
                              await Future.delayed(
                                const Duration(seconds: 2),
                              );
                              setState(() {
                                _hidePassword = true;
                              });
                            },
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: _hidePassword ? Colors.green : Colors.grey,
                      ),
                    ),
                    filled: true,
                    fillColor: _textFieldColor,
                    isDense: true,
                    contentPadding: _textFieldContentPadding,
                    hintText: 'password',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(ForgotPasswordScreen.routeName);
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                        ),
                      ),
                    )
                  ],
                ),
                const Spacer(),
                if (_isLoading)
                  const Center(
                    child: LoadingSpinnerWithMargin(),
                  ),
                if (!_isLoading)
                  SubmitButton(
                    action: () {
                      _logUserIn();
                    },
                    title: 'Login',
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            SignupScreen.routeName, (route) => false);
                      },
                      child: const Text(
                        ' Sign Up',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.green,
                          decorationThickness: 2,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
