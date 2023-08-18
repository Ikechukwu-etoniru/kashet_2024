import 'package:flutter/material.dart';
import 'package:kasheto_flutter/models/billings.dart';
import 'package:kasheto_flutter/provider/billing_provider.dart';
import 'package:kasheto_flutter/widgets/error_widget.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:provider/provider.dart';

import '/widgets/airtime_purchase_page.dart';
import '/widgets/data_purchase_page.dart';

class AirtimeDataPurchaseScreen extends StatefulWidget {
  static const routeName = '/airtime_data_purchase_screen.dart';
  const AirtimeDataPurchaseScreen({Key? key}) : super(key: key);

  @override
  State<AirtimeDataPurchaseScreen> createState() =>
      _AirtimeDataPurchaseScreenState();
}

class _AirtimeDataPurchaseScreenState extends State<AirtimeDataPurchaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var _isLoading = false;
  var _isError = false;

  late List<BillingPlan> airtimePlan;
  late List<BillingPlan> dataPlan;

  Future _loadDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<BillingProvider>(context, listen: false).getOperators();
      airtimePlan = Provider.of<BillingProvider>(context, listen: false)
          .airtimeBillingList;
      dataPlan =
          Provider.of<BillingProvider>(context, listen: false).dataBillingList;
    } catch (error) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDetails();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingSpinnerWithScaffold()
        : _isError
            ? const IsErrorScreen()
            : SafeArea(
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    title: const Text('Airtime/Data'),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 2),
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                        child: TabBar(
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
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
                              text: 'Airtime',
                            ),
                            Tab(
                              text: 'Data',
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child:
                            TabBarView(controller: _tabController, children: [
                          AirtimePurchasePage(airtimePlan: airtimePlan),
                          DataPurchasePage(
                            dataPlan: dataPlan,
                          ),
                        ]),
                      )
                    ]),
                  ),
                ),
              );
  }
}
