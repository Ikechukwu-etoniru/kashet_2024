import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/billings.dart';
import 'package:kasheto_flutter/provider/billing_provider.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/provider/wallet_provider.dart';
import 'package:kasheto_flutter/screens/main_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/dialog_chip.dart';
import 'package:kasheto_flutter/widgets/dialog_row.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/my_dropdown.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';

import '../provider/platform_provider.dart';

class AirtimePurchasePage extends StatefulWidget {
  final List<BillingPlan> airtimePlan;
  const AirtimePurchasePage({required this.airtimePlan, Key? key})
      : super(key: key);

  @override
  State<AirtimePurchasePage> createState() => _AirtimePurchasePageState();
}

class _AirtimePurchasePageState extends State<AirtimePurchasePage> {
  String? _dropDownValue;
  String? _ktcAmount = '0.00';
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  BillingPlan? _choosenAirtimeBilling;
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void _getKtcAmount() {
    if (_amountController.text.isEmpty) {
      _ktcAmount = '0.00';
    }
    final _naira2ktc =
        Provider.of<PlatformChargesProvider>(context, listen: false).nairaToKtc;
    final _amount = double.parse(_amountController.text) * _naira2ktc;
    _ktcAmount = _amount.toString();
  }

  void _getBillingPlanByName() {
    _choosenAirtimeBilling =
        Provider.of<BillingProvider>(context, listen: false)
            .getAirtimeBillingPlanByName(_dropDownValue!);
  }

  Future _buyAirtime() async {
    final _isValid = _formKey.currentState!.validate();
    if (_isValid) {
      final _isConfirmed = await _confirmationDialog(
          context: context,
          amount: _amountController.text,
          operatorName: _dropDownValue!,
          operatorNumber: _phoneController.text);
      if (_isConfirmed != null && _isConfirmed) {
        try {
          setState(() {
            _isLoading = true;
          });
          final _userCurrency =
              Provider.of<AuthProvider>(context, listen: false)
                  .userList[0]
                  .userCurrency;
          final url =
              Uri.parse('${ApiUrl.baseURL}user/bills/paybills?is_airtime=true');
          final _header = await ApiUrl.setHeaders();

          final _body = json.encode({
            'card_number': _phoneController.text,
            'amount': _amountController.text,
            'ktc_value': _ktcAmount,
            'plan_id': _choosenAirtimeBilling!.id.toString(),
            'currency': _userCurrency,
          });
          final _response = await http.post(url, headers: _header, body: _body);
          final res = json.decode(_response.body);

          if (_response.statusCode == 201 && res['status'] == 'success') {
            await _showSuccessDialog(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              Alert.snackBar(message: ApiUrl.errorString, context: context),
            );
          }
        } on SocketException {
          ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(
                message: ApiUrl.internetErrorString, context: context),
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
  }

  num get _walletBalance {
    return Provider.of<WalletProvider>(context, listen: false).walletBalance;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 15,
                ),
                const TextFieldText(text: 'Select Operator'),
                const SizedBox(
                  height: 5,
                ),
                MyDropDown(
                    items: widget.airtimePlan.map(
                      (val) {
                        return DropdownMenuItem<String>(
                          value: val.genName,
                          child: Text(
                            val.genName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (val) {
                      setState(
                        () {
                          _dropDownValue = val as String?;
                          _getBillingPlanByName();
                        },
                      );
                    },
                    hint: _dropDownValue == null
                        ? const FittedBox(
                            child: Text(
                              'E.g  MTN, Airtel, etc.',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          )
                        : FittedBox(
                            child: Text(
                              _dropDownValue!,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                    validator: (value) {
                      if (value == null) {
                        return 'Select an operator';
                      } else {
                        return null;
                      }
                    }),
                const SizedBox(
                  height: 15,
                ),
                const TextFieldText(text: 'Phone Number'),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(letterSpacing: 3, fontSize: 12),
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    } else if (int.tryParse(value) == null) {
                      return 'Enter a valid number';
                    } else if (value.length > 11) {
                      return 'Phone number too long';
                    } else if (value.length < 11) {
                      return 'Phone number too short';
                    } else if (!value.startsWith('0')) {
                      return 'Enter a valid number';
                    } else {
                      return null;
                    }
                  }),
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: MyPadding.textFieldContentPadding,
                    filled: true,
                    fillColor: MyColors.textFieldColor,
                    isDense: true,
                    hintText: '',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const TextFieldText(text: 'Amount'),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: MyColors.textFieldColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '₦',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'This field cannot be empty';
                          } else if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          } else if (double.parse(_ktcAmount!) >
                              _walletBalance) {
                            return 'You have insufficient Kasheto funds';
                          } else {
                            return null;
                          }
                        }),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          filled: true,
                          fillColor: MyColors.textFieldColor,
                          isDense: true,
                          hintText: '0.00',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _getKtcAmount();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const TextFieldText(text: 'Value in KTC'),
                    const Spacer(),
                    Text(
                      'k ${_walletBalance.toString()}',
                      style:
                          const TextStyle(color: Colors.green, fontFamily: ''),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: MyColors.textFieldColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'k',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 1,
                    ),
                    Expanded(
                      child: TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          filled: true,
                          fillColor: MyColors.textFieldColor,
                          isDense: true,
                          hintText: _ktcAmount,
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const Text(
                      'The current exhange rate is',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'NGN 1 = K ${Provider.of<PlatformChargesProvider>(context, listen: false).nairaToKtc}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (_isLoading) const LoadingSpinnerWithMargin(),
                if (!_isLoading)
                  SubmitButton(
                      action: () {
                        _buyAirtime();
                      },
                      title: 'Continue')
              ],
            ),
          ),
        );
      }),
    );
  }
}

Future<bool?> _confirmationDialog({
  required BuildContext context,
  required String amount,
  required String operatorName,
  required String operatorNumber,
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
                  'Confirm Airtime Purchase !!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(thickness: 1),
                DialogRow(title: 'Amount', content: amount),
                const Divider(thickness: 1),
                DialogRow(title: 'Operator', content: operatorName),
                const Divider(thickness: 1),
                DialogRow(title: 'Phone Number', content: operatorNumber),
                const Divider(thickness: 1),
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

Future _showSuccessDialog(
  BuildContext context,
) {
  return showDialog(
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
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: Image.asset(
                    'images/happy_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Your recharge card purchase was succesful !!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(
                  height: 30,
                ),
                DialogChip(
                    onTap: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          MainScreen.routeName, (route) => false);
                    },
                    text: 'Close',
                    color: Colors.red),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      });
}
