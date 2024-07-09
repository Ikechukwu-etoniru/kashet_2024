import 'package:flutter/material.dart';

import '/screens/dstv_subscribtion_screen.dart';
import '/screens/electric_bill_subscription_screen.dart';
import '/screens/gotv_subscription_screen.dart';
import '/screens/startime_subscription_screen.dart';

class BillPaymentScreen extends StatelessWidget {
  static const routeName = '/bill_payment_screen.dart';

  BillPaymentScreen({Key? key}) : super(key: key);

  final List<String> _billPaymentServices = [
    'DSTV Subscriptions',
    'GoTV Subscriptions',
    'StarTimes Subscriptions',
    'Electricity Bills'
  ];

  final List<String> _billPaymentServicesLogo = [
    'images/dstv_logo.png',
    'images/gotv_logo.png',
    'images/startime_logo.png',
    'images/electricity_logo.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bill Payment'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Select your desired service provider for bill payment.',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: _billPaymentServices.length,
                    itemBuilder: (context, index) {
                      return BillPaymentServiceContainer(
                        index: index,
                        title: _billPaymentServices[index],
                        imageTitle: _billPaymentServicesLogo[index],
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BillPaymentServiceContainer extends StatelessWidget {
  final int index;
  final String title;
  final String imageTitle;

  const BillPaymentServiceContainer(
      {required this.index,
      required this.title,
      required this.imageTitle,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.of(context).pushNamed(DstvSubscriptionScreen.routeName);
        } else if (index == 1) {
          Navigator.of(context).pushNamed(GotvSubscriptionScreen.routeName);
        } else if (index == 2) {
          Navigator.of(context).pushNamed(StartimeSubscriptionScreen.routeName);
        } else if (index == 3) {
          Navigator.of(context)
              .pushNamed(ElectricBillSubscriptionScreen.routeName);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 5,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: 40,
              child: Image.asset(
                imageTitle,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_right_rounded,
              color: Colors.grey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
