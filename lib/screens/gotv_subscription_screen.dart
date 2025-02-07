import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/provider/billing_provider.dart';
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/provider/wallet_provider.dart';
import 'package:kasheto_flutter/screens/main_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/widgets/dialog_chip.dart';
import 'package:kasheto_flutter/widgets/dialog_row.dart';
import 'package:kasheto_flutter/widgets/error_widget.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/my_dropdown.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';

import '../models/billings.dart';

class GotvSubscriptionScreen extends StatefulWidget {
  static const routeName = '/gotv_subscription_screen.dart';
  const GotvSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<GotvSubscriptionScreen> createState() => _GotvSubscriptionScreenState();
}

class _GotvSubscriptionScreenState extends State<GotvSubscriptionScreen> {
  final _textFieldContentPadding = const EdgeInsets.all(10);
  final _cardController = TextEditingController();
  var _isButtonLoading = false;
  String? _dropDownValue;
  var _isLoading = false;
  var _isError = false;
  final _formKey = GlobalKey<FormState>();
  List<GotvPlan>? _gotvplanList;
  GotvPlan? _choosenGotvplan;

  String _getAmount(String subType, BuildContext context) {
    _gotvplanList =
        Provider.of<BillingProvider>(context, listen: false).gotvPlans;
    var _gotvPlan = _gotvplanList!.firstWhere((element) {
      return element.name == subType;
    });
    _choosenGotvplan = _gotvPlan;
    return _gotvPlan.amount;
  }

  double? _ktcAmount;

  String _getKtcAmount(String subType, BuildContext context) {
    final _nairaAmount = double.parse(_getAmount(subType, context));
    final _nairaToKtc =
        Provider.of<PlatformChargesProvider>(context).nairaToKtc;
    _ktcAmount = _nairaAmount * _nairaToKtc;
    return _ktcAmount.toString();
  }

  num get _walletBalance {
    return Provider.of<WalletProvider>(context, listen: false).walletBalance;
  }

