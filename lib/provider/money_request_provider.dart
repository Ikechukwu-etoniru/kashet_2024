import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/http_exceptions.dart';
import 'package:kasheto_flutter/models/money_request.dart';
import 'package:kasheto_flutter/utils/api_url.dart';

class MoneyRequestProvider with ChangeNotifier {
 final List<MoneyRequest> _sentMoneyRequestList = [];

 final List<MoneyRequest> _receivedMoneyRequestList = [];

  List<MoneyRequest> get sentMoneyRequestList {
    return [..._sentMoneyRequestList];
  }

  List<MoneyRequest> get receivedMoneyRequestList {
    return [..._receivedMoneyRequestList];
  }

// This is the list of pending money requuest and will use it to send notification during initialization
  List<MoneyRequest> get pendingReceivedMoneyRequest {
    return _receivedMoneyRequestList.where((element) {
      return element.status == 'pending';
    }).toList();
  }

  Future getReceivedMoneyReqestList() async {
    try {
      final url = Uri.parse(
          '${ApiUrl.baseURL}user/transaction/requests/fetch/recieved');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(
        url,
        headers: _header,
      );
      final res = json.decode(response.body);

      if (res['success'] == true) {
        _receivedMoneyRequestList.clear();
        List resList = res['payrequest']['data'];
        for (var element in resList) {
          var mR = MoneyRequest(
              type: 'received',
              id: element['id'].toString(),
              status: element['status'],
              name: element['sender']['name'],
              amount: element['amount'],
              ktcValue: element['ktc_value'],
              currency: element['currency'],
              description: element['description'],
              createdAt: element['created_at'],
              updatedAt: element['updated_at']);
          _receivedMoneyRequestList.add(mR);
        }
      } else {
        throw AppException(ApiUrl.errorString);
      }
    } on SocketException {
      throw AppException(ApiUrl.internetErrorString);
    } catch (error) {
      throw AppException(ApiUrl.errorString);
    }
  }

  Future getSentMoneyReqestList() async {
    try {
      final url =
          Uri.parse('${ApiUrl.baseURL}user/transaction/requests/fetch/sent');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(
        url,
        headers: _header,
      );
      final res = json.decode(response.body);

      if (res['success'] == true) {
        _sentMoneyRequestList.clear();
        List resList = res['payrequest']['data'];
        for (var element in resList) {
          var mR = MoneyRequest(
              type: 'sent',
              id: element['id'].toString(),
              status: element['status'],
              name: element['reciever']['name'],
              amount: element['amount'],
              ktcValue: element['ktc_value'],
              currency: element['currency'],
              description: element['description'],
              createdAt: element['created_at'],
              updatedAt: element['updated_at']);
          _sentMoneyRequestList.add(mR);
        }
      } else {
        throw AppException(ApiUrl.errorString);
      }
    } on SocketException {
      throw AppException(ApiUrl.internetErrorString);
    } catch (error) {
      throw AppException(ApiUrl.errorString);
    }
  }
}
