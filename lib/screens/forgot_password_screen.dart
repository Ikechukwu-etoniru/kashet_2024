import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forget_password_screen.dart';
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;

  Future _sendEmailToResetPassword() async {
    final _isValid = _formKey.currentState!.validate();
    if (_isValid) {
      try {
        setState(() {
          _isLoading = true;
        });
        final _url = Uri.parse('${ApiUrl.baseURL}password/email');
        final _body = json.encode({'email': _emailController.text});
        _setHeaders() =>
            {"Content-type": "application/json", "Accept": "application/json"};

        final _response =
            await http.post(_url, body: _body, headers: _setHeaders());
        final res = json.decode(_response.body);
       if (_response.statusCode == 200 && res['msg'] != null) {
          Alert.showSuccessDialog(
              context: context,
              text: res['msg'],
              onPressed: () {
                Navigator.of(context).pop();
              });
        } else if (res['success'] == false) {
          Alert.showSuccessDialog(
              context: context,
              text: res['message'],
              onPressed: () {
                Navigator.of(context).pop();
              });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              Alert.snackBar(message: ApiUrl.errorString, context: context));
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: 'An error occurred', context: context));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Center(
              child: Container(
                padding: const EdgeInsets.only(
                    top: 40, bottom: 10, left: 15, right: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          spreadRadius: 3,
                          blurRadius: 7),
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          spreadRadius: 5,
                          blurRadius: 15),
                    ]),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Forgot your password ?',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Confirm your email and we will send you instructions to reset your password',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'This field cannot be empty';
                          } else if (!value.contains('@')) {
                            return 'Enter a valid email';
                          } else {
                            return null;
                          }
                        }),
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          contentPadding: MyPadding.textFieldContentPadding,
                          errorStyle: const TextStyle(fontSize: 10),
                          filled: true,
                          fillColor: MyColors.textFieldColor,
                          hintText: 'Example@gmail.com',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (_isLoading) const LoadingSpinnerWithMargin(),
                      if (!_isLoading)
                        SubmitButton(
                            action: () {
                              _sendEmailToResetPassword();
                            },
                            title: 'Continue')
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
