import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/http_exceptions.dart';
import 'package:kasheto_flutter/utils/api_url.dart';

class WalletProvider with ChangeNotifier {
  double walletBalance = 0;

  void reduceKtcWalletBalance(double amount) {
    walletBalance -= amount;
    notifyListeners();
  }

  void increaseKtcWalletBalance(double amount) {
    walletBalance += amount;
    notifyListeners();
  }

  Future<void> getWalletBalance() async {
    final _header = await ApiUrl.setHeaders();
    try {
      final httpResponse = await http.get(
          Uri.parse('${ApiUrl.baseURL}user/profile/balance'),
          headers: _header);
      final response = json.decode(httpResponse.body);

      if (httpResponse.statusCode == 200) {
        double walBal = double.parse(response['balance'].toString());
        walletBalance = double.parse(walBal.toStringAsFixed(2));
      } else {
        throw AppException('An error occured');
      }
    } on SocketException {
      throw AppException('Check your internet connection');
    } catch (error) {
      throw AppException('An error occured');
    }
    notifyListeners();
  }
}
