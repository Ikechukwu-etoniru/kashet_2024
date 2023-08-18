import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/bank.dart';
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/provider/wallet_provider.dart';
import 'package:kasheto_flutter/screens/main_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/my_dropdown.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:provider/provider.dart';

import '../provider/bank_provider.dart';

class BankTransfer extends StatefulWidget {
  static const routeName = '/bank_transfer.dart';
  const BankTransfer({Key? key}) : super(key: key);

  @override
  State<BankTransfer> createState() => _BankTransferState();
}

class _BankTransferState extends State<BankTransfer> {
  final _textFieldContentPadding = MyPadding.textFieldContentPadding;
  final _textFieldColor = MyColors.textFieldColor;
  String _dropDownValue = 'Choose bank';
  String? _countryDropDownValue;
  String? _bankId;
  String? _beneName;
  Bank? _selectedBank;
  var _isLoading = false;
  var _isButtonLoading = false;
  var _isNameLoading = false;
  var _screenLoading = false;
  List<Bank>? _isoBankList;
  List<String>? _isoBankListString;
  final _acctNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> _bankCountryList = [
    'Nigeria',
    'Kenya',
    'Ghana',
    'South Africa',
    'Tanzania'
  ];

  void _getBankId(String value) {
    _selectedBank = _isoBankList!.firstWhere((element) {
      return element.name == value;
    });
    _bankId = _selectedBank!.code;
  }

  List<String> _getFilteredOptions(String pattern) {
    List<String> filteredOptions = [];
    for (String option in _isoBankListString!) {
      if (option.toLowerCase().contains(pattern.toLowerCase())) {
        filteredOptions.add(option);
      }
    }
    return filteredOptions;
  }

  String? _ktcAmount = '0.00';

  void _getKtcAmount() {
    if (_amountController.text.isEmpty) {
      _ktcAmount = '0.00';
    }
    final _naira2ktc =
        Provider.of<PlatformChargesProvider>(context, listen: false).nairaToKtc;
    final _amount = double.parse(_amountController.text) * _naira2ktc;
    _ktcAmount = _amount.toString();
  }

  String _getBankIso(String val) {
    if (val == 'Nigeria') {
      return 'NG';
    } else if (val == 'Kenya') {
      return 'KE';
    } else if (val == 'Ghana') {
      return 'GH';
    } else if (val == 'South Africa') {
      return 'ZA';
    } else if (val == 'Tanzania') {
      return 'TZ';
    } else {
      return 'NG';
    }
  }

  String _getCurrency(String val) {
    if (val == 'Nigeria') {
      return 'NGN';
    } else if (val == 'Kenya') {
      return 'KES';
    } else if (val == 'Ghana') {
      return 'GHS';
    } else if (val == 'South Africa') {
      return 'ZAR';
    } else if (val == 'Tanzania') {
      return 'TZS';
    } else {
      return 'NGN';
    }
  }

