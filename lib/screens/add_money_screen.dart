import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/provider/transaction_provider.dart';
import 'package:kasheto_flutter/screens/web_view_pages.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';

import '../utils/my_colors.dart';

class AddMoneyScreen extends StatefulWidget {
  static const routeName = '/add_money_screen.dart';

  const AddMoneyScreen({Key? key}) : super(key: key);

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  String? _paymentMethodDropdown;
  String? _paymentVal;
  final _amountController = TextEditingController();
  var _dropDownValue = 'NGN';

  var _isLoading = false;

  Future _addUsdMoney() async {
    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      Alert.showerrorDialog(
        context: context,
        text: 'Add an amount',
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      return;
    } else if (double.parse(_amountController.text) <= 19.99 &&
        _dropDownValue == 'USD') {
      Alert.showerrorDialog(
        context: context,
        text: 'Enter an amount above 19',
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      return;
    } else if (_paymentMethodDropdown == null) {
      Alert.showerrorDialog(
        context: context,
        text: 'Pick a payment method',
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      return;
    } else if (_paymentMethodDropdown == 'flutterwave' &&
        _dropDownValue == 'USD') {
      Alert.showerrorDialog(
        context: context,
        text: 'Select a payment method for dollar',
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      return;
    }

    final _isConfirmed = await Alert.showAddUsdDialog(
        context: context,
        amount: '\$${_amountController.text}',
        ktcValue: _kashetoValue(),
        paymentMeethod: toBeginningOfSentenceCase(_paymentMethodDropdown),
        charges: _platformChargeForDeposit,
        totalDepositAmount: _depositAmount());
    if (_isConfirmed == null || !_isConfirmed) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      final url = Uri.parse('${ApiUrl.baseURL}user/pay');
      final header = await ApiUrl.setHeaders();
      final body = json.encode({
        "currency": "USD",
        "payment_method": _paymentMethodDropdown,
        "amount": _amountController.text,
      });
      final response = await http.post(url, body: body, headers: header);
      final res = json.decode(response.body);

      if (response.statusCode == 200 && _paymentMethodDropdown == 'paypal') {
        final paypalWebviewLink = res['details']['href'];
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return WebViewPagesPaypal(
            appbarTitle: 'Add Money (Paypal)',
            url: paypalWebviewLink,
            amount: 'USD ${_amountController.text}',
          );
        }));
      } else if (response.statusCode == 200 &&
          _paymentMethodDropdown!.toLowerCase() == 'card') {
        final cashappWebviewLink = res['details']['href'];
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return WebViewPagesPaypal(
            appbarTitle: 'Add Money (Card Payment)',
            url: cashappWebviewLink,
            amount: 'USD ${_amountController.text}',
          );
        }));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: ApiUrl.errorString, context: context),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert.snackBar(message: 'An error occured', context: context),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addNairaMoney() async {
    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      Alert.showerrorDialog(
        context: context,
        text: 'Add a valid amount',
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      return;
    } else if (double.parse(_amountController.text) <= 999.99 &&
        _dropDownValue == 'NGN' &&
        _paymentMethodDropdown == 'flutterwave') {
      Alert.showerrorDialog(
        context: context,
        text: 'Enter an amount above 999',
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      return;
    } else if (_paymentMethodDropdown == null) {
      Alert.showerrorDialog(
        context: context,
        text: 'Pick a payment method',
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      return;
    } else if (_paymentMethodDropdown != 'flutterwave' &&
        _dropDownValue == 'NGN') {
      Alert.showerrorDialog(
        context: context,
        text: 'Select a payment method for naira',
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      final _response =
          await Provider.of<TransactionProvider>(context, listen: false)
              .addMoney(
                  currency: _dropDownValue,
                  paymentMethod: _paymentMethodDropdown!,
                  amount: _amountController.text,
                  charges: _platformChargeForDeposit);

      if (_response != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: ((context) => WebViewPages(
                  url: _response,
                  appbarTitle: 'Add money',
                )),
          ),
        );
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

  String get _platformChargeForDeposit {
    if (_amountController.text.isEmpty) {
      return '0.00';
    } else if (_dropDownValue == 'USD') {
      return Provider.of<PlatformChargesProvider>(context, listen: false)
          .depositDollarsCharges(_amountController.text);
    } else {
      return Provider.of<PlatformChargesProvider>(context, listen: false)
          .depositCharges(_amountController.text);
    }
  }

  String _depositAmount() {
    if (_amountController.text.isEmpty) {
      return '0.00';
    }
    var _charge = double.parse(_platformChargeForDeposit);
    var _amount = double.parse(_amountController.text);
    var _totalAmount = _charge + _amount;
    var _totalAmountPlusFlutterwaveCharges =
        _totalAmount + (_totalAmount * 0.02);
    return _totalAmountPlusFlutterwaveCharges.toStringAsFixed(2);
  }

  String get _serviceCharge {
    double _charge = double.parse(_platformChargeForDeposit) +
        (double.parse(_depositAmount()) * 0.02);
    return _charge.toStringAsFixed(2);
  }

  String _kashetoValue() {
    final exValues =
        Provider.of<PlatformChargesProvider>(context, listen: false);
    if (_amountController.text.isEmpty) {
      return '0.00';
    } else if (_dropDownValue == 'NGN') {
      var kAmount = double.parse(_amountController.text) * exValues.nairaToKtc;
      return kAmount.toStringAsFixed(2);
    } else {
      var kAmount =
          double.parse(_amountController.text) * exValues.dollarsToKtc;
      return kAmount.toStringAsFixed(2);
    }
  }

  PlatformChargesProvider get platformCharges {
    return Provider.of<PlatformChargesProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Add Money'),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldText(text: 'Amount'),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: MyColors.textFieldColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: constraints.maxWidth * 0.12,
                      height: 40,
                      child: Center(
                        child: Text(
                          _dropDownValue == 'NGN' ? '₦' : '\$',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontFamily: '',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        maxLength: 19,
                        controller: _amountController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          errorStyle: const TextStyle(fontSize: 10),
                          filled: true,
                          fillColor: MyColors.textFieldColor,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          hintText: '0.00',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      width: 60,
                      child: DropdownButton(
                        focusColor: Colors.black,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 23,
                        ),
                        iconEnabledColor: Colors.grey,
                        iconDisabledColor: Colors.grey,
                        underline: const SizedBox(),
                        elevation: 0,
                        hint: Text(
                          _dropDownValue,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        isExpanded: true,
                        items: ['NGN', 'USD'].map(
                          (val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: FittedBox(
                                child: Text(
                                  val,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
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
                const TextFieldText(
                  text: 'Choose Payment Method',
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButton(
                    isExpanded: true,
                    items: [
                      'Local Card ( ₦, GH₵, KSh, R, USh, TSh)',
                      'Paypal (\$)',
                      'Card Payment (\$)',
                    ].map(
                      (val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(
                            val,
                            style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                    focusColor: Colors.black,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 23,
                    ),
                    iconEnabledColor: Colors.grey,
                    iconDisabledColor: Colors.grey,
                    underline: const SizedBox(),
                    elevation: 0,
                    hint: Text(
                      _paymentVal ?? 'Pick a Payment Method',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: _paymentVal == null
                            ? FontWeight.w400
                            : FontWeight.bold,
                        fontFamily: 'Raleway',
                      ),
                    ),
                    onChanged: (val) {
                      if (val == 'Local Card ( ₦, GH₵, KSh, R, USh, TSh)') {
                        setState(
                          () {
                            _paymentMethodDropdown = 'flutterwave';
                            _dropDownValue = 'NGN';
                            _paymentVal = val.toString();
                          },
                        );
                      } else if (val == 'Card Payment (\$)') {
                        setState(() {
                          _paymentMethodDropdown = 'card';
                          _dropDownValue = 'USD';
                          _paymentVal = val.toString();
                        });
                      } else {
                        setState(() {
                          _paymentMethodDropdown = 'paypal';
                          _dropDownValue = 'USD';
                          _paymentVal = val.toString();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Text(
                      'The current exhange rate is',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _dropDownValue == 'USD'
                          ? '1 USD = ${platformCharges.dollarsToKtc} KTC'
                          : '1 NGN = ${platformCharges.nairaToKtc} KTC',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: _deviceHeight * 0.02,
                ),
                const Divider(thickness: 1),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const Text(
                      'Service charge',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _dropDownValue == 'USD'
                          ? '\$ $_platformChargeForDeposit'
                          // Adding flutterwave charges
                          : '₦ $_serviceCharge',
                      style: const TextStyle(
                        fontFamily: '',
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Text(
                      'You\'ll Deposit',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _dropDownValue == 'USD'
                          ? '\$ ${_depositAmount()}'
                          : '₦ ${_depositAmount()}',
                      style: const TextStyle(
                        fontFamily: '',
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Text(
                      'You\'ll get ',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'KTC ${_kashetoValue()}',
                      style: const TextStyle(
                        fontFamily: '',
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    )
                  ],
                ),
                const Spacer(),
                if (_isLoading) const LoadingSpinnerWithMargin(),
                if (!_isLoading)
                  SubmitButton(
                    action: () {
                      FocusScope.of(context).unfocus();

                      // if (_paymentMethodDropdown == null) {
                      //   Alert.showerrorDialog(
                      //     context: context,
                      //     text: 'Pick a payment method',
                      //     onPressed: () {
                      //       Navigator.of(context).pop();
                      //     },
                      //   );
                      // }

                      if (_dropDownValue == 'USD') {
                        _addUsdMoney();
                      } else {
                        _addNairaMoney();
                      }
                    },
                    title: 'Continue',
                  )
              ],
            ),
          );
        }),
      ),
    );
  }
}
