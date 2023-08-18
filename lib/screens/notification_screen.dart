import 'package:flutter/material.dart';
import 'package:kasheto_flutter/models/money_request.dart';
import 'package:kasheto_flutter/provider/money_request_provider.dart';
import 'package:kasheto_flutter/screens/money_request_screen.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = '/notification_screen.dart';

  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<MoneyRequest> get _pendingMoneyRequestList {
    return Provider.of<MoneyRequestProvider>(context, listen: false).pendingReceivedMoneyRequest;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Notification',
          ),
        ),
        body: _pendingMoneyRequestList.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 120,
                        width: 120,
                        child: Image.asset(
                          'images/unavailable_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'You have no notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Go Back',
                      ),
                    )
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: ListView.builder(
                    itemCount: _pendingMoneyRequestList.length,
                    itemBuilder: (_, index) {
                      return NotificationBox(mr: _pendingMoneyRequestList[index]);
                    }),
              ),
      ),
    );
  }
}

class NotificationBox extends StatelessWidget {
  final MoneyRequest mr;

  const NotificationBox({required this.mr, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const MoneyRequestScreen(pageNumber: 1),
      )),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'You have a new fund request',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${mr.name} requested payment',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.grey,
              ),
            ],
          ),
          const Divider()
        ],
      ),
    );
  }
}