  Future _getBankList(String iso) async {
    setState(() {
      _isLoading = true;
    });
    try {
      _isoBankList = await Provider.of<BankProvider>(context, listen: false)
          .getBankListByIso(iso);
      _isoBankListString = _isoBankList!.map((e) {
        return e.name;
      }).toList();
      _isoBankListString!.sort();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message: 'An error occured. Banks couldn\'t be fetched',
          context: context));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _verifyAcctNumber() async {
    setState(() {
      _isNameLoading = true;
    });
    try {
      final url =
          Uri.parse('${ApiUrl.baseURL}user/profile/confirm-bank-account');
      final _header = await ApiUrl.setHeaders();
      final _body = json.encode({
        'account_number': _acctNumberController.text,
        'account_bank': _selectedBank!.id,
        'code': _selectedBank!.code
      });
      final response = await http.post(url, body: _body, headers: _header);
      final res = json.decode(response.body);
      if (res["status"] == "success" && res['data']['account_name'] != null) {
        _beneName = res['data']['account_name'];
        return true;
      } else if (res["status"] == "error") {
        ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
            message: 'Sorry, recipient account could not be validated',
            context: context));
        _beneName = 'Error validating details';
        return false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
            message:
                'Account number couldn\'t be verified. Check the account number and bank or try again later',
            context: context));
        _beneName = 'Error validating details';
        return false;
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message:
              'Account number couldn\'t be verified. Check the account number and bank or try again later',
          context: context));
      _beneName = 'Error validating details';
      return false;
    } finally {
      setState(() {
        _isNameLoading = false;
      });
    }
  }

  String get walletBalance {
    return Provider.of<WalletProvider>(context, listen: false)
        .walletBalance
        .toString();
  }

  Future _transferFunds() async {
    setState(() {
      _isButtonLoading = true;
    });

    try {
      final url =
          Uri.parse('${ApiUrl.baseURL}user/withdraw/withdraw-to-other-bank');
      final _header = await ApiUrl.setHeaders();

      final _body = json.encode({
        "code": _selectedBank!.code,
        "account_number": _acctNumberController.text,
        "amount": _amountController.text,
        "currency": _getCurrency(_countryDropDownValue!),
        "beneficiary_name": _beneName,
        "charges": _totalCharge,
        "email": null,
        "phone": null,
        "bank": true
      });
      final response = await http.post(url, body: _body, headers: _header);
      final res = json.decode(response.body);
      if (res['status'] == 'success') {
        // Provider.of<WalletProvider>(context, listen: false)
        //     .reduceWalletBalance(double.parse(_amountController.text));
        Alert.showSuccessDialog(
            context: context,
            text: 'Your transfer to $_beneName was successful',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  MainScreen.routeName, (route) => false);
            });
      } else {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: ApiUrl.errorString, context: context));
      }
    } catch (error) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: ApiUrl.errorString, context: context));
    } finally {
      setState(() {
        _isButtonLoading = false;
      });
    }
  }

  String get _flutterwaveCharge {
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
      var _charge =
          double.parse(_flutterwaveCharge) + double.parse(_kashetoCharge);
      return _charge.toStringAsFixed(2);
    }
  }

  double get _totalAmount {
    return double.parse(_totalCharge) + double.parse(_amountController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Bank Transfer'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const Text(
                        'Bank Country',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, letterSpacing: 1.5),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      MyDropDown(
                          items: _bankCountryList.map(
                            (val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            },
                          ).toList(),
                          onChanged: (val) {
                            setState(
                              () {
                                _countryDropDownValue = val as String?;
                                _getBankList(
                                    _getBankIso(_countryDropDownValue!));
                              },
                            );
                          },
                          hint: _countryDropDownValue == null
                              ? const FittedBox(
                                  child: Text('Choose Bank Country'),
                                )
                              : FittedBox(
                                  child: Text(
                                    _countryDropDownValue!,
                                  ),
                                ),
                          validator: (value) {
                            if (value == null) {
                              return 'Choose a Bank Country';
                            } else {
                              return null;
                            }
                          }),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Account Number',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, letterSpacing: 1.5),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (_countryDropDownValue == null)
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                                Alert.snackBar(
                                    message: 'Choose a bank country first',
                                    context: context));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: MyColors.textFieldColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Beneficiary Account Number',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        ),
                      if (_countryDropDownValue != null)
                        Focus(
                          onFocusChange: (value) {
                            if (!value &&
                                _selectedBank != null &&
                                _acctNumberController.text.isNotEmpty) {
                              _verifyAcctNumber();
                            }
                          },
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter beneficiary account number';
                              } else if (value.length < 10) {
                                return 'Account number is short by ${10 - value.length} numbers';
                              } else if (value.length > 10) {
                                return 'Account number is too long with ${value.length - 10} extra numbers';
                              } else {
                                return null;
                              }
                            },
                            controller: _acctNumberController,
                            onFieldSubmitted: (value) async {
                              FocusScope.of(context).unfocus();
                              if (_selectedBank != null) {
                                _verifyAcctNumber();
                              }
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: _textFieldContentPadding,
                              isDense: true,
                              hintText: 'Beneficiary account number',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
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
                        height: 20,
                      ),
                      const Text(
                        'Bank Name',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, letterSpacing: 1.5),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (_countryDropDownValue == null)
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                                Alert.snackBar(
                                    message: 'Choose a bank country first',
                                    context: context));
                          },
                          child: Container(
                            padding: MyPadding.textFieldContentPadding,
                            decoration: BoxDecoration(
                              color: MyColors.textFieldColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Choose Bank',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        ),
                      if (_isLoading) const LoadingSpinnerWithMargin(),
                      if (_countryDropDownValue != null && _isLoading == false)
                        DropdownSearch<String>(
                          popupProps: const  PopupProps.menu(
                            showSearchBox: true,
                            showSelectedItems: true,
                          ),
                          items: _isoBankListString!,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              contentPadding: _textFieldContentPadding,
                              isDense: true,
                              hintText: _dropDownValue,
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: _textFieldColor,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                          onChanged: (value) {
                            setState(
                              () {
                                _dropDownValue = value.toString();
                                _getBankId(value.toString());
                                if (_acctNumberController.text.isNotEmpty) {
                                  _verifyAcctNumber();
                                }
                              },
                            );
                          },
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Account Name',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, letterSpacing: 1.5),
                      ),
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
                            if (_countryDropDownValue == null) {
                              FocusScope.of(context).unfocus();
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                Alert.snackBar(
                                    message: 'Choose a bank country first',
                                    context: context),
                              );
                            } else {
                              FocusScope.of(context).unfocus();
                              ScaffoldMessenger.of(context).showSnackBar(
                                Alert.snackBar(
                                    message:
                                        'This field will be dynamically filled',
                                    context: context),
                              );
                            }
                          },
                          child: TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                              contentPadding: _textFieldContentPadding,
                              isDense: true,
                              hintText: _beneName ?? 'Beneficiary Name',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
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
                        height: 20,
                      ),
                      const Text(
                        'Amount',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, letterSpacing: 1.5),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Add transfer amount';
                          }
                          //  else if (double.parse(value) <= 999.99) {
                          //   return 'Enter an amount above 999.99';
                          // }
                          else if (double.parse(_ktcAmount!) >
                              double.parse(walletBalance)) {
                            return 'You have insufficient Kasheto funds';
                          } else if (double.parse(_ktcAmount!) > _totalAmount) {
                            return 'You have insufficient Kasheto funds to cover for charges';
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
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: _textFieldContentPadding,
                          isDense: true,
                          hintText: '0.00',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
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
                      Row(
                        children: [
                          const Text(
                            'KTC value',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5),
                          ),
                          const Spacer(),
                          Text(
                            ' K $walletBalance',
                            style:
                                const TextStyle(color: MyColors.primaryColor),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          contentPadding: _textFieldContentPadding,
                          isDense: true,
                          hintText: _ktcAmount,
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: _textFieldColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text('Charge'),
                          const Spacer(),
                          Text(
                            'KTC $_totalCharge',
                            style: const TextStyle(
                              color: Colors.green,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                if (_isButtonLoading) const LoadingSpinnerWithMargin(),
                if (!_isButtonLoading)
                  SubmitButton(
                    action: () async {
                      final _isValid = _formKey.currentState!.validate();
                      if (!_isValid) {
                        return;
                      }
                      final acctNumberValid = await _verifyAcctNumber();
                      if (!acctNumberValid) {
                        return;
                      }
                      final _isConfirmed = await Alert.showTransferDialog(
                        context: context,
                        name: _beneName!,
                        bank: _selectedBank!,
                        amount: _amountController.text,
                        charges: _totalCharge,
                        totalAmount: _totalAmount.toStringAsFixed(2),
                      );
                      if (_isConfirmed == null || !_isConfirmed) {
                        return;
                      }
                      _transferFunds();
                    },
                    title: 'Continue',
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConfirmColumn extends StatelessWidget {
  final String title;
  final String content;
  const ConfirmColumn(this.title, this.content, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(content)
      ],
    );
  }
}
