import 'package:flutter/material.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/bank_transfer_screen.dart';
import 'package:kasheto_flutter/screens/bill_payment_scren.dart';
import 'package:kasheto_flutter/screens/initialization_screen.dart';
import 'package:kasheto_flutter/screens/withdraw_money_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:provider/provider.dart';

class WithdrawPaypalToNaira extends StatefulWidget {
  final String ktcValue;
  const WithdrawPaypalToNaira({required this.ktcValue, Key? key})
      : super(key: key);

  @override
  State<WithdrawPaypalToNaira> createState() => _WithdrawPaypalToNairaState();
}

class _WithdrawPaypalToNairaState extends State<WithdrawPaypalToNaira> {
  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  InitializationScreen.routeName, (route) => false);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: _deviceHeight * 0.3,
                width: double.infinity,
                child: Image.asset(
                  'images/happy_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
              const Text(
                'Your Paypal deposit was successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
              const SizedBox(
                height: 50,
              ),
              RichText(
                text: TextSpan(
                    text: 'KTC ${widget.ktcValue}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    children: const [
                      TextSpan(
                        text:
                            ' has been added to your wallet balance.\nWhat next !!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    ]),
              ),
              WhatNextContainer(
                onpressed: () {
                  if (Provider.of<AuthProvider>(context).userVerified ==
                      IDStatus.approved) {
                    Navigator.of(context)
                        .pushNamed(WithdrawMoneyScreen.routeName);
                  } else {
                    Alert.idMustBeVerifiedDialog(context: context);
                  }
                },
                title: 'Withdraw to your bank account',
              ),
              WhatNextContainer(
                onpressed: () {
                  Navigator.of(context).pushNamed(BankTransfer.routeName);
                },
                title: 'Send Money',
              ),
              WhatNextContainer(
                onpressed: () {
                  Navigator.of(context).pushNamed(BillPaymentScreen.routeName);
                },
                title: 'Pay Bills',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WhatNextContainer extends StatelessWidget {
  final String title;
  final VoidCallback onpressed;
  const WhatNextContainer(
      {required this.onpressed, required this.title, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.green[50],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: onpressed,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 17,
            ),
          )
        ],
      ),
    );
  }
}
