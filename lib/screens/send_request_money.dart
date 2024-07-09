import 'package:flutter/material.dart';

import '/widgets/request_money_page.dart';
import '/widgets/send_money_page.dart';

class SendRequestMoneyScreen extends StatefulWidget {
  static const routeName = '/send_request_money_screen.dart';
  const SendRequestMoneyScreen({Key? key}) : super(key: key);

  @override
  State<SendRequestMoneyScreen> createState() => _SendRequestMoneyScreenState();
}

class _SendRequestMoneyScreenState extends State<SendRequestMoneyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Send/Request Money'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
              ),
              child: TabBar(
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    7.0,
                  ),
                  color: Colors.white,
                ),
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black.withOpacity(0.7),
                tabs: const [
                  Tab(
                    text: 'Send Money',
                  ),
                  Tab(
                    text: 'Request Money',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabController, children: const [
                SendMoneyPage(),
                RequestMoneyPage(),
              ]),
            )
          ]),
        ),
      ),
    );
  }
}
