import 'package:shared_preferences/shared_preferences.dart';

class ApiUrl {
  static const String baseURL = 'https://api.kasheto.com/api/';
  // static const String baseURL = 'http://km.ictnetworldltd.com/api/';
  static const String internetErrorString = 'Check your internet connection';
  static const String errorString = 'An error occured';

  static Future<Map<String, String>?> setHeaders() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    return {
      "Content-type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  static Map<String, String> setNoTokenHeaders() {
    return {"Content-type": "application/json", "Accept": "application/json"};
  }
}

