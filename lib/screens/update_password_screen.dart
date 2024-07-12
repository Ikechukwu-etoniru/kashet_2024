import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/utils/alerts.dart';

import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';

class UpdatePasswordScreen extends StatefulWidget {
  static const routeName = '/update_password_screen.dart';
  const UpdatePasswordScreen({Key? key}) : super(key: key);

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  var _isLoading = false;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _textFieldContentPadding = MyPadding.textFieldContentPadding;
  final _textFieldColor = MyColors.textFieldColor;
  var _hidePassword = true;
  var _hidePassword1 = true;
  var _hidePassword2 = true;
  final _formKey = GlobalKey<FormState>();

  void _changePassword() async {
    final _isValid = _formKey.currentState!.validate();
    if (_isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        final url = Uri.parse('${ApiUrl.baseURL}user/profile/update-password');
        final _header = await ApiUrl.setHeaders();
        final _response = await http.post(url,
            headers: _header,
            body: json.encode({
              "old_password": _oldPasswordController.text,
              "password": _newPasswordController.text,
              "password_confirmation": _confirmPasswordController.text
            }));
        final _res = json.decode(_response.body);

        if (_response.statusCode == 200 && _res["data"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(
                message: 'Your password has been changed successfully',
                context: context),
          );
          // Navigator.of(context).pop();
        } else if (_response.statusCode == 422) {
          ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: _res['message'], context: context),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              Alert.snackBar(message: ApiUrl.errorString, context: context));
        }
      } on SocketException {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: ApiUrl.internetErrorString, context: context),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: ApiUrl.errorString, context: context),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Update Password'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldText(text: 'Old Password'),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _oldPasswordController,
                  style: const TextStyle(
                    letterSpacing: 5,
                    fontSize: 13,
                  ),
                  validator: ((value) {
                    String pattern =
                        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                    RegExp regExp = RegExp(pattern);

                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    } else if (regExp.hasMatch(value) == false) {
                      return 'Password must contain an uppercase letter,\nlowercase letter, number and special character';
                    } else {
                      return null;
                    }
                  }),
                  obscureText: _hidePassword,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
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
                    hintText: '........',
                    hintStyle:
                        const TextStyle(color: Colors.grey, letterSpacing: 5),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const TextFieldText(text: 'New Password'),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  style: const TextStyle(
                    letterSpacing: 5,
                    fontSize: 13,
                  ),
                  controller: _newPasswordController,
                  validator: ((value) {
                    String pattern =
                        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                    RegExp regExp = RegExp(pattern);

                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    } else if (regExp.hasMatch(value) == false) {
                      return 'Password must contain an uppercase letter,\nlowercase letter, number and special character';
                    } else {
                      return null;
                    }
                  }),
                  obscureText: _hidePassword1,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: !_hidePassword1
                          ? null
                          : () async {
                              setState(() {
                                _hidePassword1 = false;
                              });
                              await Future.delayed(
                                const Duration(seconds: 2),
                              );
                              setState(() {
                                _hidePassword1 = true;
                              });
                            },
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: _hidePassword1 ? Colors.green : Colors.grey,
                      ),
                    ),
                    filled: true,
                    fillColor: _textFieldColor,
                    isDense: true,
                    contentPadding: _textFieldContentPadding,
                    hintText: '........',
                    hintStyle:
                        const TextStyle(color: Colors.grey, letterSpacing: 5),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const TextFieldText(text: 'Confirm Password'),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  style: const TextStyle(
                    letterSpacing: 5,
                    fontSize: 13,
                  ),
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    } else if (_newPasswordController.text != value) {
                      return 'Passwords must match';
                    } else {
                      return null;
                    }
                  }),
                  obscureText: _hidePassword2,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: !_hidePassword2
                          ? null
                          : () async {
                              setState(() {
                                _hidePassword2 = false;
                              });
                              await Future.delayed(
                                const Duration(seconds: 2),
                              );
                              setState(() {
                                _hidePassword2 = true;
                              });
                            },
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: _hidePassword2 ? Colors.green : Colors.grey,
                      ),
                    ),
                    filled: true,
                    fillColor: _textFieldColor,
                    isDense: true,
                    contentPadding: _textFieldContentPadding,
                    hintText: '........',
                    hintStyle:
                        const TextStyle(color: Colors.grey, letterSpacing: 5),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const Spacer(),
                if (_isLoading) const LoadingSpinnerWithMargin(),
                if (!_isLoading)
                  SubmitButton(
                      action: () {
                        _changePassword();
                      },
                      title: 'Save Changes')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
