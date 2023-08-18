import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/billings.dart';
import 'package:kasheto_flutter/models/http_exceptions.dart';
import 'package:kasheto_flutter/utils/api_url.dart';

class BillingProvider with ChangeNotifier {
  final List<DstvPlan> _dstvPlans = [];
  final List<GotvPlan> _gotvPlans = [];
  final List<StimePlan> _stimePlans = [];
  final List<ElectricPlan> _electricPlans = [];

  final List<String> _operatorList = [];
  final List<BillingPlan> _dataBillingList = [];
  final List<BillingPlan> _airtimeBillingList = [];

  List<BillingPlan> get dataBillingList {
    return [..._dataBillingList];
  }

  List<BillingPlan> get airtimeBillingList {
    return [..._airtimeBillingList];
  }

  List<String> get operatorList {
    return [..._operatorList];
  }

  List<DstvPlan> get dstvPlans {
    return [..._dstvPlans];
  }

  List<GotvPlan> get gotvPlans {
    return [..._gotvPlans];
  }

  List<StimePlan> get stimePlans {
    return [..._stimePlans];
  }

  List<ElectricPlan> get electricPlans {
    return [..._electricPlans];
  }

  Future<void> getDstvPlans() async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/bills/dstv');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(url, headers: _header);
      final res = json.decode(response.body);
      if (response.statusCode == 200 && res['success'] == true) {
        List _dstvPaidPlans = res['plans'];
        _dstvPlans.clear();
        for (var element in _dstvPaidPlans) {
          final newDstvPlan = DstvPlan(
              id: element['id'],
              amount: element['amount'],
              name: element['name']);
          _dstvPlans.add(newDstvPlan);
        }
      } else {
        throw AppException('An error occured');
      }
    } on SocketException {
      throw AppException('Check your internet connection');
    } catch (error) {
      throw AppException('An error occured');
    }
  }

  Future<void> getGotvPlans() async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/bills/gotv');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(url, headers: _header);
      final res = json.decode(response.body);
      if (response.statusCode == 200 && res['success'] == true) {
        List _gotvPaidPlans = res['plans'];
        _gotvPlans.clear();
        for (var element in _gotvPaidPlans) {
          final newGotvPlan = GotvPlan(
              id: element['id'],
              amount: element['amount'],
              name: element['name']);
          _gotvPlans.add(newGotvPlan);
        }
      } else {
        throw AppException('An error occured');
      }
    } on SocketException {
      throw AppException('Check your internet connection');
    } catch (error) {
      throw AppException('An error occured');
    }
  }

  Future<void> getStimePlans() async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/bills/startime');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(url, headers: _header);
      final res = json.decode(response.body);
      if (response.statusCode == 200 && res['success'] == true) {
        List _stimePaidPlans = res['plans'];
        _stimePlans.clear();
        for (var element in _stimePaidPlans) {
          final newStimePlan = StimePlan(
              id: element['id'],
              amount: element['amount'],
              name: element['name']);
          _stimePlans.add(newStimePlan);
        }
      } else {
        throw AppException('An error occured');
      }
    } on SocketException {
      throw AppException('Check your internet connection');
    } catch (error) {
      throw AppException('An error occured');
    }
  }

  Future<void> getElectricPlans() async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/bills/disco');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(url, headers: _header);
      final res = json.decode(response.body);
      if (response.statusCode == 200 && res['success'] == true) {
        List _electricPaidPlans = res['plans'];
        _electricPlans.clear();
        for (var element in _electricPaidPlans) {
          final newElectricPlan =
              ElectricPlan(id: element['id'], name: element['name']);
          _electricPlans.add(newElectricPlan);
        }
      } else {
        throw AppException('An error occured');
      }
    } on SocketException {
      throw AppException('Check your internet connection');
    } catch (error) {
      throw AppException('An error occured');
    }
  }

  BillingPlan getAirtimeBillingPlanByName(String billingName) {
    return _airtimeBillingList.firstWhere((element) {
      return element.genName == billingName;
    });
  }

  Future<void> getOperators() async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/bills/show_airtime');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(url, headers: _header);
      final res = json.decode(response.body);
      if (response.statusCode == 200 && res['success'] == true) {
        List _resList = res['operators'];
        _operatorList.clear();
        _airtimeBillingList.clear();
        _dataBillingList.clear();
        for (var element in _resList) {
          final _operator = element['general_name'];
          _operatorList.add(_operator);
          await getProducts(_operator);
        }
      } else {
        throw AppException('An error occured');
      }
    } on SocketException {
      throw AppException('Check your internet connection');
    } catch (error) {
      throw AppException('An error occured');
    }
  }

  Future<void> getProducts(String operator) async {
    try {
      final url = Uri.parse(
          '${ApiUrl.baseURL}user/bills/fetch-operator-products/$operator/fetch');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(url, headers: _header);
      final res = json.decode(response.body);
      if (response.statusCode == 200) {
        List resList = res;

        for (var element in resList) {
          final newBilling = BillingPlan(
              id: element['id'],
              name: element['name'],
              amount: element['amount'],
              genName: element['general_name'],
              billType: element['bill_type']);
          if (newBilling.name == 'AIRTIME') {
            final listWithSimilarGenName = _airtimeBillingList
                .where((element) => element.genName == newBilling.genName)
                .toList();

            if (listWithSimilarGenName.isEmpty) {
              _airtimeBillingList.add(newBilling);
            }
          } else {
            _dataBillingList.add(newBilling);
          }
        }
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
