import 'package:flutter/material.dart';
import 'package:kasheto_flutter/models/user.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:provider/provider.dart';

class EditEmailScreen extends StatefulWidget {
  static const routeName = '/edit_email_screen.dart';
  const EditEmailScreen({Key? key}) : super(key: key);

  @override
  State<EditEmailScreen> createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  final _newEmailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  var _isLoading = false;

  Future _changeEmail() async {}

  User get user {
    return Provider.of<AuthProvider>(context).userList[0];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Old Email',
                style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.5),
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                enabled: false,
                initialValue: user.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: MyColors.textFieldColor,
                  isDense: true,
                  contentPadding: MyPadding.textFieldContentPadding,
                  hintText: user.emailAddress,
                  hintStyle: const TextStyle(color: Colors.black),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'New Email',
                style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.5),
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                style: const TextStyle(letterSpacing: 5),
                controller: _newEmailController,
                validator: ((value) {
                  if (value == null || value.isEmpty) {
                    return 'This field cannot be empty';
                  } else if (!value.contains('@')) {
                    return 'This field cannot be empty';
                  } else {
                    return null;
                  }
                }),
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: MyColors.textFieldColor,
                  isDense: true,
                  contentPadding: MyPadding.textFieldContentPadding,
                  hintText: 'Example@gmail.com',
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
              const Spacer(),
              if (_isLoading) const LoadingSpinnerWithMargin(),
              if (!_isLoading)
                SubmitButton(
                    action: () {
                      _changeEmail();
                    },
                    title: 'Save Changes')
            ],
          ),
        ),
      ),
    );
  }
}
