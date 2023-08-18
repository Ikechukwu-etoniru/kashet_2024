import 'package:flutter/material.dart';
import 'package:kasheto_flutter/widgets/buy_crypto_page.dart';
import 'package:kasheto_flutter/widgets/sell_crypto_page.dart';

class BuySellCryptoScreen extends StatefulWidget {
  static const routeName = '/buy_sell_crypto_screen.dart';
  const BuySellCryptoScreen({Key? key}) : super(key: key);

  @override
  State<BuySellCryptoScreen> createState() => _BuySellCryptoScreenState();
}

class _BuySellCryptoScreenState extends State<BuySellCryptoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Cryptocurrency'),
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
                    10.0,
                  ),
                  color: Colors.white,
                ),
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black.withOpacity(0.7),
                tabs: const [
                  Tab(
                    text: 'Buy',
                  ),
                  Tab(
                    text: 'Sell',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  BuyCryptoPage(),
                  SellCryptoPage()
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
