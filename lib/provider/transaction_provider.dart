import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/http_exceptions.dart';
import 'package:kasheto_flutter/models/transaction.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:provider/provider.dart';

class TransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactionList = [];

  List<Transaction> get transactionList {
    // Using .reversed to show last transaction at the top of the list
    return [..._transactionList.reversed];
  }

  List<Transaction> get first10Transactions {
    if (_transactionList.length < 10) {
      return _transactionList.reversed.toList();
    } else {
      return _transactionList.reversed.toList().sublist(0, 10);
    }
  }

  void addTransactionToList(Transaction tx) {
    _transactionList.add(tx);
    notifyListeners();
  }

  List<Transaction> transactionsByRange(DateTime startDate, DateTime endDate) {
    return _transactionList.where((element) {
      var inDateTime = DateTime(
        int.parse(element.createDate.substring(0, 4)),
        int.parse(element.createDate.substring(5, 7)),
        int.parse(element.createDate.substring(8, 10)),
        int.parse(element.createDate.substring(11, 13)),
        int.parse(element.createDate.substring(14, 16)),
      );
      return inDateTime.isAfter(startDate) && inDateTime.isBefore(endDate);
    }).toList();
  }

  Future<void> getAllTransactions() async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/transaction/');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(url, headers: _header);
      if (response.statusCode == 200) {
        final res = json.decode(response.body);

        final txList = res as List;
        _transactionList.clear();
        for (var element in txList) {
          final _newTx = Transaction(
              id: int.parse(element['id'].toString()),
              userId: int.parse(element['user_id'].toString()),
              type: element['type'] == 'credit'
                  ? TransactionType.credit
                  : TransactionType.debit,
              amount: element['amount'],
              ktcValue: element['ktc_value'],
              paymentType: element['payment_type'],
              description: element['description'],
              status: element['status'],
              currency: element['currency'],
              charges: element['charges'],
              createDate: element['created_at'],
              updatedDate: element['updated_at'],
              personInvoled: element['person_involved']);
          _transactionList.add(_newTx);
        }
      } else {
        throw AppException('An error occured');
      }
    } on SocketException {
      throw AppException(ApiUrl.internetErrorString);
    } catch (error) {
      throw AppException('An error occurred');
    }
  }

  Future<dynamic> addMoney(
      {required String currency,
      required String paymentMethod,
      required String amount,
      required String charges}) async {
    try {
      var _body = {
        "currency": currency,
        "payment_method": paymentMethod,
        "amount": amount,
        "charges": charges
      };
      final _header = await ApiUrl.setHeaders();

      const url = '${ApiUrl.baseURL}user/pay';

      var response = await http.post(Uri.parse(url),
          body: json.encode(_body), headers: _header);
      final res = json.decode(response.body);
      print('start');
      print(res);

      if (response.statusCode == 200) {
        final String ee = res['details']['original']['Response Body'];

        return ee
            .substring(60)
            .replaceAll(RegExp(r'"'), '')
            .replaceAll(RegExp(r'}'), '');

        // Send transaction
      } else if (response.statusCode == 401) {
        throw AppException('An error occured');
      } else {
        throw AppException('An error occured');
      }
    } on SocketException {
      throw AppException('Check your internet connection');
    } catch (error) {
      throw AppException('An error occured');
    }
  }

  Future<dynamic> sendMoney(
      {required String email,
      required String name,
      required String amount,
      required String ktcValue,
      required String currency,
      required String user}) async {
    try {
      var _body = {
        "email": email,
        "name": name,
        "amount": amount,
        // "ktc_value": ktcValue,
        "currency": currency,
        "user": user
      };

      final _header = await ApiUrl.setHeaders();
      const url = '${ApiUrl.baseURL}user/transaction/send';

      var _httpResponse = await http.post(Uri.parse(url),
          body: json.encode(_body), headers: _header);
      final _response = json.decode(_httpResponse.body);
      if (_httpResponse.statusCode == 200) {
        return _response;
      } else {
        throw AppException('An error occured');
      }
    } on SocketException {
      throw AppException('Check your internet connection');
    } catch (error) {
      throw AppException('An error occured');
    }
  }

  Future<dynamic> sendMoneyToAnotherUser(
      {required String currency,
      required String amount,
      required String id,
      required String charges}) async {
    try {
      var _body = {
        "currency": currency,
        "payment_method": "flutterwave",
        "amount": amount,
        "charges": charges,
        "id": id
      };
      final _header = await ApiUrl.setHeaders();

      const url = '${ApiUrl.baseURL}user/pay/bank';

      var _httpResponse = await http.post(Uri.parse(url),
          body: json.encode(_body), headers: _header);
      final response = json.decode(_httpResponse.body);

      if (_httpResponse.statusCode == 200) {
        final String ee = response['details']['original']['Response Body'];
        return ee.substring(60, 130);

        // Send transaction
      } else if (_httpResponse.statusCode == 401) {
        throw AppException('An error occured');
      } else {
        throw AppException('An error occured');
      }
    } on SocketException {
      throw AppException('Check your internet connection');
    } catch (error) {
      throw AppException('An error occured');
    }
  }

  Future<String> requestMoneyFromUser(
      {required BuildContext context,
      required String userId,
      required String amount,
      required String ktcValue,
      required String description}) async {
    final currency = Provider.of<AuthProvider>(context, listen: false)
        .userList[0]
        .userCurrency;
    try {
      final _url =
          Uri.parse('${ApiUrl.baseURL}user/transaction/request/process');
      final _header = await ApiUrl.setHeaders();
      final httpResponse = await http.post(_url,
          headers: _header,
          body: json.encode({
            "user_id": userId,
            "amount": amount,
            "currency": currency,
            "ktc_value": ktcValue,
            "description": description
          }));
      final response = json.decode(httpResponse.body);
      if (httpResponse.statusCode == 200 && response['status'] == 'success') {
        return response['message'];
      } else {
        throw AppException('An error occured');
      }
    } on SocketException {
      throw AppException('Check your internet connection');
    } catch (error) {
      throw AppException('An error occured');
    }
  }
}
