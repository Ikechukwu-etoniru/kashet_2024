import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kasheto_flutter/models/user.dart';
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/provider/wallet_provider.dart';
import 'package:kasheto_flutter/screens/payment_option_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({Key? key}) : super(key: key);

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final _textFieldContentPadding = const EdgeInsets.all(10);
  final _textFieldColor = Colors.grey[200];
  String _dropDownValue = 'NGN';
  String _ktcDropDownValue = 'KTC';
  final _amountController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _receiverName;
  String? _receiverId;

  bool? _isEmailvalid;
  String? _ktcAmount = '0.00';

  var _isLoading = false;

  User get user {
    return Provider.of<AuthProvider>(context, listen: false).userList[0];
  }

  Future<void> _sendMoney() async {
    bool _isValid = _formKey.currentState!.validate();

    if (_isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        final userStatus = await _checkUser();
        if (!userStatus) {
          return;
        }
        final receiverDetails = SendUserDetails(
          amount: _amountController.text.trim(),
          currency: 'NGN',
          email: _emailController.text.trim(),
          ktcValue: _ktcAmount!,
          name: _receiverName!,
          user: _receiverId!,
          charges: _charges,
        );

        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return PaymentOptionScreen(
            receiver: receiverDetails,
          );
        }));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: error.toString(), context: context),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String get _charges {
    return Provider.of<PlatformChargesProvider>(context, listen: false)
        .depositCharges(_amountController.text)
        .toString();
  }

  Future<bool> _checkUser() async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/profile/get-user-email');
      final _header = await ApiUrl.setHeaders();
      final _body = json.encode({"email": _emailController.text});
      final response = await http.post(url, headers: _header, body: _body);
      final res = json.decode(response.body);

      if (res['is_valid'] == false) {
        setState(() {
          _isEmailvalid = false;
          ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
              message: 'No kasheto user with the entered email address exists',
              context: context));
        });
        return false;
      } else if (res['is_valid'] == true && response.statusCode == 200) {
        _receiverName = res['user']['name'];
        _receiverId = res['user']['id'].toString();
        setState(() {
          _isEmailvalid = true;
        });
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  void _getKtcAmount() {
    if (_amountController.text.isEmpty) {
      _ktcAmount = '0.00';
    }
    final _naira2ktc =
        Provider.of<PlatformChargesProvider>(context, listen: false).nairaToKtc;
    final _amount = double.parse(_amountController.text) * _naira2ktc;
    _ktcAmount = _amount.toString();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  num get _walletBalance {
    return Provider.of<WalletProvider>(context, listen: false).walletBalance;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        return Form(
          key: _formKey,
          child: SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: ListView(
              children: [
                const SizedBox(
                  height: 10,
                ),
                const TextFieldText(text: 'Receipient Email'),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _emailController,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (value) async {
                    FocusScope.of(context).unfocus();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {},
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    suffixIcon: _isEmailvalid == null
                        ? const SizedBox()
                        : _isEmailvalid != null && _isEmailvalid!
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 12),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  height: 20,
                                  width: 20,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : _isEmailvalid != null && _isEmailvalid! == false
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 12),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle),
                                      height: 20,
                                      width: 20,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                    contentPadding: _textFieldContentPadding,
                    isDense: true,
                    hintText: 'sample@gmail.com',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: _textFieldColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none),
                  ),
                ),
                if (_isEmailvalid != null && _isEmailvalid!)
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        _receiverName!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                const SizedBox(
                  height: 20,
                ),
                const TextFieldText(text: 'You\'re Sending'),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: 50,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: MyColors.textFieldColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _dropDownValue == 'NGN' ? '₦' : '\$',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 15, fontFamily: ''),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        maxLength: 19,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field shouldn\'t be empty';
                          } else if (double.tryParse(value) == null) {
                            return 'Enter valid number';
                          } else if (double.parse(value) <= 1) {
                            return 'Enter value above 999.99';
                          } else if (double.parse(_ktcAmount!) >
                              _walletBalance) {
                            return 'You have insufficient Kasheto funds';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            _getKtcAmount();
                          });
                        },
                        controller: _amountController,
                        decoration: InputDecoration(
                          counterStyle: const TextStyle(
                            height: double.minPositive,
                          ),
                          counterText: "",
                          filled: true,
                          fillColor: MyColors.textFieldColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          hintText: '0.00',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),

                    //  Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 5),
                    //     alignment: Alignment.center,
                    //     width: constraints.maxWidth * 0.23,
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(5),
                    //     ),
                    //     child: DropdownButton(
                    //       focusColor: Colors.black,
                    //       icon: const Icon(Icons.keyboard_arrow_down),
                    //       iconEnabledColor: Colors.grey,
                    //       iconDisabledColor: Colors.grey,
                    //       underline: const SizedBox(),
                    //       elevation: 0,
                    //       hint: Text(_dropDownValue),
                    //       isExpanded: true,
                    //       items: [
                    //         'NGN'
                    //         //  'USD'
                    //       ].map(
                    //         (val) {
                    //           return DropdownMenuItem<String>(
                    //             value: val,
                    //             child: Text(val),
                    //           );
                    //         },
                    //       ).toList(),
                    //       onChanged: (val) {
                    //         setState(
                    //           () {
                    //             _dropDownValue = val as String;
                    //           },
                    //         );
                    //       },
                    //     ),
                    //   ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const TextFieldText(text: 'Recepient Get'),
                    const Spacer(),
                    Text(
                      'k ${_walletBalance.toString()}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: '',
                        fontSize: 11,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: 50,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: MyColors.textFieldColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'k',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontFamily: '',
                        ),
                      ),
                    ),
                    TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: constraints.maxWidth * 0.2),
                        filled: true,
                        fillColor: _textFieldColor,
                        isDense: true,
                        hintText: _ktcAmount,
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: constraints.maxWidth * 0.15,
                      height: 50,
                      child: Text(
                        _ktcDropDownValue == 'KTC' ? 'K' : '\$',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontFamily: '',
                        ),
                      ),
                    ),
                    // Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 5),
                    //     alignment: Alignment.center,
                    //     width: constraints.maxWidth * 0.23,
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(5),
                    //     ),
                    //     child: DropdownButton(
                    //       focusColor: Colors.black,
                    //       icon: const Icon(Icons.keyboard_arrow_down),
                    //       iconEnabledColor: Colors.grey,
                    //       iconDisabledColor: Colors.grey,
                    //       underline: const SizedBox(),
                    //       elevation: 0,
                    //       hint: Text(_ktcDropDownValue),
                    //       isExpanded: true,
                    //       items: ['KTC'].map(
                    //         (val) {
                    //           return DropdownMenuItem<String>(
                    //             value: val,
                    //             child: Text(val),
                    //           );
                    //         },
                    //       ).toList(),
                    //       onChanged: (val) {
                    //         setState(
                    //           () {
                    //             _ktcDropDownValue = val as String;
                    //           },
                    //         );
                    //       },
                    //     ),
                    //   ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Text(
                      'The current exhange rate is',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    Text(
                      'NGN 1 = KTC ${Provider.of<PlatformChargesProvider>(context, listen: false).nairaToKtc}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Text('Total Amount'),
                    const Spacer(),
                    Text(
                      '₦${_amountController.text}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontFamily: ''),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                if (_isLoading) const LoadingSpinnerWithMargin(),
                if (!_isLoading)
                  SubmitButton(
                    action: _isLoading ? () {} : _sendMoney,
                    title: 'Continue',
                  )
              ],
            ),
          ),
        );
      }),
    );
  }
}
