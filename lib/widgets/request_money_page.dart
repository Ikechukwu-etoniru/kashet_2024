import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/provider/transaction_provider.dart';
import 'package:kasheto_flutter/screens/initialization_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/dialog_chip.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';

class RequestMoneyPage extends StatefulWidget {
  const RequestMoneyPage({Key? key}) : super(key: key);

  @override
  State<RequestMoneyPage> createState() => _RequestMoneyPageState();
}

class _RequestMoneyPageState extends State<RequestMoneyPage> {
  final _textFieldContentPadding = const EdgeInsets.all(10);
  final _textFieldColor = Colors.grey[200];
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _isNameLoading = false;
  String? _receiverName;
  String? _receiverId;
  var _dropDownValue = 'NGN';
  var _ktcDropDownValue = 'KTC';
  String? _ktcAmount = '0.00';

  Future<bool> _checkUser() async {
    setState(() {
      _isNameLoading = true;
    });
    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/profile/get-user-email');
      final _header = await ApiUrl.setHeaders();
      final _body = json.encode({"email": _emailController.text});
      final response = await http.post(url, headers: _header, body: _body);
      final res = json.decode(response.body);
      if (res['is_valid'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(
              message: 'Recepient email could not be validated',
              context: context),
        );
        return false;
      } else if (res['is_valid'] == true && response.statusCode == 200) {
        setState(() {
          _receiverName = res['user']['name'];
        });
        _receiverId = res['user']['id'].toString();
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(
              message:
                  'Recepient email could not be confirmed, Confirm details or try again later',
              context: context),
        );
        return false;
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert.snackBar(
            message:
                'Recepient email could not be confirmed, Confirm details or try again later',
            context: context),
      );
      return false;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert.snackBar(
            message:
                'Recepient email could not be confirmed, Confirm details or try again later',
            context: context),
      );
      return false;
    } finally {
      setState(() {
        _isNameLoading = false;
      });
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

  Future _requestMoney() async {
    FocusScope.of(context).unfocus();
    try {
      final _isUserValid = await _checkUser();
      if (!_isUserValid) {
        return;
      }
      setState(() {
        _isLoading = true;
      });
      final _isAgreed = await _requestMoneyBottomSheet(
          currency: _dropDownValue,
          context: context,
          recepientName: _receiverName!,
          amount: _amountController.text,
          ktcValue: _ktcAmount!,
          userId: _receiverId!,
          description: _descriptionController.text);
      if (_isAgreed != null || _isAgreed! == true) {
        final response =
            await Provider.of<TransactionProvider>(context, listen: false)
                .requestMoneyFromUser(
                    context: context,
                    userId: _receiverId!,
                    amount: _amountController.text,
                    ktcValue: _ktcAmount!,
                    description: _descriptionController.text);
        if (response.isNotEmpty) {
          Alert.showSuccessDialog(
              context: context,
              text: 'You have successfully requested money from $_receiverName',
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    InitializationScreen.routeName, (route) => false);
              });
        }
      }
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
                Focus(
                  onFocusChange: (value) {
                    if (!value) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                  child: TextFormField(
                    controller: _emailController,
                    onFieldSubmitted: (value) async {
                      FocusScope.of(context).unfocus();
                    },
                    validator: ((value) {
                      if (value == null || value.isEmpty) {
                        return 'This field cannot be empty';
                      } else if (!value.contains('@')) {
                        return 'Enter a valid';
                      } else {
                        return null;
                      }
                    }),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    decoration: InputDecoration(
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
                ),
                const SizedBox(
                  height: 15,
                ),
                const TextFieldText(text: 'Receipient Name'),
                const SizedBox(
                  height: 5,
                ),
                if (_isNameLoading)
                  const Center(
                    child: SpinKitDoubleBounce(
                      color: MyColors.primaryColor,
                      size: 30,
                    ),
                  ),
                if (!_isNameLoading)
                  InkWell(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        Alert.snackBar(
                            message: 'This field will be dynamically filled',
                            context: context),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: MyPadding.textFieldContentPadding,
                      decoration: BoxDecoration(
                        color: MyColors.textFieldColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _receiverName ?? 'Recepient Name',
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 15,
                ),
                const TextFieldText(text: 'Amount Requested'),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: 45,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: MyColors.textFieldColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _dropDownValue == 'NGN' ? '₦' : '\$',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14, fontFamily: ''),
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
                          } else if (double.parse(value) <= 999.99) {
                            return 'Enter a value greater than or equal to 1000';
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
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          counterStyle: const TextStyle(
                            height: double.minPositive,
                          ),
                          counterText: "",
                          filled: true,
                          fillColor: MyColors.textFieldColor,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          hintText: '0.00',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      alignment: Alignment.center,
                      width: 65,
                      height: 40,
                      decoration: BoxDecoration(
                        color: MyColors.textFieldColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton(
                        focusColor: Colors.black,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          size: 18,
                        ),
                        iconEnabledColor: Colors.grey,
                        iconDisabledColor: Colors.grey,
                        underline: const SizedBox(),
                        elevation: 0,
                        hint: Text(
                          _dropDownValue,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        isExpanded: true,
                        items: ['NGN', 'USD'].map(
                          (val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(
                                val,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (val) {
                          setState(
                            () {
                              _dropDownValue = val as String;
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const TextFieldText(text: 'You\'ll Get'),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: 45,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                    const SizedBox(
                      width: 2,
                    ),
                    Expanded(
                      child: TextFormField(
                        enabled: false,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          filled: true,
                          fillColor: _textFieldColor,
                          isDense: true,
                          hintText: _ktcAmount,
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 1,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const TextFieldText(text: 'Description'),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    } else {
                      return null;
                    }
                  }),
                  onSaved: (value) {},
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    contentPadding: _textFieldContentPadding,
                    isDense: true,
                    hintText: 'Provide a payment description',
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Text(
                      'The current exhange rate is',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'NGN 1 = KTC ${Provider.of<PlatformChargesProvider>(context, listen: false).nairaToKtc}',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (_isLoading) const LoadingSpinnerWithMargin(),
                if (!_isLoading)
                  SubmitButton(
                      action: () {
                        bool _value = _formKey.currentState!.validate();
                        if (!_value) {
                          return;
                        }
                        _requestMoney();
                      },
                      title: 'Continue'),
              ],
            ),
          ),
          // ),
        );
      }),
    );
  }
}

Future<bool?> _requestMoneyBottomSheet(
    {required BuildContext context,
    required String recepientName,
    required String amount,
    required String ktcValue,
    required String userId,
    required String description,
    required String currency}) async {
  return showModalBottomSheet<bool>(
      elevation: 30,
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 10),
                  height: 3,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const Text(
                  'Request Money',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You are about to request money.',
                  textAlign: TextAlign.center,
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Receipient Name'),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        recepientName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text('Amount Requested'),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        '₦ $amount',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontFamily: ''),
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text('You\'ll Get'),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'k $ktcValue',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(description)
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Spacer(),
                    DialogChip(
                        onTap: () {
                          Navigator.of(_).pop(false);
                        },
                        text: 'Cancel',
                        color: Colors.red),
                    const SizedBox(
                      width: 15,
                    ),
                    DialogChip(
                        onTap: () {
                          Navigator.of(_).pop(true);
                        },
                        text: 'Continue',
                        color: Colors.green),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        );
      });
}
