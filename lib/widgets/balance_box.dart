import 'package:flutter/material.dart';
import 'package:kasheto_flutter/provider/bank_provider.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/add_money_screen.dart';
import 'package:kasheto_flutter/screens/withdraw_money_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:provider/provider.dart';

class BalanceBox extends StatelessWidget {
  final double width;
  final String text;
  final int id;
  const BalanceBox(
      {required this.text, required this.id, required this.width, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userBankStatus =
        Provider.of<BankProvider>(context, listen: false).userBankList.isEmpty;
    final user = Provider.of<AuthProvider>(context, listen: false).userList[0];
    final userIdStatus = Provider.of<AuthProvider>(context).userVerified;
    return GestureDetector(
      onTap: () {
        if (id == 1) {
          if (user.userCurrency == null) {
            Alert.cantDialog(context: context);
          } else {
            Navigator.of(context).pushNamed(AddMoneyScreen.routeName);
          }
        } else if (id == 2) {
          if (user.userCurrency == null) {
            Alert.cantDialog(context: context);
          } else if (userBankStatus == true) {
            Alert.mustAddBankDialog(context: context);
          } else if (userIdStatus != IDStatus.approved) {
            Alert.idMustBeVerifiedDialog(context: context);
          } else {
            Navigator.of(context).pushNamed(WithdrawMoneyScreen.routeName);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 35,
        width: width,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 9,
                  backgroundColor: Colors.yellow,
                  child: Center(
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: Colors.yellowAccent,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 3,
                    backgroundColor: id == 1 ? Colors.blue : Colors.red,
                    child: FittedBox(
                      child: Icon(
                        id == 1 ? Icons.add : Icons.remove,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
            FittedBox(
              child: Text(
                text,
                style:
                    const TextStyle(color: MyColors.primaryColor, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
