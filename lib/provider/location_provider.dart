import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/http_exceptions.dart';
import 'package:kasheto_flutter/models/location.dart';
import 'package:kasheto_flutter/utils/api_url.dart';

class LocationProvider with ChangeNotifier {
  final List<CountryModel> _countriesList = [];

  List<CountryModel> get countriesList {
    return [..._countriesList];
  }

  List<States> _statesList = [];

  CountryModel getCountry(String countryName) {
    final selectedCountry = _countriesList.firstWhere((element) {
      return element.name == countryName;
    });
    return selectedCountry;
  }

  String getStateById(int id) {
    final selectedState = _statesList.firstWhere((element) {
      return element.stateId == id;
    });
    return selectedState.name;
  }

  String getCountryById(int id) {
    final selectedCountry = _countriesList.firstWhere((element) {
      return element.id == id;
    });
    return selectedCountry.name;
  }

  Future<void> getCountriesList() async {
    try {
      // Get all countries from database
      final url = Uri.parse('${ApiUrl.baseURL}getcountries');
      final stateUrl = Uri.parse('${ApiUrl.baseURL}getstates');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(url, headers: _header);
      // Get all state from database
      final stateResponse = await http.get(stateUrl, headers: _header);
      final res = json.decode(response.body);

      final stateRes = json.decode(stateResponse.body);
      if (response.statusCode == 200 && stateResponse.statusCode == 200) {
        final _countries = res['country'];
        List _resStates = stateRes;
        List<States> _states = _resStates
            .map((e) => States(
                id: int.parse(e['country_id'].toString()),
                name: e['name'],
                stateId: int.parse(e['id'].toString())))
            .toList();
        _statesList.clear();
        _countriesList.clear();
        for (var element in _countries) {
          final newCountry = CountryModel(
              id: int.parse(element['id'].toString()),
              name: element['name'],
              countryISO: element['iso2'] ?? 'btc',
              states: _states.where((ele) => ele.id == element['id']).toList());
          _countriesList.add(newCountry);
        }
        _statesList = _states;
      }
    } on SocketException {
      throw AppException('Check your internet connection');
    } catch (error) {
      throw AppException('An error occured');
    }
  }
}
