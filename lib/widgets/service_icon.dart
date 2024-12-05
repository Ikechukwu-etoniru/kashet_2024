import 'package:flutter/material.dart';
import 'package:kasheto_flutter/screens/book_flight_screen.dart';
import 'package:kasheto_flutter/screens/buy_sell_crypto_screen.dart';
import 'package:kasheto_flutter/screens/verify_bank_transfer_account.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/airtime_data_purchase_screen.dart';
import 'package:kasheto_flutter/screens/bank_transfer_screen.dart';
import 'package:kasheto_flutter/screens/bill_payment_scren.dart';
import 'package:kasheto_flutter/screens/future_update_screen.dart';
import 'package:kasheto_flutter/screens/paypal_tx_screen.dart';
import 'package:kasheto_flutter/screens/send_request_money.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';

class ServiceIcons extends StatelessWidget {
  final int index;
  ServiceIcons({required this.index, Key? key}) : super(key: key);

  final List<String> _names = [
    'Airtime/Data Purchase',
    'Bill Payment',
    'Send/Request Money',
    'Paypal Transactions',
    'Bank Transfer'
  ];

  final List<String> _imageNames = [
    'images/airtime.png',
    'images/bill_payment.png',
    'images/send_money.png',
    'images/paypal.png',
  ];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).userList[0];
    return GestureDetector(
      onTap: () {
        if (index == 0 && user.userCurrency == null) {
          Alert.cantDialog(context: context);
        } else if (index == 0) {
          Navigator.of(context).pushNamed(AirtimeDataPurchaseScreen.routeName);
        } else if (index == 1 && user.userCurrency == null) {
          Alert.cantDialog(context: context);
        } else if (index == 1) {
          Navigator.of(context).pushNamed(BillPaymentScreen.routeName);
        } else if (index == 2 && user.userCurrency == null) {
          Alert.cantDialog(context: context);
        } else if (index == 2) {
          Navigator.of(context).pushNamed(SendRequestMoneyScreen.routeName);
        } else if (index == 3) {
          Navigator.of(context).pushNamed(PaypalTxScreen.routeName);
          // } else if (index == 4) {
          //   Navigator.of(context).pushNamed(BookFlightScreen.routeName);
          // } else if (index == 5) {
          //   Navigator.of(context).pushNamed(BuySellCryptoScreen.routeName);
          // } else if (index == 6) {
          //   Navigator.of(context).pushNamed(FutureUpdate.routeName);
        } else if (index == 4) {
          Navigator.of(context).pushNamed(VerifyBankTransferAccount.routeName);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(1, 5),
                    )
                  ]),
              child: index == 4
                  ? Padding(
                      padding: const EdgeInsets.all(3),
                      child: FaIcon(
                        FontAwesomeIcons.moneyBillTransfer,
                        color: MyColors.primaryColor.withOpacity(0.8),
                      ),
                    )
                  : Image.asset(_imageNames[index]),
            ),
            const SizedBox(
              height: 13,
            ),
            Text(
              _names[index],
              softWrap: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
