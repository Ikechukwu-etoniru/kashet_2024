import 'package:flutter/material.dart';
import 'package:kasheto_flutter/provider/transaction_provider.dart';
import 'package:kasheto_flutter/screens/generate_statement_screen.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/widgets/transaction_box.dart';
import 'package:provider/provider.dart';

class AllTransactionScreen extends StatelessWidget {
  static const routeName = '/all_transaction_screen.dart';
  const AllTransactionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _transactionList =
        Provider.of<TransactionProvider>(context).transactionList;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction History'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                width: double.infinity,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(GenerateStatementScreen.routeName);
                        },
                        child: Chip(
                            backgroundColor:
                                MyColors.primaryColor.withOpacity(0.5),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 20),
                              child: Text('Generate Statement'),
                            )),
                      )
                    ],
                  )
                ]),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _transactionList.length,
                  itemBuilder: ((context, index) => TransactionBox(
                        transaction: _transactionList[index],
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