  Future _validateGotv() async {
    final _isValid = _formKey.currentState!.validate();
    if (_isValid && _ktcAmount! > _walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message: 'You have insufficient Kasheto funds to purchse this plan',
          context: context));
    } else if (_isValid) {
      final _isConfirmed = await _confirmationDialog(
          context: context,
          amount: _choosenGotvplan!.amount,
          subName: _choosenGotvplan!.name,
          subNumber: _cardController.text);

      if (_isConfirmed != null && _isConfirmed) {
        _subscribeGotv();
      }
    }
  }

  Future _subscribeGotv() async {
    try {
      setState(() {
        _isButtonLoading = true;
      });
      final _userCurrency = Provider.of<AuthProvider>(context, listen: false)
          .userList[0]
          .userCurrency;
      final url = Uri.parse('${ApiUrl.baseURL}user/bills/paybills');
      final _header = await ApiUrl.setHeaders();
      final _ktcValue = _getKtcAmount(_choosenGotvplan!.name, context);
      final _body = json.encode({
        'card_number': _cardController.text,
        'amount': _choosenGotvplan!.amount,
        'ktc_value': _ktcValue,
        'plan_id': _choosenGotvplan!.id,
        'currency': _userCurrency,
      });
      final _response = await http.post(url, headers: _header, body: _body);
      final res = json.decode(_response.body);

      if (_response.statusCode == 200 && res['status'] == 'success') {
        Provider.of<WalletProvider>(context, listen: false)
            .reduceKtcWalletBalance(double.parse(_ktcValue));
        await Alert.showSuccessDialog(
            context: context,
            text: 'Your GOTV subscription was successful',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  MainScreen.routeName, (route) => false);
            });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: ApiUrl.errorString, context: context),
        );
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
        _isButtonLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future _loadDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<BillingProvider>(context, listen: false).getGotvPlans();
      _gotvplanList =
          Provider.of<BillingProvider>(context, listen: false).gotvPlans;
    } catch (error) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final platformCharges = Provider.of<PlatformChargesProvider>(context);
    return _isLoading
        ? const LoadingSpinnerWithScaffold()
        : _isError
            ? const IsErrorScreen()
            : SafeArea(
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    title: const Text('GOTV'),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          const TextFieldText(text: 'Decoder Number (ICU)'),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: _cardController,
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty';
                              } else if (int.tryParse(value) == null) {
                                return 'Enter a valid number';
                              }
                              // else if (value.length != 11) {
                              //   return 'Enter a valid number';
                              // }
                              else {
                                return null;
                              }
                            }),
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).unfocus();
                            },
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                            decoration: InputDecoration(
                              contentPadding: _textFieldContentPadding,
                              filled: true,
                              fillColor: MyColors.textFieldColor,
                              isDense: true,
                              hintText: 'E.g 88135467889',
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
                          const SizedBox(
                            height: 20,
                          ),
                          const TextFieldText(text: 'Select Subscription Plan'),
                          const SizedBox(
                            height: 5,
                          ),
                          MyDropDown(
                            items: _gotvplanList!.map((e) {
                              return DropdownMenuItem(
                                value: e.name,
                                child: Text(
                                  e.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                            value: _dropDownValue,
                            onChanged: (val) {
                              setState(
                                () {
                                  _dropDownValue = val as String?;
                                },
                              );
                            },
                            hint: _dropDownValue == null
                                ? const FittedBox(
                                    child: Text(
                                      'Select plan',
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : FittedBox(
                                    child: Text(
                                      _dropDownValue!,
                                    ),
                                  ),
                            validator: (value) {
                              if (value == null) {
                                return 'Select a subscription plan';
                              } else {
                                return null;
                              }
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const TextFieldText(text: 'Amount'),
                          const SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_dropDownValue == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  Alert.snackBar(
                                      message:
                                          'You haven\'t choose a subscription plan yet',
                                      context: context),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: MyColors.textFieldColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Row(
                                children: [
                                  const Text(
                                    '₦',
                                    style: TextStyle(
                                        fontFamily: '',
                                        fontSize: 14,
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    _dropDownValue == null
                                        ? '0.0'
                                        : _getAmount(_dropDownValue!, context),
                                    style: const TextStyle(
                                      fontFamily: '',
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const TextFieldText(text: 'Value in KTC'),
                          const SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_dropDownValue == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  Alert.snackBar(
                                      message:
                                          'You haven\'t choose a subscription plan yet',
                                      context: context),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: MyColors.textFieldColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Row(
                                children: [
                                  const Text(
                                    'K',
                                    style: TextStyle(
                                      fontFamily: '',
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    _dropDownValue == null
                                        ? '0.0'
                                        : _getKtcAmount(
                                            _dropDownValue!, context),
                                    style: const TextStyle(
                                      fontFamily: '',
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              const Text(
                                'The current exhange rate is',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                '1 NGN = ${platformCharges.nairaToKtc} KTC',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (_isButtonLoading)
                            const LoadingSpinnerWithMargin(),
                          if (!_isButtonLoading)
                            SubmitButton(
                                action: () {
                                  _validateGotv();
                                },
                                title: 'Continue')
                        ],
                      ),
                    ),
                  ),
                ),
              );
  }
}

Future<bool?> _confirmationDialog({
  required BuildContext context,
  required String amount,
  required String subName,
  required String subNumber,
}) {
  return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 30,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Confirm GOTV Subscribtion !!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(thickness: 1),
                DialogRow(title: 'Amount', content: amount),
                const Divider(thickness: 1),
                DialogRow(title: 'Subscribtion Name', content: subName),
                const Divider(thickness: 1),
                DialogRow(title: 'Card Number', content: subNumber),
                // const Divider(thickness: 1),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Spacer(),
                    DialogChip(
                        onTap: () {
                          Navigator.of(context).pop(false);
                        },
                        text: 'Cancel',
                        color: Colors.red),
                    const SizedBox(
                      width: 15,
                    ),
                    DialogChip(
                        onTap: () {
                          Navigator.of(context).pop(true);
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
