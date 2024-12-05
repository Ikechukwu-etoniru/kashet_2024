import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/bank.dart';
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/provider/wallet_provider.dart';
import 'package:kasheto_flutter/screens/main_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/home_widgets/black_box.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';

class BankTransfer extends StatefulWidget {
  final Bank bank;
  final String acctNumber;
  final String countryDropDownValue;
  final String beneficiaryName;
  const BankTransfer(
      {required this.bank,
      required this.acctNumber,
      required this.countryDropDownValue,
      required this.beneficiaryName,
      Key? key})
      : super(key: key);

  @override
  State<BankTransfer> createState() => _BankTransferState();
}

class _BankTransferState extends State<BankTransfer> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _isButtonLoading = false;
  final _amountController = TextEditingController();
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

  String get walletBalance {
    return Provider.of<WalletProvider>(context, listen: false)
        .walletBalance
        .toString();
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

  Future _transferFunds() async {
    setState(() {
      _isButtonLoading = true;
    });

    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/transaction/send');
      final _header = await ApiUrl.setHeaders();

      final _body = json.encode({
        "amount": _amountController.text,
        "currency": _getCurrency(widget.countryDropDownValue),
        "account_name": widget.beneficiaryName,
        "account_number": widget.acctNumber,
        "bank": {"label": widget.bank.name, "bank_id": widget.bank.id},
        "recipient_type": "bank"
      });
      final response = await http.post(url, body: _body, headers: _header);
      final res = json.decode(response.body);
      print(res);
      if (res['success'] == true) {
        Alert.showSuccessDialog(
            context: context,
            text: 'Your transfer to ${widget.beneficiaryName} was successful',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  MainScreen.routeName, (route) => false);
            });
      } else {
        FocusScope.of(context).unfocus();

        Alert.showerrorDialog(
            context: context,
            text: 'Transfer failed',
            onPressed: () {
              Navigator.of(context).pop();
            });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Transfer'),
      ),
      body: Padding(
        padding: MyPadding.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextFieldText(text: 'Amount'),
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                decoration: InputDecoration(
                  contentPadding: MyPadding.textFieldContentPadding,
                  isDense: true,
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
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
                  const TextFieldText(text: 'KTC value'),
                  const Spacer(),
                  Text(
                    ' K ${formatCurrency(walletBalance)}',
                    style: const TextStyle(
                      color: MyColors.primaryColor,
                      fontSize: 11,
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
                  contentPadding: MyPadding.textFieldContentPadding,
                  isDense: true,
                  hintText: _ktcAmount,
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: MyColors.textFieldColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Spacer(),
              // Row(
              //   children: [
              //     const Text('Charge'),
              //     const Spacer(),
              //     Text(
              //       'KTC $_totalCharge',
              //       style: const TextStyle(
              //         color: Colors.green,
              //       ),
              //     )
              //   ],
              // ),
              if (_isButtonLoading) const LoadingSpinnerWithMargin(),
              if (!_isButtonLoading)
                SubmitButton(
                  action: _transferFunds,
                  title: 'Submit',
                )
            ],
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
        Text(
          content,
          style: const TextStyle(fontSize: 13),
        )
      ],
    );
  }
}
