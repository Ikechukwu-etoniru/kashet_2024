import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/http_exceptions.dart';
import 'package:kasheto_flutter/models/id_model.dart';
import 'package:kasheto_flutter/models/user.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

enum IDStatus { pending, declined, approved, notSubmitted }

class AuthProvider with ChangeNotifier {
  final List<User> _userList = [];

  int? faStatus;

  List<User> get userList {
    return [..._userList];
  }

  IdModel? userId;
  IDStatus? userVerified;

  String get userCurrency {
    if (_userList[0].userCurrency == 'NGN') {
      return 'Naira';
    } else if (_userList[0].userCurrency == 'USD') {
      return 'Dollars';
    } else if (_userList[0].userCurrency == 'CAD') {
      return 'Canadian Dollars';
    } else {
      return 'Naira';
    }
  }

  Future<String> getDeviceInfo() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.model} - ${androidInfo.id}';
    } else if (Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return '${iosInfo.model} - ${iosInfo.identifierForVendor}';
    } else {
      throw AppException('An error ocured getting device info');
    }
  }

  Future<bool> signUserUp(
      User user, String countryCode, BuildContext context) async {
    try {
      const _signUpEndpoint = '${ApiUrl.baseURL}v1/register';
      final _uri = Uri.parse(_signUpEndpoint);
      final _deviceInfo = await getDeviceInfo();

      _setHeaders() =>
          {"Content-type": "application/json", "Accept": "application/json"};

      final _body = json.encode({
        "name": user.fullName,
        "email": user.emailAddress,
        "phone": '$countryCode${user.phoneNumber.toString()}',
        "password": user.password,
        "password_confirmation": user.password,
        "ip_address": _deviceInfo
      });
      final httpResponse =
          await http.post(_uri, body: _body, headers: _setHeaders());
      final response = json.decode(httpResponse.body);
      //  If response is successfull, i add token and save user details
      if (httpResponse.statusCode == 200) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        if (localStorage.containsKey('token')) {
          localStorage.remove('token');
        }
        localStorage.setString('token', response['token']);
        return true;
      } else if (httpResponse.statusCode == 422) {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: response['errors'][0], context: context),
        );
        return false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(
              message: 'An error occured, try again later', context: context),
        );
        return false;
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert.snackBar(message: ApiUrl.internetErrorString, context: context),
      );
      return false;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert.snackBar(message: ApiUrl.errorString, context: context),
      );
      return false;
    }
  }

  void changeFaStatus(int value) {
    faStatus = value;
    notifyListeners();
  }

  Future getFaStatus() async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}v1/personal');
      final _header = await ApiUrl.setHeaders();
      final httpResponse = await http.get(url, headers: _header);
      final res = json.decode(httpResponse.body);
      if (httpResponse.statusCode == 200 && res['success'] == 'true') {
        faStatus = null;
        faStatus = res['user Details']['two_fa_status'];
      } else {
        throw AppException('An error occurred');
      }
    } on SocketException {
      throw AppException(ApiUrl.internetErrorString);
    } catch (error) {
      throw AppException('An error occurred');
    }
  }

  Future<void> fetchUserDetails() async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}v1/personal');
      final _header = await ApiUrl.setHeaders();
      final httpResponse = await http.get(url, headers: _header);
      final res = json.decode(httpResponse.body);
      if (httpResponse.statusCode == 200 && res['success'] == 'true') {
        // Delete user from list and add another user

        _userList.clear();
        final newUser = User(
          fullName: res['user Details']['name'],
          emailAddress: res['user Details']['email'],
          phoneNumber: res['user Details']['details']['phone'],
          id: res['user Details']['id'].toString(),
          imageUrl: res['user Details']['photo'],
          isBvnVerified: res['user Details']['bvn_verified_at'],
          isEmailVerified: res['user Details']['email_verified_at'],
          isNumberVerified: res['user Details']['phone_verified_at'],
          dob: res['user Details']['details']['dob'],
          gender: res['user Details']['details']['gender'],
          address: res['user Details']['details']['address'],
          country: res['user Details']['details']['country_id'].toString(),
          state: res['user Details']['details']['state_id'].toString(),
          countryInitial: res['user Details']['details']['country'] == null
              ? null
              : res['user Details']['details']['country']['iso2'],
          city: res['user Details']['details']['city'],
          userCurrency: res['user Details']['details']['country'] == null
              ? null
              : res['user Details']['details']['country']['currency'],
        );

        _userList.add(newUser);
        faStatus = null;
        faStatus = int.parse(res['user Details']['two_fa_status'].toString());
      } else {
        throw AppException('An error occurred');
      }
    } on SocketException {
      throw AppException(ApiUrl.internetErrorString);
    } catch (error) {
      throw AppException('An error occurred');
    }
  }

  Future<bool> sendAuthOtp({required bool isResend}) async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/send-two-fa-code');
      final _header = await ApiUrl.setHeaders();
      final _body = json.encode({'resend': isResend});
      final response = await http.post(url, headers: _header, body: _body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  Future checkVerificationStatus() async {
    try {
      final url = Uri.parse('${ApiUrl.baseURL}user/profile/verification');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(
        url,
        headers: _header,
      );
      final res = json.decode(response.body);
      if (res['data'] == null) {
        userVerified = IDStatus.notSubmitted;
        return;
      }
      if (response.statusCode == 200 &&
          res['data'] != null &&
          (res['data']['status'] == '1' || res['data']['status'] == '0')) {
        userId = IdModel(
          id: res['data']['id'],
          userId: res['data']['user_id'],
          type: res['data']['type'],
          frontImage: res['data']['doc_front'],
          backImage: res['data']['doc_back'],
          documentNumber: res['data']['doc_number'],
          status: res['data']['status'],
        );
        if (res['data']['status'] == '1') {
          userVerified = IDStatus.pending;
        } else if (res['data']['status'] == '0') {
          userVerified = IDStatus.approved;
        }
      } else if (response.statusCode == 200 &&
          res['data'] != null &&
          res['data']['status'] == '2') {
        userId = IdModel(
          id: res['data']['id'],
          userId: res['data']['user_id'],
          type: res['data']['type'],
          frontImage: res['data']['doc_front'],
          backImage: res['data']['doc_back'],
          documentNumber: res['data']['doc_number'],
          status: res['data']['status'],
          remark: res['data']['remark'],
        );
        userVerified = IDStatus.declined;
      }
    } catch (error) {
      print(error);
    } finally {
      notifyListeners();
    }
  }
}
