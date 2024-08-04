import 'dart:convert';

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
  var _verificationComplete = false;
  var _screenLoadingError = false;
  var _verriffError = false;
  String? errormessge;

  @override
  void initState() {
    super.initState();
    getVeriffLink();
  }

  Future getVeriffLink() async {
    try {
      setState(() {
        _isCancelledStatus = false;
        _urAccountIsVerified = false;
        _verificationComplete = false;
        _screenLoadingError = false;
        _verriffError = false;
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
        setState(() {
          _urAccountIsVerified = true;
        });
      } else if ((response.statusCode == 200 || response.statusCode == 201) &&
          res['status'] == 'success') {
        final sessionUrl = res['data']['url'];
        startVeriffVerification(sessionUrl);
      }
    } catch (error) {
      setState(() {
        _screenLoadingError = true;
      });
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

      if (result.status == Status.canceled) {
        setState(() {
          _isCancelledStatus = true;
        });
      } else if (result.status == Status.done) {
        setState(() {
          _verificationComplete = true;
        });
      } else if (result.error != null) {
        setState(() {
          _verriffError = true;
        });

        if (result.error == Error.cameraUnavailable) {
          errormessge = "User did not give permission for the camera";
        } else if (result.error == Error.microphoneUnavailable) {
          errormessge = "User did not give permission for the microphone.";
        } else if (result.error == Error.networkError) {
          errormessge = "Network error occurred.";
        }
      }
    } catch (e) {
      setState(() {
        _verriffError = true;
      });
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
                              'Congratulations! Your document has been approved. You can now access the full powers of your dashboard.',
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
                      : _verificationComplete
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Center(
                                  child: Icon(
                                    Icons.verified_rounded,
                                    color: MyColors.primaryColor,
                                    size: 100,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                const Text(
                                  'Your Account has been verified',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    // Remember Change user id status to verified
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
                            )
                          : _screenLoadingError
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error,
                                        size: 100,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        'Error occured while loading this screen',
                                      ),
                                      const SizedBox(
                                        height: 50,
                                      ),
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: MyColors.primaryColor,
                                          ),
                                          child: const Text(
                                            'Reload Screen',
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
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                              : _verriffError
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.error,
                                            size: 100,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Text(
                                            'Error occured, verification incomplete',
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          if (errormessge != null)
                                            Text(
                                              errormessge!,
                                            ),
                                          const SizedBox(
                                            height: 50,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              getVeriffLink();
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 15,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 15,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                  : Padding(
                                      padding: MyPadding.screenPadding,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [],
                                      ),
                                    )),
    );
  }
}
