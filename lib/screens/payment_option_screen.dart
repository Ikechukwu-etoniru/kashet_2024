import 'package:flutter/material.dart';
import 'package:kasheto_flutter/models/user.dart';
import 'package:kasheto_flutter/provider/transaction_provider.dart';
import 'package:kasheto_flutter/screens/successful_transaction_screen.dart';
import 'package:kasheto_flutter/screens/web_view_pages.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/widgets/card_container.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:provider/provider.dart';

import '/provider/user_card_provider.dart';

class PaymentOptionScreen extends StatefulWidget {
  static const routeName = '/payment_option_screen.dart';
  final SendUserDetails receiver;
  const PaymentOptionScreen({required this.receiver, Key? key})
      : super(key: key);

  @override
  State<PaymentOptionScreen> createState() => _PaymentOptionScreenState();
}

class _PaymentOptionScreenState extends State<PaymentOptionScreen> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;

    final _usercardList = Provider.of<UserCardProvider>(context).userCardList;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Option'),
        ),
        body: _isLoading
            ? const LoadingSpinner()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    SizedBox(
                      height: _deviceHeight * 0.05,
                    ),
                    SizedBox(
                      height: _deviceHeight * 0.1,
                      child: const Text(
                          'Please select a payment option to continue with your transaction'),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          CardContainer(
                              card: _usercardList[0],
                              width: _deviceWidth,
                              action: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  final _response = await Provider.of<
                                              TransactionProvider>(context,
                                          listen: false)
                                      .sendMoney(
                                          email: widget.receiver.email,
                                          name: widget.receiver.name,
                                          amount: widget.receiver.amount,
                                          ktcValue: widget.receiver.ktcValue,
                                          // For now only currency is NGN
                                          currency: widget.receiver.currency,
                                          user: widget.receiver.user);

                                  if (_response['success'] == true) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (context) {
                                      return SuccessfulTransactionScreen(
                                          message: _response['message']);
                                    }));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        Alert.snackBar(
                                            message: ApiUrl.errorString,
                                            context: context));
                                  }
                                } catch (error) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    Alert.snackBar(
                                        message: error.toString(),
                                        context: context),
                                  );
                                }
                              }),
                          CardContainer(
                              card: _usercardList[1],
                              width: _deviceWidth,
                              action: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  final response =
                                      await Provider.of<TransactionProvider>(
                                              context,
                                              listen: false)
                                          .sendMoneyToAnotherUser(
                                    charges: widget.receiver.charges,
                                    currency: widget.receiver.currency,
                                    amount: widget.receiver.amount,
                                    id: widget.receiver.user,
                                  );
                                  if (response != null) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return WebViewTransferPage(
                                        url: response,
                                        appbarTitle: 'Send Money',
                                      );
                                    }));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        Alert.snackBar(
                                            message: ApiUrl.errorString,
                                            context: context));
                                  }
                                } catch (error) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    Alert.snackBar(
                                        message: error.toString(),
                                        context: context),
                                  );
                                }
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
