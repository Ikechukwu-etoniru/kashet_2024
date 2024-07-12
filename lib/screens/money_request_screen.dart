import 'package:flutter/material.dart';
import 'package:kasheto_flutter/provider/money_request_provider.dart';
import 'package:kasheto_flutter/widgets/money_request_page.dart';
import 'package:provider/provider.dart';

class MoneyRequestScreen extends StatefulWidget {
  static const routeName = '/money_request_screen.dart';
  final int pageNumber;
  const MoneyRequestScreen({required this.pageNumber, Key? key})
      : super(key: key);

  @override
  State<MoneyRequestScreen> createState() => _MoneyRequestScreenState();
}

class _MoneyRequestScreenState extends State<MoneyRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.pageNumber);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var sentMoneyRequest =
        Provider.of<MoneyRequestProvider>(context, listen: false)
            .sentMoneyRequestList;
    var receivedMoneyRequest =
        Provider.of<MoneyRequestProvider>(context, listen: false)
            .receivedMoneyRequestList;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Money Request'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
              ),
              child: TabBar(
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    7,
                  ),
                  color: Colors.white,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black.withOpacity(0.7),
                tabs: const [
                  Tab(
                    text: 'Sent',
                  ),
                  Tab(
                    text: 'Received',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabController, children: [
                MoneyRequestPage(
                  mrList: sentMoneyRequest,
                  pageNumber: 0,
                ),
                MoneyRequestPage(
                  mrList: receivedMoneyRequest,
                  pageNumber: 1,
                ),
              ]),
            )
          ]),
        ),
      ),
    );
  }
}
