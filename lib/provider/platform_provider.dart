import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/currency.dart';
import 'package:kasheto_flutter/models/http_exceptions.dart';
import 'package:kasheto_flutter/utils/api_url.dart';

class PlatformChargesProvider with ChangeNotifier {
  late double nairaToKtc;
  late double dollarsToKtc;

  late double usdCharge;
  late double ngnCharge;
  late double withdrawalCharge;

  final List<CurrencyK> _currencyList = [];

  List<CurrencyK> get currencyList {
    return [..._currencyList];
  }

  Future getExchangeRate() async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}v1/exchange-rate');
      final header = {
        "Content-type": "application/json",
        "Accept": "application/json"
      };

      final response = await http.get(
        url,
        headers: header,
      );
      List res = json.decode(response.body);
      if (response.statusCode == 200) {
        for (var element in res) {
          if (element['country']['currency'] == 'USD') {
            dollarsToKtc = double.parse(element['rate'].toString());
          } else if (element['country']['currency'] == 'NGN') {
            nairaToKtc = double.parse(element['rate'].toString());
          }
        }
      }
    } catch (error) {
      throw AppException('An error occured');
    }
  }

  Future getCurrencies() async {
    try {
      final url = Uri.parse('https://kasheto.com/send');
      final header = {"Accept": "application/json"};

      final response = await http.get(
        url,
        headers: header,
      );
      final res = json.decode(response.body);
      Map<String, dynamic> currencyFromDb = res["fxcurrencies"]["rates"];
      if (response.statusCode == 200) {
        _currencyList.clear();
        currencyFromDb.values.toList().forEach((val) {
          final cur = CurrencyK(
              name: val['name'],
              rate: double.parse(val['rate'].toString()),
              code: val['code']);
          _currencyList.add(cur);
        });
      }
    } catch (error) {
      throw AppException('An error occured');
    }
  }

  Future getPlatformCharges() async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}v1/charges');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(
        url,
        headers: _header,
      );
      final res = json.decode(response.body);
      if (response.statusCode == 200) {
// {usd_charge: 10, ngn_charge: 5, withdrawal_charge: 2}
      }
    } catch (error) {
      throw AppException(
        error.toString(),
      );
    }
  }

  String withdrawalCharges(String? amount) {
    if (amount == null || amount == '0' || double.parse(amount) <= 0) {
      return '0.00';
    } else {
      final charges = double.parse(amount) * 0.05;
      return charges.toStringAsFixed(2);
    }
  }

  String depositCharges(String? amount) {
    if (amount == null || amount == '0' || double.parse(amount) <= 0) {
      return '0.00';
    } else {
      final charges = double.parse(amount) * 0.05;
      return charges.toStringAsFixed(2);
    }
  }

  String depositDollarsCharges(String? amount) {
    if (amount == null || amount == '0' || double.parse(amount) <= 0) {
      return '0.00';
    } else {
      final charges = double.parse(amount) * 0.1;
      return charges.toStringAsFixed(2);
    }
  }
}
