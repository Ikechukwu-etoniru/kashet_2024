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
import 'package:kasheto_flutter/widgets/my_dropdown.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:provider/provider.dart';

import '../utils/my_colors.dart';

class AddMoneyScreen extends StatefulWidget {
  static const routeName = '/add_money_screen.dart';

  const AddMoneyScreen({Key? key}) : super(key: key);

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _paymentMethodDropdown;
  final _amountController = TextEditingController();
  var _dropDownValue = 'NGN';

  var _isLoading = false;

  Future _addUsdMoney(String paymentMethod) async {
    bool _isFormValid = _formKey.currentState!.validate();
    if (_isFormValid) {
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
        print(paymentMethod);
        _formKey.currentState!.save();
        setState(() {
          _isLoading = true;
        });
        final url = Uri.parse('${ApiUrl.baseURL}user/pay');
        final header = await ApiUrl.setHeaders();
        final body = json.encode({
          "currency": "USD",
          "payment_method": 'card',
          // paymentMethod == 'Payment Method' ? 'cashapp' : paymentMethod,
          "amount": _amountController.text,
          "charges": _platformChargeForDeposit
        });
        final response = await http.post(url, body: body, headers: header);
        final res = json.decode(response.body);
        print(res);
        if (response.statusCode == 200 &&
            paymentMethod.toLowerCase() == 'paypal') {
          final paypalWebviewLink = res['details']['links'][1]['href'];
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return WebViewPagesPaypal(
              appbarTitle: 'Add Money (Paypal)',
              url: paypalWebviewLink,
              amount: 'USD ${_amountController.text}',
            );
          }));
        } else if (response.statusCode == 200 &&
            paymentMethod.toLowerCase() == 'cashapp') {
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
  }

  Future<void> _addNairaMoney() async {
    bool _isFormValid = _formKey.currentState!.validate();

    if (_isFormValid) {
      try {
        _formKey.currentState!.save();
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: _deviceHeight * 0.03,
                  ),
                  const Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Stack(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        maxLength: 19,
                        controller: _amountController,
                        validator: ((value) {
                          final isCashPayPal =
                              _paymentMethodDropdown == 'Payment Method' ||
                                  _paymentMethodDropdown == 'paypal';

                          if (value == null || value.isEmpty) {
                            return 'This field cannot be empty';
                          } else {
                            final amount = double.tryParse(value);
                            if (amount == null) {
                              return 'Enter a valid number';
                            } else if (amount <= 0) {
                              return 'Enter an amount greater than 0.9';
                            } else if (isCashPayPal && amount < 20) {
                              return 'Enter an amount greater than 19.99';
                            } else if (amount <= 999.99 &&
                                _dropDownValue == 'NGN' &&
                                _paymentMethodDropdown == 'flutterwave') {
                              return 'Enter an amount greater than 999.99';
                            } else {
                              return null;
                            }
                          }
                        }),
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          errorStyle: const TextStyle(fontSize: 10),
                          filled: true,
                          fillColor: MyColors.textFieldColor,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: constraints.maxWidth * 0.2),
                          //  MyPadding.textFieldContentPadding,
                          hintText: '0.00',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: constraints.maxWidth * 0.15,
                        height: 50,
                        child: Text(
                          _dropDownValue == 'NGN' ? '₦' : '\$',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 20, fontFamily: ''),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          alignment: Alignment.center,
                          width: constraints.maxWidth * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: DropdownButton(
                            focusColor: Colors.black,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            iconEnabledColor: Colors.grey,
                            iconDisabledColor: Colors.grey,
                            underline: const SizedBox(),
                            elevation: 0,
                            hint: Text(_dropDownValue),
                            isExpanded: true,
                            items: ['NGN', 'USD'].map(
                              (val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: FittedBox(
                                    child: Text(val),
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
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Choose Payment Method',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyDropDown(
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
                              fontFamily: '',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (val) {
                      if (val == 'Local Card ( ₦, GH₵, KSh, R, USh, TSh)') {
                        setState(
                          () {
                            _paymentMethodDropdown = 'flutterwave';
                            _dropDownValue = 'NGN';
                          },
                        );
                      } else if (val == 'Card Payment (\$)') {
                        setState(() {
                          _paymentMethodDropdown = 'cashapp';
                          _dropDownValue = 'USD';
                        });
                      } else {
                        setState(() {
                          _paymentMethodDropdown = 'paypal';
                          _dropDownValue = 'USD';
                        });
                      }
                    },
                    hint: const Text('Pick a Payment Method'),
                    validator: (val) {
                      if (val == null) {
                        return 'Pick a payment method';
                      } else if (_dropDownValue == 'USD' &&
                          _paymentMethodDropdown == 'flutterwave') {
                        return 'Choose a Payment method for Dollars';
                      } else if (_dropDownValue == 'NGN' &&
                          (_paymentMethodDropdown == 'paypal' ||
                              _paymentMethodDropdown == 'Payment Method')) {
                        return 'Choose a Payment method for Naira';
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const Text('The current exhange rate is'),
                      const Spacer(),
                      Text(
                        _dropDownValue == 'USD'
                            ? '1 USD = ${platformCharges.dollarsToKtc} KTC'
                            : '1 NGN = ${platformCharges.nairaToKtc} KTC',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: _deviceHeight * 0.02,
                  ),
                  const Divider(thickness: 1),
                  SizedBox(
                    height: _deviceHeight * 0.03,
                  ),
                  Row(
                    children: [
                      const Text('Service charge'),
                      const Spacer(),
                      Text(
                        _dropDownValue == 'USD'
                            ? '\$ $_platformChargeForDeposit'
                            // Adding flutterwave charges
                            : '₦ $_serviceCharge',
                        style: const TextStyle(
                          fontFamily: '',
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: _deviceHeight * 0.03,
                  ),
                  Row(
                    children: [
                      const Text('You\'ll Deposit'),
                      const Spacer(),
                      Text(
                        _dropDownValue == 'USD'
                            ? '\$ ${_depositAmount()}'
                            : '₦ ${_depositAmount()}',
                        style: const TextStyle(
                          fontFamily: '',
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: _deviceHeight * 0.03,
                  ),
                  Row(
                    children: [
                      const Text('You\'ll get '),
                      const Spacer(),
                      Text(
                        'KTC ${_kashetoValue()}',
                        style: const TextStyle(
                          fontFamily: '',
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
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
                        if (_dropDownValue == 'USD') {
                          _addUsdMoney(_paymentMethodDropdown!);
                        } else {
                          _addNairaMoney();
                        }
                      },
                      title: 'Continue',
                    )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
