import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/screens/web_view_pages.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';

class PaypalTxScreen extends StatefulWidget {
  static const routeName = '/paypal_tx_screen.dart';
  const PaypalTxScreen({Key? key}) : super(key: key);

  @override
  State<PaypalTxScreen> createState() => _PaypalTxScreenState();
}

class _PaypalTxScreenState extends State<PaypalTxScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  double _ktcValue = 0.00;
  var _isLoading = false;

  void _getKtcValue() {
    double? dollarsToKtc =
        Provider.of<PlatformChargesProvider>(context, listen: false)
            .dollarsToKtc;
    _ktcValue = double.parse(_amountController.text) * dollarsToKtc;
  }

  String get _platformChargeForDeposit {
    if (_amountController.text.isEmpty) {
      return '0.00';
    }
    return Provider.of<PlatformChargesProvider>(context, listen: false)
        .depositDollarsCharges(_amountController.text);
  }

  String get _totalDepositAmount {
    if (_amountController.text.isEmpty) {
      return '0.00';
    } else {
      double tAmount = double.parse(_amountController.text) +
          double.parse(_platformChargeForDeposit);
      return tAmount.toStringAsFixed(2);
    }
  }

  String get _nairaAmount {
    if (_amountController.text.isEmpty) {
      return '0.00';
    } else {
      double nAmount = _ktcValue /
          double.parse(
              Provider.of<PlatformChargesProvider>(context, listen: false)
                  .nairaToKtc
                  .toString());
      return nAmount.toStringAsFixed(2);
    }
  }

  Future _depositPaypal() async {
    final _isConfirmed = await Alert.showExchangeUsdtoNairaDialog(
        context: context,
        totalAmount: '\$ $_totalDepositAmount',
        nairaValue: '₦ $_nairaAmount',
        charges: '\$ $_platformChargeForDeposit',
        ktcValue: 'KTC $_ktcValue');
    if (_isConfirmed != null && _isConfirmed) {
      try {
        setState(() {
          _isLoading = true;
        });
        final url = Uri.parse('${ApiUrl.baseURL}user/pay');
        final header = await ApiUrl.setHeaders();
        final body = json.encode({
          "currency": "USD",
          "payment_method": "paypal",
          "amount": _amountController.text,
          "charges": _platformChargeForDeposit
        });
        final response = await http.post(url, body: body, headers: header);
        final res = json.decode(response.body);
        if (response.statusCode == 200) {
          final paypalWebviewLink = res['details']['href'];
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return WebViewPagesPaypalToNaira(
              appbarTitle: 'Paypal Exchange',
              url: paypalWebviewLink,
              amount: 'USD ${_amountController.text}',
              ktcAmount: _ktcValue.toString(),
            );
          }));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(
                message: 'An error occured, could not process transaction',
                context: context),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paypal Exchange'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextFieldText(text: 'Amount (\$)'),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: _amountController,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        _ktcValue = 0.0;
                      });
                    } else {
                      setState(() {
                        _getKtcValue();
                      });
                    }
                  },
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    } else if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    } else if (double.parse(value) <= 19.99) {
                      return 'Enter a value above 20';
                    } else {
                      return null;
                    }
                  }),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    contentPadding: MyPadding.textFieldContentPadding,
                    isDense: true,
                    hintText: 'Value of paypal funds',
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text(
                      'Charges',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$ $_platformChargeForDeposit',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: '',
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Text(
                      'You\'ll deposit ',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$ $_totalDepositAmount ',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: '',
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Text(
                      'You\'ll receive',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'KTC $_ktcValue',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: '',
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Text(
                      'Naira Amount ',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₦ $_nairaAmount ',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: '',
                      ),
                    )
                  ],
                ),
                if (_isLoading) const LoadingSpinnerWithMargin(),
                if (!_isLoading)
                  SubmitButton(
                    action: () {
                      final _isValid = _formKey.currentState!.validate();
                      if (_isValid) {
                        FocusScope.of(context).unfocus();
                        _depositPaypal();
                      }
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
