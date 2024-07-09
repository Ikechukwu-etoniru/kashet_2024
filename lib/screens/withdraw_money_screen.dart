import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/bank.dart';
import 'package:kasheto_flutter/provider/bank_provider.dart';
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/provider/wallet_provider.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/widgets/error_widget.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/my_dropdown.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';

class WithdrawMoneyScreen extends StatefulWidget {
  static const routeName = '/withdraw_money_screen.dart';

  const WithdrawMoneyScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawMoneyScreen> createState() => _WithdrawMoneyScreenState();
}

class _WithdrawMoneyScreenState extends State<WithdrawMoneyScreen> {
  final _textFieldColor = Colors.grey[200];
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _paymentMethodDropdown = 'Choose a withdrawal method';
  var _isLoading = false;
  var _isError = false;
  String? _ktcAmount = '0.00';
  var _showBanks = false;
  int? _selectedBank;

  List<UserBank> get _banks {
    return Provider.of<BankProvider>(context, listen: false).userBankList;
  }

  bool _isDetailsValid() {
    final _validateDetails = _formKey.currentState!.validate();
    if (_validateDetails && _selectedBank != null) {
      return true;
    } else if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert.snackBar(
            message: 'Select a bank account to receive funds',
            context: context),
      );
      return false;
    } else {
      return false;
    }
  }

// Using this to show bank details in my confirmation dialog
  UserBank _selectedBankDetails(int bankId) {
    return _banks.firstWhere((element) => element.id == bankId);
  }

