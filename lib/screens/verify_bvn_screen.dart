import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/screens/initialization_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';

class VerifyBvnScreen extends StatefulWidget {
  static const routeName = '/verify_bvn_screen.dart';
  const VerifyBvnScreen({Key? key}) : super(key: key);

  @override
  State<VerifyBvnScreen> createState() => _VerifyBvnScreenState();
}

class _VerifyBvnScreenState extends State<VerifyBvnScreen> {
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  var bvnController = TextEditingController();
  Future<void> _sendBvn() async {
    final _isValid = _formKey.currentState!.validate();
    if (!_isValid) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/profile/bvn_verified');
      final _header = await ApiUrl.setHeaders();

      final response = await http.post(
        url,
        headers: _header,
        body: json.encode({'bvn': bvnController.text}),
      );
      final res = json.decode(response.body);
      if (response.statusCode == 200 && res['success'] == "true") {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: res['message'], context: context),
        );
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context)
              .pushReplacementNamed(InitializationScreen.routeName);
        });
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Add Your BVN'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Center(
                    child: Image.asset(
                      'images/bvn_icon.png',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Amount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: bvnController,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    } else if (value.length != 11) {
                      return 'A valid BVN has 11 digits';
                    } else {
                      return null;
                    }
                  }),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: MyPadding.textFieldContentPadding,
                    isDense: true,
                    fillColor: MyColors.textFieldColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    hintText: 'Add your BVN',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Spacer(),
                if (_isLoading) const LoadingSpinnerWithMargin(),
                if (!_isLoading)
                  SubmitButton(
                      action: () {
                        _sendBvn();
                      },
                      title: 'Submit')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
