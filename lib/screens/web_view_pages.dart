import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasheto_flutter/screens/withdraw_paypal_to_naira_screen.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/notifications.dart';
import 'package:kasheto_flutter/widgets/success_page.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class WebViewPages extends StatefulWidget {
  final String appbarTitle;
  final String url;

  const WebViewPages({required this.appbarTitle, required this.url, Key? key})
      : super(key: key);

  @override
  State<WebViewPages> createState() => _WebViewPagesState();
}

class _WebViewPagesState extends State<WebViewPages> {
  var _dstReached = false;
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: _dstReached ? false : true,
          title: Text(widget.appbarTitle),
        ),
        body: _dstReached
            ? const SuccessPage()
            : _isLoading
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitPianoWave(
                        color: Theme.of(context).primaryColor,
                        duration: const Duration(milliseconds: 400),
                        itemCount: 5,
                        size: 20,
                        type: SpinKitPianoWaveType.center,
                      ),
                    ],
                  )
                : WebViewPlus(
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: widget.url,
                    navigationDelegate: (NavigationRequest request) async {
                      if (request.url
                          .contains('${ApiUrl.baseURL}user/transaction')) {
                        Navigator.pop(context);
                        // do not navigate
                        return NavigationDecision.prevent;
                      } else if (request.url
                          .contains('${ApiUrl.baseURL}user/pay/success')) {
                        setState(() {
                          _dstReached = true;
                        });
                        Notifications.notifyUser(
                            title: 'Deposit Successful',
                            body: 'Your deposit was succesfully');

                        // do not navigate
                        return NavigationDecision.prevent;
                      } else {
                        return NavigationDecision.navigate;
                      }
                    },
                  ),
      ),
    );
  }
}

class WebViewTransferPage extends StatefulWidget {
  final String appbarTitle;
  final String url;

  const WebViewTransferPage(
      {required this.appbarTitle, required this.url, Key? key})
      : super(key: key);

  @override
  State<WebViewTransferPage> createState() => _WebViewTransferPageState();
}

class _WebViewTransferPageState extends State<WebViewTransferPage> {
  var _dstReached = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: _dstReached ? false : true,
          title: Text(widget.appbarTitle),
        ),
        body: _dstReached
            ? const SuccessPage()
            : WebViewPlus(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: widget.url,
                navigationDelegate: (NavigationRequest request) async {
                  if (request.url
                      .contains('${ApiUrl.baseURL}user/transaction')) {
                    Navigator.pop(context);
                    // do not navigate
                    return NavigationDecision.prevent;
                  } else if (request.url
                      .contains('${ApiUrl.baseURL}user/pay/success')) {
                    setState(() {
                      _dstReached = true;
                    });
                    Notifications.notifyUser(
                        title: 'Transfer Deposit Successful',
                        body: 'Your Transfer deposit was succesfully');

                    // do not navigate
                    return NavigationDecision.prevent;
                  } else {
                    return NavigationDecision.navigate;
                  }
                },
              ),
      ),
    );
  }
}

class WebViewPagesPaypal extends StatefulWidget {
  final String appbarTitle;
  final String url;
  final String amount;

  const WebViewPagesPaypal(
      {required this.appbarTitle,
      required this.url,
      required this.amount,
      Key? key})
      : super(key: key);

  @override
  State<WebViewPagesPaypal> createState() => _WebViewPagesPaypalState();
}

class _WebViewPagesPaypalState extends State<WebViewPagesPaypal> {
  late WebViewPlusController controller;

  var _dstReached = 0;

  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: _dstReached == 1 ? false : true,
          title: Text(widget.appbarTitle),
        ),
        body: _dstReached == 1
            ? const SuccessPage()
            : WebViewPlus(
                key: UniqueKey(),
                javascriptMode: JavascriptMode.unrestricted,
                gestureRecognizers: gestureRecognizers,
                initialUrl: widget.url,
                navigationDelegate: (NavigationRequest request) {
                  if (request.url.contains('api/user/transaction')) {
                    Navigator.pop(context);
                    // do not navigate
                    return NavigationDecision.prevent;
                  } else if (request.url
                      .contains('${ApiUrl.baseURL}user/pay/success')) {
                    setState(() {
                      _dstReached = 1;
                    });
                    Notifications.notifyUser(
                        title: 'Deposit Successful',
                        body:
                            'Your deposit of ${widget.amount} was succesfully and has been added to your balance');
                    // do not navigate
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
              ),
      ),
    );
  }
}

class WebViewPagesPaypalToNaira extends StatefulWidget {
  final String appbarTitle;
  final String url;
  final String amount;
  final String ktcAmount;

  const WebViewPagesPaypalToNaira(
      {required this.appbarTitle,
      required this.url,
      required this.amount,
      required this.ktcAmount,
      Key? key})
      : super(key: key);

  @override
  State<WebViewPagesPaypalToNaira> createState() =>
      _WebViewPagesPaypalToNairaState();
}

class _WebViewPagesPaypalToNairaState extends State<WebViewPagesPaypalToNaira> {
  late WebViewPlusController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.appbarTitle),
        ),
        body: WebViewPlus(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: widget.url,
          navigationDelegate: (NavigationRequest request) async {
            if (request.url.contains('api/user/transaction')) {
              Navigator.pop(context);
              // do not navigate
              return NavigationDecision.prevent;
            } else if (request.url
                .contains('${ApiUrl.baseURL}user/pay/success')) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return WithdrawPaypalToNaira(
                    ktcValue: widget.ktcAmount,
                  );
                }),
              );

              // do not navigate
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
