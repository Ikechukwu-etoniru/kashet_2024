import 'package:flutter/material.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/widgets/balance_box.dart';
import 'package:provider/provider.dart';

import '../../provider/wallet_provider.dart';

class BlackBox extends StatelessWidget {
  final double height;
  const BlackBox({required this.height, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final walletBalance = Provider.of<WalletProvider>(context).walletBalance;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: LayoutBuilder(builder: (context, constraint) {
        return Stack(
          children: [
            Positioned(
              bottom: 0,
              child: Image.asset(
                'images/wave.png',
                fit: BoxFit.fitWidth,
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const Text(
                      'Kasheto Balance',
                      style: TextStyle(color: MyColors.primaryColor),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'K ${walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BalanceBox(
                          width: constraint.maxWidth * 0.4,
                          text: 'Add Money',
                          id: 1,
                        ),
                        SizedBox(
                          width: constraint.maxWidth * 0.06,
                        ),
                        BalanceBox(
                          width: constraint.maxWidth * 0.4,
                          text: 'Withdraw',
                          id: 2,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
