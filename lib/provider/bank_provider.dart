import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/bank.dart';
import 'package:kasheto_flutter/models/http_exceptions.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:provider/provider.dart';

class BankProvider with ChangeNotifier {
  final List<Bank> _bankList = [];

  List<Bank> get bankList {
    return [..._bankList];
  }

  final List<UserBank> _userBankList = [];

  List<UserBank> get userBankList {
    return [..._userBankList];
  }

  int getBankId(String value) {
    final selectedBank = _bankList.firstWhere((element) {
      return element.name == value;
    });

    return selectedBank.id;
  }

// Getting user first bank account when the app loads
  Future getUserBanksInformation() async {
    _userBankList.clear();
    try {
      final url =
          Uri.parse('${ApiUrl.baseURL}user/profile/get-bank-information');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(url, headers: _header);
      final res = json.decode(response.body);
      if (response.statusCode == 200 && res['success'] == true) {
        List _bankElement = res['Bank information'];
        // If user hasnt added a bank yet all values should be null so i can use it to show not set in profile screen
        if (_bankElement.isEmpty) {
        } else {
          for (var element in _bankElement) {
            final _newBank = UserBank(
                id: element['id'],
                acctName: element['account_name'],
                acctNumber: element['account_number'],
                bankCode: element['bank_details'] != null
                    ? element['bank_details']['code']
                    : '',
                bankName: element['bank_details'] != null
                    ? element['bank_details']['name']
                    : '');
            _userBankList.add(_newBank);
          }
        }
        notifyListeners();
      }
    } catch (error) {
      throw AppException(ApiUrl.errorString);
    }
  }

  Future<void> getBankList(BuildContext context) async {
    final userCountryInitial = Provider.of<AuthProvider>(context, listen: false)
        .userList[0]
        .countryInitial;

    try {
      final url = Uri.parse('${ApiUrl.baseURL}country/$userCountryInitial');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(url, headers: _header);
      final res = json.decode(response.body);
      if (response.statusCode == 200 && res['success'] == true) {
        _bankList.clear();
        var _countryList = res['country'] as List;
        for (var element in _countryList) {
          var _newBank = Bank(
              code: element['code'],
              country: element['country'],
              id: element['id'],
              name: element['name']);
          _bankList.add(_newBank);
        }
      }
    } on SocketException {
      throw AppException(ApiUrl.internetErrorString);
    } catch (error) {
      throw AppException(ApiUrl.errorString);
    }
  }

  Future<List<Bank>> getBankListByIso(String iso) async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}country/$iso');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(url, headers: _header);
      final res = json.decode(response.body);

      if (response.statusCode == 200 && res['success'] == true) {
        List<Bank> isoBankList = [];
        var _countryList = res['country'] as List;
        for (var element in _countryList) {
          var _newBank = Bank(
              code: element['code'],
              country: element['country'],
              id: element['id'],
              name: element['name']);
          isoBankList.add(_newBank);
        }
        return isoBankList;
      } else {
        throw AppException(ApiUrl.errorString);
      }
    } on SocketException {
      throw AppException(ApiUrl.internetErrorString);
    } catch (error) {
      throw AppException(ApiUrl.errorString);
    }
  }

  Future deleteBank(
      {required int bankId,
      required BuildContext context,
      required String route}) async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/profile/delete-bank');
      final _header = await ApiUrl.setHeaders();

      final _body = json.encode({"user_bank_id": bankId});
      final response = await http.post(url, body: _body, headers: _header);
      final res = json.decode(response.body);
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: res['Message'], context: context));
        _userBankList.clear();
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
            message: 'An error occurred when deleting bank details, Try again',
            context: context));
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message: ApiUrl.internetErrorString, context: context));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: ApiUrl.errorString, context: context));
    }
  }
}
