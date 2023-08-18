import 'package:flutter/cupertino.dart';
import 'package:kasheto_flutter/models/http_exceptions.dart';
import 'package:kasheto_flutter/provider/money_request_provider.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/provider/wallet_provider.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:provider/provider.dart';

class InitializeProvider with ChangeNotifier {
  Future refreshInitialize(BuildContext context) async {
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .fetchUserDetails();
      await Provider.of<WalletProvider>(context, listen: false)
          .getWalletBalance();
      await Provider.of<MoneyRequestProvider>(context, listen: false)
          .getSentMoneyReqestList();
      await Provider.of<MoneyRequestProvider>(context, listen: false)
          .getReceivedMoneyReqestList();
    } catch (error) {
      throw AppException(ApiUrl.errorString);
    }
  }
}
