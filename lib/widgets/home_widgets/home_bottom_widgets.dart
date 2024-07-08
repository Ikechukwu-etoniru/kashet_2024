import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/provider/money_request_provider.dart';
import 'package:kasheto_flutter/provider/transaction_provider.dart';
import 'package:kasheto_flutter/screens/all_transactions_screen.dart';
import 'package:kasheto_flutter/screens/id_declined_screen.dart';
import 'package:kasheto_flutter/screens/money_request_screen.dart';
import 'package:kasheto_flutter/screens/security_settings_screen.dart';
import 'package:kasheto_flutter/screens/verify_id_card_screen.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/widgets/service_icon.dart';
import 'package:kasheto_flutter/widgets/transaction_box.dart';
import 'package:provider/provider.dart';

class HomeServiceMenu extends StatelessWidget {
  final double height;

  const HomeServiceMenu({required this.height, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 0,
        right: 15,
        top: 10,
        bottom: 10,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      height: height,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.07),
                blurRadius: 3,
                spreadRadius: 5),
            BoxShadow(
                color: Colors.grey.withOpacity(0.02),
                blurRadius: 10,
                spreadRadius: 20)
          ]),
      child: ListView.builder(
          itemCount: 5,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return ServiceIcons(
              index: index,
            );
          }),
    );
  }
}

class VerifyIdWidget extends StatelessWidget {
  const VerifyIdWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.of<AuthProvider>(context).userVerified ==
            IDStatus.notSubmitted
        ? GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(VerifyIdCardScreen.routeName);
            },
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.07),
                        blurRadius: 3,
                        spreadRadius: 5),
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.02),
                        blurRadius: 10,
                        spreadRadius: 20)
                  ]),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'images/cert.svg',
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verify Your Identity',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "To ensure the security of your account and to enjoy all our features, verify your identity",
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        )
                      ],
                    ),
                  ),
                  const Column(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.red,
                        size: 30,
                      ),
                      Expanded(child: SizedBox())
                    ],
                  ),
                ],
              ),
            ),
          )
        : Provider.of<AuthProvider>(context).userVerified == IDStatus.pending
            ? GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(VerifyIdCardScreen.routeName);
                },
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.07),
                            blurRadius: 3,
                            spreadRadius: 5),
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.02),
                            blurRadius: 10,
                            spreadRadius: 20)
                      ]),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'images/cert.svg',
                        height: 100,
                        width: 100,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Identity Verification is Pending',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "We're currently reviewing your submitted ID, and we kindly request 24-48 hours to complete the verification process.",
                              style: TextStyle(
                                fontSize: 11,
                              ),
                            )
                          ],
                        ),
                      ),
                      const Column(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Colors.yellow,
                            size: 30,
                          ),
                          Expanded(child: SizedBox())
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Provider.of<AuthProvider>(context).userVerified ==
                    IDStatus.declined
                ? GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(IdDeclinedScreen.routeName);
                    },
                    child: Container(
                      height: 130,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.07),
                                blurRadius: 3,
                                spreadRadius: 5),
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.02),
                                blurRadius: 10,
                                spreadRadius: 20)
                          ]),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'images/cert.svg',
                            height: 100,
                            width: 100,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Identity Card Verification Declined',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "We regret to inform you that the ID you submitted has been disapproved.",
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const Column(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: Colors.red,
                                size: 30,
                              ),
                              Expanded(child: SizedBox())
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox();
  }
}

class HomeMiddleWidget extends StatelessWidget {
  const HomeMiddleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int? faStatus = Provider.of<AuthProvider>(context).faStatus;
    if (faStatus == 0) {
      return LayoutBuilder(builder: (context, constraint) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(SecuritySettingsScreen.routeName);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.07),
                      blurRadius: 3,
                      spreadRadius: 5),
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.02),
                      blurRadius: 10,
                      spreadRadius: 20)
                ]),
            child: Row(
              children: [
                SizedBox(
                  height: 150,
                  width: constraint.maxWidth * 0.3,
                  child: Image.asset(
                    'images/enable_2fa.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enable',
                        style: TextStyle(
                            fontSize: 15, color: MyColors.primaryColor),
                      ),
                      Text(
                        '2-Factor Authenciation',
                        style: TextStyle(
                            fontSize: 12, color: MyColors.primaryColor),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Provide more security for your account',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    } else {
      return const SizedBox();
    }
  }
}

class HomeFundRequestContainer extends StatelessWidget {
  const HomeFundRequestContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final receivedMoneyRequest =
        Provider.of<MoneyRequestProvider>(context).receivedMoneyRequestList;
    final sentMoneyRequest =
        Provider.of<MoneyRequestProvider>(context).sentMoneyRequestList;
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth * 0.9,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.07),
                  blurRadius: 3,
                  spreadRadius: 5),
              BoxShadow(
                  color: Colors.grey.withOpacity(0.02),
                  blurRadius: 10,
                  spreadRadius: 20)
            ]),
        child: Row(
          children: [
            SizedBox(
              height: 100,
              width: constraints.maxWidth * 0.3,
              child: Image.asset(
                'images/money_request.png',
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) {
                        return const MoneyRequestScreen(pageNumber: 1);
                      }));
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'You have received',
                                style: TextStyle(fontSize: 10),
                              ),
                              Text(
                                '${receivedMoneyRequest.length} fund request',
                                style: const TextStyle(
                                  color: MyColors.primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: MyColors.primaryColor,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: MyColors.primaryColor,
                    thickness: 0.5,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const MoneyRequestScreen(pageNumber: 0),
                    )),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'You have sent',
                                style: TextStyle(fontSize: 10),
                              ),
                              Text(
                                '${sentMoneyRequest.length} fund request',
                                style: const TextStyle(
                                    color: MyColors.primaryColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: MyColors.primaryColor,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class HomePageBottomBar extends StatelessWidget {
  const HomePageBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final first10Transactions =
        Provider.of<TransactionProvider>(context).first10Transactions;
    return Container(
      color: Colors.white,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Row(
              children: [
                if (first10Transactions.isEmpty)
                  const SizedBox(
                    height: 40,
                  ),
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    wordSpacing: 2,
                    fontFamily: 'Raleway',
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                if (first10Transactions.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      if (first10Transactions.isEmpty) {
                      } else {
                        Navigator.of(context)
                            .pushNamed(AllTransactionScreen.routeName);
                      }
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  )
              ],
            ),
          ),
          if (first10Transactions.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset(
                    'images/unavailable_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text('You have no transactions yet !!!!')
              ],
            ),
          if (first10Transactions.isNotEmpty)
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                itemCount: first10Transactions.length,
                itemBuilder: (context, index) {
                  return TransactionBox(
                    transaction: first10Transactions[index],
                  );
                }),
          const SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }
}