// Withdraw function
  Future<void> _withdrawMoney() async {
    final _isValid = _isDetailsValid();
    if (!_isValid) {
      return;
    } else {
      final confirm = await Alert.confirmationDialog(
        context: context,
        charges: _totalCharge,
        amount: _ktcAmount.toString(),
        acctName: _selectedBankDetails(_selectedBank!).acctName!,
        acctNumber: _selectedBankDetails(_selectedBank!).acctNumber!,
        bankName: _selectedBankDetails(_selectedBank!).bankName!,
      );
      if (confirm == null || !confirm) {
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        const _currency =
            'NGN'; // Provider.of<AuthProvider>(context, listen: false).userList[0].userCurrency;
        final _url = Uri.parse(
            '${ApiUrl.baseURL}user/withdraw/process-withdraw-to-bank');
        final _header = await ApiUrl.setHeaders();

        final _response = await http.post(_url,
            headers: _header,
            body: json.encode({
              "currency": _currency,
              "bank": _selectedBank,
              "amount": _amountController.text,
            }));
        final res = json.decode(_response.body);
        if (_response.statusCode == 200 && res['status'] == 'success') {
          Alert.showSuccessDialog2(context);
        } else if (_response.statusCode == 422) {
          ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
              message: res['errors']['amount'][0], context: context));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              Alert.snackBar(message: 'Withdrawal failed', context: context));
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

  void _getKtcAmount() {
    if (_amountController.text.isEmpty) {
      _ktcAmount = '0.00';
    }
    final _naira2ktc =
        Provider.of<PlatformChargesProvider>(context, listen: false).nairaToKtc;
    final _amount = double.parse(_amountController.text) * _naira2ktc;
    _ktcAmount = _amount.toString();
  }

  num get _walletBalance {
    return Provider.of<WalletProvider>(context, listen: false).walletBalance;
  }

  String get _flutterwaveWithdrawCharge {
    if (_amountController.text.isEmpty) {
      return '0.00';
    } else if (double.parse(_amountController.text) <= 5000) {
      return '10.75';
    } else if (double.parse(_amountController.text) >= 5001 &&
        double.parse(_amountController.text) <= 50000) {
      return '27';
    } else {
      return '53.75';
    }
  }

  String get _kashetoCharge {
    if (_amountController.text.isEmpty) {
      return '0.00';
    } else {
      var _charge = double.parse(_amountController.text) * 0.01;
      return _charge.toStringAsFixed(2);
    }
  }

  String get _totalCharge {
    if (_amountController.text.isEmpty) {
      return '0.00';
    } else {
      var _charge = double.parse(_flutterwaveWithdrawCharge) +
          double.parse(_kashetoCharge);
      return _charge.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingSpinnerWithScaffold()
        : _isError
            ? const IsErrorScreen()
            : SafeArea(
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    title: const Text('Withdraw Money'),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                const Text(
                                  'Please enter the details of the account you wish to withdraw into.',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const TextFieldText(text: 'Amount'),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  // Max lenth is 19 to prevent invalid number error
                                  maxLength: 19,

                                  onChanged: (value) {
                                    setState(() {
                                      _getKtcAmount();
                                    });
                                  },
                                  controller: _amountController,
                                  validator: ((value) {
                                    if (value == null || value.isEmpty) {
                                      return 'This field cannot be empty';
                                    } else if (double.tryParse(value) == null) {
                                      return 'Invalid amount';
                                    } else if (double.parse(value) <= 0.0) {
                                      return 'Enter an amount above 0';
                                    } else if (double.parse(value) >
                                        _walletBalance) {
                                      return 'You have insufficient KTC';
                                    } else if ((double.parse(_ktcAmount!) +
                                            double.parse(_totalCharge)) >
                                        _walletBalance) {
                                      return 'Your current balance doesn\'t cover service charges';
                                    } else {
                                      return null;
                                    }
                                  }),
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context).unfocus();
                                  },
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    // Using c style and text to hide counter
                                    counterStyle: const TextStyle(
                                      height: double.minPositive,
                                    ),
                                    counterText: "",
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(
                                        '₦',
                                        style: TextStyle(
                                            fontFamily: '',
                                            fontSize: 15,
                                            color: Colors.grey),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    filled: true,
                                    fillColor: _textFieldColor,
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
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Raleway',
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(
                                        'k',
                                        style: TextStyle(
                                            fontFamily: '',
                                            fontSize: 18,
                                            color: Colors.grey),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    filled: true,
                                    fillColor: _textFieldColor,
                                    isDense: true,
                                    hintText: _ktcAmount,
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
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
                                const TextFieldText(text: 'Withdrawal Method'),
                                const SizedBox(
                                  height: 5,
                                ),
                                MyDropDown(
                                  items: ['Local Bank'].map(
                                    (val) {
                                      return DropdownMenuItem<String>(
                                        value: val,
                                        child: Text(
                                          val,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (val) {
                                    if (val == 'Local Bank') {
                                      setState(
                                        () {
                                          _paymentMethodDropdown =
                                              'flutterwave';
                                        },
                                      );
                                    }
                                  },
                                  hint: const Text(
                                    'Choose a Withdrawal Method',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val == null) {
                                      return 'Pick a withdrawal method';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                const TextFieldText(text: 'Select Account'),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: MyColors.textFieldColor),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Choose Bank Account',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          if (!_showBanks) {
                                            setState(() {
                                              _showBanks = true;
                                            });
                                          } else {
                                            setState(() {
                                              _showBanks = false;
                                            });
                                          }
                                        },
                                        icon: Icon(
                                          Icons.arrow_drop_down_circle,
                                          size: 17,
                                          color: _showBanks
                                              ? Colors.grey
                                              : MyColors.primaryColor,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                if (_showBanks)
                                  SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                        itemCount: _banks.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 5),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: MyColors.primaryColor
                                                  .withOpacity(0.3),
                                            ),
                                            alignment: Alignment.center,
                                            child: Stack(children: [
                                              Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      FittedBox(
                                                        child: Text(
                                                          capitalizeFirstLetterOfEachWord(
                                                              _banks[index]
                                                                  .acctName!),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      FittedBox(
                                                        child: Text(
                                                          _banks[index]
                                                              .acctNumber!,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      FittedBox(
                                                        child: Text(
                                                          _banks[index]
                                                              .bankName!,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 35,
                                                  )
                                                ],
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (_selectedBank ==
                                                          _banks[index].id) {
                                                        _selectedBank = null;
                                                      } else {
                                                        _selectedBank =
                                                            _banks[index].id;
                                                      }
                                                    });
                                                  },
                                                  child: _selectedBank ==
                                                          _banks[index].id
                                                      ? const CircleAvatar(
                                                          child: Icon(
                                                            Icons.check,
                                                            color: Colors.white,
                                                            size: 10,
                                                          ),
                                                        )
                                                      : const CircleAvatar(
                                                          radius: 10,
                                                          backgroundColor:
                                                              Colors.white,
                                                        ),
                                                ),
                                              ),
                                            ]),
                                          );
                                        }),
                                  ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Service Charge',
                                      style: TextStyle(
                                        fontSize: 11,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _amountController.text.isEmpty
                                          ? '₦ 0'
                                          : '₦ $_totalCharge',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontFamily: "",
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
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
                                      'NGN 1 = K ${Provider.of<PlatformChargesProvider>(context, listen: false).nairaToKtc}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SubmitButton(
                              action: () {
                                _withdrawMoney();
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

String capitalizeFirstLetterOfEachWord(String sentence) {
  if (sentence.isEmpty) return sentence;

  // Split the sentence into words
  List<String> words = sentence.split(' ');

  // Capitalize the first letter of each word
  words = words.map((word) {
    if (word.isEmpty) return word; // Handle any extra spaces
    return word[0].toUpperCase() + word.substring(1);
  }).toList();

  // Join the words back into a sentence
  return words.join(' ');
}
