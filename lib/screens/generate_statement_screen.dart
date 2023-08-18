import 'package:flutter/material.dart';
import 'package:kasheto_flutter/models/transaction.dart';
import 'package:kasheto_flutter/provider/transaction_provider.dart';
import 'package:kasheto_flutter/provider/wallet_provider.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/pdf_helper.dart';
// import 'package:kasheto_flutter/utils/pdf_helper.dart';
import 'package:kasheto_flutter/widgets/date_selecter.dart';
import 'package:provider/provider.dart';

class GenerateStatementScreen extends StatefulWidget {
  static const routeName = '/generate_statement_screen.dart';
  const GenerateStatementScreen({Key? key}) : super(key: key);

  @override
  State<GenerateStatementScreen> createState() =>
      _GenerateStatementScreenState();
}

class _GenerateStatementScreenState extends State<GenerateStatementScreen> {
  DateTime? startDate;
  DateTime? endDate;
  var _isLoading = false;

  void getStartDate(DateTime date) {
    startDate = date;
  }

  void getEndDate(DateTime date) {
    endDate = date;
  }

  bool _validateForm() {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: 'Select a start date', context: context));
      return false;
    } else if (endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: 'Select an end date', context: context));
      return false;
    } else {
      return true;
    }
  }

  num get walletBalance {
    return Provider.of<WalletProvider>(context, listen: false).walletBalance;
  }

  Future _generatePdf() async {
    final _isValid = _validateForm();
    if (_isValid) {
      try {
        setState(() {
          _isLoading = true;
        });
        List<Transaction> _listByRange =
            Provider.of<TransactionProvider>(context, listen: false)
                .transactionsByRange(startDate!, endDate!);
        final moneyOutList =
            _listByRange.where((e) => e.amount.contains('-')).toList();
        final moneyInList =
            _listByRange.where((e) => !e.amount.contains('-')).toList();
        var moneyOutInitialValue = 0.0;
        var moneyInInitialValue = 0.0;

        final moneyOutBal = moneyOutList.fold<double>(moneyOutInitialValue,
            (previousValue, element) {
          return previousValue + double.parse(element.amount);
        });
        final moneyInBal = moneyInList.fold<double>(moneyInInitialValue,
            (previousValue, element) {
          return previousValue + double.parse(element.amount);
        });

        final pdfFile = await PdfInvoiceApi.generate(
            transaction: _listByRange,
            balance: walletBalance,
            moneyInBal: moneyInBal,
            moneyOutBal: moneyOutBal);
        Alert.showInfoDialog(context: context, info: pdfFile.path);
        PdfApi.openFile (pdfFile);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(
            message: 'An error occured generating pdf',
            context: context,
          ),
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
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose a time frame for your statement'),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Start Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              DateSelecter(getStartDate),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'End Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              DateSelecter(getEndDate),
              const SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  const Spacer(),
                  if (_isLoading) const CircularProgressIndicator.adaptive(),
                  if (!_isLoading)
                    GestureDetector(
                      onTap: () {
                        _generatePdf();
                      },
                      child: const Chip(
                          backgroundColor: MyColors.primaryColor,
                          label: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 20),
                            child: Text('Generate PDF'),
                          )),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
