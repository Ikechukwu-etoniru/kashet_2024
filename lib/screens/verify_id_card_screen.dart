import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:kasheto_flutter/screens/main_screen.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veriff_flutter/veriff_flutter.dart';

class VerifyIdCardScreen extends StatefulWidget {
  static const routeName = '/verify_id_card_screen.dart';
  const VerifyIdCardScreen({Key? key}) : super(key: key);

  @override
  State<VerifyIdCardScreen> createState() => _VerifyIdCardScreenState();
}

class _VerifyIdCardScreenState extends State<VerifyIdCardScreen> {
  var _isLoading = false;

  var _isCancelledStatus = false;
  var _urAccountIsVerified = false;

  @override
  void initState() {
    super.initState();
    getVeriffLink();
  }

  Future getVeriffLink() async {
    try {
      setState(() {
        _isCancelledStatus = true;
        _isLoading = true;
      });
      final url =
          Uri.parse('${ApiUrl.baseURL}user/profile/verification/verify');
      final _header = await ApiUrl.setHeaders();
      final response = await http.get(
        url,
        headers: _header,
      );
      final res = json.decode(response.body);
      print(res);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          res['status'] == false) {
        print('yes');
        setState(() {
          _urAccountIsVerified = true;
        });
      } else if ((response.statusCode == 200 || response.statusCode == 201) &&
          res['status'] == 'success') {
        final sessionUrl = res['data']['url'];
        startVeriffVerification(sessionUrl);
      }
    } catch (error) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future startVeriffVerification(String sessionUrl) async {
    Configuration config = Configuration(sessionUrl);
    Veriff veriff = Veriff();

    try {
      Result result = await veriff.start(config);
      print(
          '${result.status}   fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
      print(
          '${result.error}   fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
      if (result.status == Status.canceled) {
        setState(() {
          _isCancelledStatus = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _goBackToMenu() async {
    return await (showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                title: const Text(
                  'Confirm Exit',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                content: const Text(
                    'Are you sure you want to go back without submiting an ID'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(MainScreen.routeName);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      SharedPreferences localStorage =
                          await SharedPreferences.getInstance();
                      if (localStorage.containsKey('token')) {
                        localStorage.remove('token');
                      }
                      Navigator.of(context).pop(true);

                      Navigator.of(context).pushNamedAndRemoveUntil(
                          MainScreen.routeName, (route) => false);
                    },
                    child: const Text('Yes'),
                  )
                ],
              );
            })) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _goBackToMenu,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Verify Your identity'),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    MainScreen.routeName, (route) => false);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
              ),
            ),
          ),
          body: _isLoading
              ? const Center(
                  child: LoadingSpinner(),
                )
              : _isCancelledStatus
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              getVeriffLink();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: MyColors.primaryColor,
                              ),
                              child: const Text(
                                'Restart Verification',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.red,
                              ),
                              child: const Text(
                                'Go Back',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    )
                  : _urAccountIsVerified
                      ? const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Icon(
                                Icons.verified_rounded,
                                color: MyColors.primaryColor,
                                size: 100,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Your Account is already verified',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                          ],
                        )
                      : Padding(
                          padding: MyPadding.screenPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [],
                          ),
                        )),
    );
  }
}

// 
// String? webLink;
// String? webToken;
// late WebViewControllerPlus _controller;

// String hmacUserIdCode() {
//   String base64Key = 'base64:o2cj8ZFMg8WGttwgNUJmBfEjUWgYmaI3DEUVIJ1QQTY=';
//   String message =
//       Provider.of<AuthProvider>(context, listen: false).userList.first.uid;

//   List<int> messageBytes = utf8.encode(message);
//   List<int> key = utf8.encode(base64Key);
//   Hmac hmac = Hmac(sha256, key);
//   Digest digest = hmac.convert(messageBytes);
//   return digest.toString();
// }

// Future getVerificationLink() async {
//   setState(() {
//     _isLoading = true;
//   });
//   Dio dio = Dio();
//   FormData formData = FormData.fromMap({
//     'user_id':
//         Provider.of<AuthProvider>(context, listen: false).userList.first.uid
//   });

//   try {
//     Response response = await dio.post(
//       'https://kasheto.com/api/entrance-scene',
//       data: formData,
//       options: Options(
//         headers: {
//           "Accept": "application/json",
//           "X-KASH-SIGNATURE": hmacUserIdCode()
//         },
//       ),
//     );
//     final res = response.data;
//     if (response.statusCode == 200 && res['status'] == 'success') {
//       webLink = res['data']['url'];
//       webToken = res['data']['token'];
//       Map<String, String> headers = {"Authorization": "Bearer $webToken"};

//       _controller = WebViewControllerPlus()
//         ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         ..setBackgroundColor(const Color(0x00000000))
//         ..setNavigationDelegate(
//           NavigationDelegate(
//             onNavigationRequest: (request) {
//               if (request.url.contains('${ApiUrl.baseURL}user/transaction')) {
//                 Navigator.pop(context);
//                 // do not navigate
//                 return NavigationDecision.prevent;
//               } else if (request.url
//                   .contains('${ApiUrl.baseURL}user/pay/success')) {
//                 setState(() {
//                   // _dstReached = true;
//                 });
//                 // do not navigate
//                 return NavigationDecision.prevent;
//               } else {
//                 return NavigationDecision.navigate;
//               }
//             },
//             onPageFinished: (url) {
//               setState(() {
//                 _isLoading = false;
//               });
//             },
//             onPageStarted: (url) {
//               setState(() {
//                 _isLoading = true;
//               });
//             },
//             onProgress: (url) {},
//           ),
//         )
//         ..loadRequest(Uri.parse(webLink!),
//             headers: {"Authorization": "Bearer $webToken"});
//     }
//   } catch (error) {
//     print(error);
//   } finally {
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }
