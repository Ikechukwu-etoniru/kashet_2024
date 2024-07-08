import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kasheto_flutter/models/transaction.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';

class TransactionBox extends StatelessWidget {
  final Transaction transaction;
  const TransactionBox({required this.transaction, Key? key}) : super(key: key);
  String _txDate() {
    var time = transaction.createDate;
    var inDateTime = DateTime(
      int.parse(time.substring(0, 4)),
      int.parse(time.substring(5, 7)),
      int.parse(time.substring(8, 10)),
      int.parse(time.substring(11, 13)),
      int.parse(time.substring(14, 16)),
    );
    return DateFormat.yMMMMEEEEd().format(inDateTime);
  }

  String get txSymbol {
    if (transaction.currency == "NGN") {
      return '₦';
    } else if (transaction.currency == "USD") {
      return '\$';
    } else {
      return '';
    }
  }

  String get txAmount {
    final _editedAmount = double.parse(transaction.amount.replaceAll(r'-', ''))
        .toStringAsFixed(2);
    return _editedAmount;
  }

  String get txTitle {
    if (transaction.description.contains('AIRTIME')) {
      return 'Airtime Purchase';
    } else if (transaction.description.contains('You sent')) {
      return 'Fund Transfer';
    } else if (transaction.description.contains('Credited wallet')) {
      return 'Account Funding';
    } else if (transaction.description.contains('DStv') ||
        transaction.description.contains('DSTV')) {
      return 'DSTV Subscription ';
    } else if (transaction.description.contains('GOTV') ||
        transaction.description.contains('GOtv')) {
      return 'GOTV Subscription';
    } else if (transaction.description.contains('One')) {
      return 'Startimes Subscription';
    } else if (transaction.description.contains('Transferred')) {
      return 'Fund Transfer';
    } else if (transaction.description.contains('TOPUP')) {
      return 'Electricity Topup';
    } else if (transaction.description.contains('Withdrawal')) {
      return 'Withdrawal';
    } else if (transaction.description.contains('received') ||
        transaction.description.contains('recieved')) {
      return 'Received Funds';
    } else if (transaction.description.contains('MTN') &&
        (transaction.description.contains('DATA') ||
            transaction.description.contains('data'))) {
      return 'MTN Data Purchase';
    } else if (transaction.description.contains('GLO') &&
        (transaction.description.contains('DATA') ||
            transaction.description.contains('data'))) {
      return 'GLO Data Purchase';
    } else if (transaction.description.contains('9MOBILE') &&
        (transaction.description.contains('DATA') ||
            transaction.description.contains('data'))) {
      return '9MOBILE Data Purchase';
    } else if (transaction.description.contains('AIRTEL') &&
        (transaction.description.contains('DATA') ||
            transaction.description.contains('data'))) {
      return 'AIRTEL Data Purchase';
    } else {
      return transaction.description;
    }
  }

  Future showDesDialog(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset(
                        'images/kasheto_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      const Text(
                        'Title',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        txTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                        'Amount',
                        style: TextStyle(fontSize: 11),
                      ),
                      const Spacer(),
                      Text(
                        '$txSymbol $txAmount',
                        style: TextStyle(
                          fontFamily: '',
                          color: transaction.type == TransactionType.credit
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                        'Date',
                        style: TextStyle(fontSize: 11),
                      ),
                      const Spacer(),
                      Text(
                        _txDate(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Row(
                    children: [
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer()
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    transaction.description,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: MyColors.primaryColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDesDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: transaction.type == TransactionType.credit
                      ? Colors.lightGreen
                      : Colors.redAccent),
              alignment: Alignment.center,
              child: FaIcon(
                transaction.type == TransactionType.credit
                    ? FontAwesomeIcons.suitcase
                    : FontAwesomeIcons.squareMinus,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  _txDate(),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '$txSymbol $txAmount',
              style: TextStyle(
                fontFamily: '',
                color: transaction.type == TransactionType.credit
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
