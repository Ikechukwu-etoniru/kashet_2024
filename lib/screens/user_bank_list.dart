import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:kasheto_flutter/models/bank.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/provider/bank_provider.dart';
import 'package:kasheto_flutter/screens/add_bank_screen.dart';
import 'package:kasheto_flutter/screens/edit_bank_screen.dart';
import 'package:kasheto_flutter/screens/personal_details_screen.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:provider/provider.dart';

import '../utils/alerts.dart';

class UserBankList extends StatefulWidget {
  static const routeName = '_user_bank_list.dart';
  const UserBankList({Key? key}) : super(key: key);

  @override
  State<UserBankList> createState() => _UserBankListState();
}

class _UserBankListState extends State<UserBankList> {
  @override
  Widget build(BuildContext context) {
    final _banks = Provider.of<BankProvider>(context).userBankList;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Bank List'),
        ),
        body: Column(children: [
          Expanded(
            child: _banks.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: Image.asset(
                          'images/unavailable_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'You have not added any bank yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (Provider.of<AuthProvider>(context, listen: false)
                                  .userVerified !=
                              IDStatus.approved) {
                            Alert.showerrorDialog(
                                context: context,
                                text:
                                    'Your account is under review or has not yet been verified. You can only carry out this action after your account has been verified. Please excercise patience and try again later',
                                onPressed: () {
                                  Navigator.of(context).pop();
                                });
                          } else {
                            Navigator.of(context)
                                .pushNamed(AddBankScreen.routeName);
                          }
                        },
                        child: const Text(
                          'Click here to add bank',
                        ),
                      )
                    ],
                  )
                : ListView.builder(
                    itemCount: _banks.length,
                    itemBuilder: (context, index) {
                      return UserBankBox(
                        bank: _banks[index],
                      );
                    }),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: IconButton(
                onPressed: () {
                  if (Provider.of<AuthProvider>(context, listen: false)
                          .userVerified !=
                      IDStatus.approved) {
                    Alert.showerrorDialog(
                        context: context,
                        text:
                            'Your account is under review or has not yet been verified. You can only carry out this action after your account has been verified. Please excercise patience and try again later',
                        onPressed: () {
                          Navigator.of(context).pop();
                        });
                  } else {
                    Navigator.of(context).pushNamed(AddBankScreen.routeName);
                  }
                },
                icon: const Icon(
                  Icons.add,
                  color: MyColors.primaryColor,
                  size: 30,
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

class UserBankBox extends StatefulWidget {
  final UserBank bank;
  const UserBankBox({required this.bank, Key? key}) : super(key: key);

  @override
  State<UserBankBox> createState() => _UserBankBoxState();
}

class _UserBankBoxState extends State<UserBankBox> {
  var _isLoading = false;

  Future _deleteBank(int bankId) async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    try {
      Provider.of<BankProvider>(context, listen: false).deleteBank(
          bankId: bankId, context: context, route: UserBankList.routeName);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 3,
              spreadRadius: 7,
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 10,
            ),
          ]),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(0.0),
                width: 30.0,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _deleteBank(widget.bank.id!);
                  },
                  icon: _isLoading
                      ? const SpinKitDoubleBounce(
                          color: Colors.red,
                          size: 20,
                        )
                      : const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
                        ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Container(
                padding: const EdgeInsets.all(0.0),
                width: 30.0,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return EditBankScreen(
                        bank: widget.bank,
                      );
                    }));
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          ProfileRow(
              title: 'Account Name', content: widget.bank.acctName ?? ""),
          ProfileRow(
              title: 'Account Number', content: widget.bank.acctNumber ?? ""),
          ProfileRow(title: 'Bank Name', content: widget.bank.bankName ?? ""),
        ],
      ),
    );
  }
}
