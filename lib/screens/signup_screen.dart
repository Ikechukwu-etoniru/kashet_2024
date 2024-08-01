import 'package:flutter/material.dart';
import 'package:kasheto_flutter/models/http_exceptions.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/initialization_screen.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';
import 'package:country_code_picker/country_code_picker.dart';

import '/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup_screen.dart';
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _textFieldContentPadding = const EdgeInsets.all(10);
  final _textFieldColor = Colors.grey[200];
  var _hidePassword = true;
  var _hidePassword1 = true;
  final phoneNumberController = TextEditingController();
  String countryCode = '+1';

  bool checkBoxVal = false;

  var _isLoading = false;

  Future _saveForm() async {
    bool isValid = _formKey.currentState!.validate();
    // if country code is null show message
    if (isValid) {
      setState(() {
        _isLoading = true;
      });

      try {
        final isSaved =
            await Provider.of<AuthProvider>(context, listen: false).signUserUp(
          firstName: firstNameController.text,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          countryCode: countryCode,
          userNumber: phoneNumberController.text.trim(),
          password: passwordController.text.trim(),
          context: context,
        );

        if (isSaved) {
          Navigator.of(context)
              .pushReplacementNamed(InitializationScreen.routeName);
        }
      } catch (error) {
        throw AppException('An error occured');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _deviceWidth = MediaQuery.of(context).size.width;
    final _deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Sign Up',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      const TextFieldText(
                        text: 'First Name',
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        controller: firstNameController,
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'This field cannot be empty';
                          } else {
                            return null;
                          }
                        }),
                        keyboardType: TextInputType.name,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          contentPadding: _textFieldContentPadding,
                          isDense: true,
                          hintText: 'First name',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const TextFieldText(
                        text: 'Last Name',
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        textCapitalization: TextCapitalization.words,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        controller: nameController,
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'This field cannot be empty';
                          } else {
                            return null;
                          }
                        }),
                        keyboardType: TextInputType.name,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          contentPadding: _textFieldContentPadding,
                          isDense: true,
                          hintText: 'Last name',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const TextFieldText(text: 'Email Address'),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        controller: emailController,
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'This field cannot be empty';
                          } else if (!value.contains('@')) {
                            return 'Enter a valid Email';
                          } else {
                            return null;
                          }
                        }),
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          contentPadding: _textFieldContentPadding,
                          isDense: true,
                          fillColor: _textFieldColor,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          hintText: 'sample@mail.com',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const TextFieldText(text: 'Phone Number'),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          CountryCodePicker(
                            onChanged: (value) {
                              countryCode = value.toString();
                            },
                            backgroundColor: _textFieldColor,
                            initialSelection: 'US',
                            dialogSize:
                                Size(_deviceWidth * 0.8, _deviceHeight * 0.8),
                            dialogBackgroundColor: MyColors.textFieldColor,
                          ),
                          Expanded(
                            child: TextFormField(
                              style: const TextStyle(
                                  letterSpacing: 3, fontSize: 13),
                              validator: ((value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field cannot be empty';
                                } else if (int.tryParse(value) == null) {
                                  return 'Enter a valid number';
                                } else if (value.length > 10) {
                                  return 'Phone number too long';
                                } else if (value.length < 10) {
                                  return 'Phone number too short';
                                } else if (value.startsWith('0') &&
                                    countryCode == '+234') {
                                  return 'Use country code format';
                                } else {
                                  return null;
                                }
                              }),
                              controller: phoneNumberController,
                              onFieldSubmitted: (value) {
                                FocusScope.of(context).unfocus();
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: _textFieldContentPadding,
                                filled: true,
                                fillColor: _textFieldColor,
                                isDense: true,
                                hintText: 'xxx xxx xxxx',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const TextFieldText(
                        text: 'Password',
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        style: const TextStyle(letterSpacing: 5),
                        controller: passwordController,
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
                          hintStyle: const TextStyle(
                              color: Colors.grey, letterSpacing: 5),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const TextFieldText(
                        text: 'Confirm Password',
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        style: const TextStyle(letterSpacing: 5),
                        validator: ((value) {
                          if (passwordController.text != value) {
                            return 'Passwords must match';
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
                              color: _hidePassword ? Colors.green : Colors.grey,
                            ),
                          ),
                          filled: true,
                          fillColor: _textFieldColor,
                          isDense: true,
                          contentPadding: _textFieldContentPadding,
                          hintText: '........',
                          hintStyle: const TextStyle(
                              color: Colors.grey, letterSpacing: 5),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Checkbox(
                              value: checkBoxVal,
                              onChanged: (val) {
                                setState(() {
                                  checkBoxVal = val!;
                                });
                              },
                              activeColor: MyColors.primaryColor,
                              ),
                          const Expanded(
                            child: Text(
                              'Confirm if you would like to receive SMS notifications from us.',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Showing loading spinner when signing up
                if (_isLoading) const LoadingSpinnerWithMargin(),
                if (!_isLoading)
                  SubmitButton(
                    action: () {
                      _saveForm();
                    },
                    title: 'Sign Up',
                    noLowPadding: true,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(LoginScreen.routeName);
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.only(left: 3),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          decorationThickness: 2,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
