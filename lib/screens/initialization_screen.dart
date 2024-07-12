import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kasheto_flutter/models/money_request.dart';
import 'package:kasheto_flutter/provider/bank_provider.dart';
import 'package:kasheto_flutter/provider/location_provider.dart';
import 'package:kasheto_flutter/provider/money_request_provider.dart';
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/provider/transaction_provider.dart';
import 'package:kasheto_flutter/provider/wallet_provider.dart';
import 'package:kasheto_flutter/screens/login_screen.dart';
import 'package:kasheto_flutter/screens/main_screen.dart';
import 'package:kasheto_flutter/screens/update_image_screen.dart';
import 'package:kasheto_flutter/screens/verify_email_screen.dart';
import 'package:kasheto_flutter/screens/verify_number_screen.dart';
import 'package:kasheto_flutter/utils/notifications.dart';
import 'package:kasheto_flutter/widgets/error_widget.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:provider/provider.dart';

class InitializationScreen extends StatefulWidget {
  static const routeName = '/initialization_screen.dart';
  const InitializationScreen({Key? key}) : super(key: key);

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  var _isError = false;
  var _isLoading = false;

  var _checkEmail = false;
  var _checkNumber = false;
  var _checkImage = false;
  var _verified = false;
  var errorr = '';

  Future<void> _initializeApp() async {
    // Making all this false else even when verified, verify screen will still show up
    _checkEmail = false;
    _checkNumber = false;
    _checkImage = false;
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .fetchUserDetails();
      final user =
          Provider.of<AuthProvider>(context, listen: false).userList[0];

      // Check databse for verification status then show verification screen accordingly
      if (user.imageUrl ==
          'https://res.cloudinary.com/anifowosetobi/image/upload/v1601500323/user_korsis.png') {
        _checkImage = true;
      } else if (user.isNumberVerified == null) {
        _checkNumber = true;
      } else if (user.isEmailVerified == null) {
        _checkEmail = true;
      } else {
        _verified = true;
      }

      if (_verified = false) {
        return;
      }
      await Provider.of<TransactionProvider>(context, listen: false)
          .getAllTransactions();
      await Provider.of<WalletProvider>(context, listen: false)
          .getWalletBalance();
      await Provider.of<BankProvider>(context, listen: false)
          .getUserBanksInformation();
      await Provider.of<LocationProvider>(context, listen: false)
          .getCountriesList();
      await Provider.of<MoneyRequestProvider>(context, listen: false)
          .getSentMoneyReqestList();
      await Provider.of<MoneyRequestProvider>(context, listen: false)
          .getReceivedMoneyReqestList();
      await Provider.of<PlatformChargesProvider>(context, listen: false)
          .getExchangeRate();
      await Provider.of<AuthProvider>(context, listen: false)
          .checkVerificationStatus();
      List<MoneyRequest> _pendingMr =
          Provider.of<MoneyRequestProvider>(context, listen: false)
              .pendingReceivedMoneyRequest;
      if (_pendingMr.length == 1) {
        Notifications.notifyUser(
            title: 'Money Request',
            body:
                '${_pendingMr[0].name} has requested K${_pendingMr[0].ktcValue} from you');
      }
      if (_pendingMr.length > 1) {
        Notifications.notifyUser(
            title: 'Money Request',
            body: '${_pendingMr.length} users have requested payment from you');
      }
    } catch (error) {
      print(error);
      setState(() {
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? const Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingSpinner(),
                  ],
                ),
              )
            : _checkNumber
                ? const VerifyNumberScreen()
                : _checkEmail
                    ? const VerifyEmailScreen()
                    : _checkImage
                        ? const UpdateImageScreen()
                        : _isError
                            ? IsErrorScreen(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(LoginScreen.routeName);
                                },
                              )
                            : const MainScreen(),
      ),
    );
  }
}
