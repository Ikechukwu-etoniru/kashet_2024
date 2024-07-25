import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kasheto_flutter/screens/withdraw_paypal_to_naira_screen.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
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
  late WebViewControllerPlus _controler;

  bool _isLoading = false;
  var _dstReached = false;

  @override
  void initState() {
    _controler = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (req) {
            if (req.url.contains('${ApiUrl.baseURL}user/transaction')) {
              Navigator.pop(context);
              // do not navigate
              return NavigationDecision.prevent;
            } else if (req.url.contains('${ApiUrl.baseURL}user/pay/success')) {
              setState(() {
                _dstReached = true;
              });
              // do not navigate
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onProgress: (url) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  void dispose() {
    _controler.server.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.appbarTitle),
        ),
        body: _dstReached
            ? const SuccessPage()
            : _isLoading
                ? const Center(
                    child: LoadingSpinner(),
                  )
                : WebViewWidget(
                    controller: _controler,
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

  late WebViewControllerPlus _controler;

  bool _isLoading = false;

  @override
  void initState() {
    _controler = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.contains('${ApiUrl.baseURL}user/transaction')) {
              Navigator.pop(context);
              // do not navigate
              return NavigationDecision.prevent;
            } else if (request.url
                .contains('${ApiUrl.baseURL}user/pay/success')) {
              setState(() {
                _dstReached = true;
              });

              // do not navigate
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onProgress: (url) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  void dispose() {
    _controler.server.close();
    super.dispose();
  }

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
                ? const Center(
                    child: LoadingSpinner(),
                  )
                : WebViewWidget(
                    controller: _controler,
                  ),
      ),
    );
  }
}

//  https://api.kasheto.com/payment-verification?reference=cs_test_a16GBzkTozrrgLJVj31q3O3gNeFXz1xStb9hRmvbqSfr9X63zyArcuDVp2

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
  late WebViewControllerPlus _controler;
  bool _isLoading = false;
  bool _dstReached = false;

  @override
  void initState() {
    _controler = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.contains('${ApiUrl.baseURL}user/transaction')) {
              Navigator.pop(context);
              // do not navigate
              return NavigationDecision.prevent;
            } else if (request.url
                .contains('${ApiUrl.baseURL}user/pay/success')) {
              setState(() {
                _dstReached = true;
              });

              // do not navigate
              return NavigationDecision.prevent;
            } else if (request.url
                .contains('https://api.kasheto.com/payment-verification')) {
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onProgress: (url) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  void dispose() {
    _controler.server.close();
    super.dispose();
  }

  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: _dstReached ? false : true,
          title: Text(widget.appbarTitle),
        ),
        body: _isLoading
            ? const Center(
                child: LoadingSpinner(),
              )
            : WebViewWidget(
                controller: _controler,
              ),
      ),
    );
  }
}

class WebViewPagesStripe extends StatefulWidget {
  final String appbarTitle;
  final String url;
  final String amount;

  const WebViewPagesStripe(
      {required this.appbarTitle,
      required this.url,
      required this.amount,
      Key? key})
      : super(key: key);

  @override
  State<WebViewPagesStripe> createState() => _WebViewPagesStripeState();
}

class _WebViewPagesStripeState extends State<WebViewPagesStripe> {
  late WebViewControllerPlus _controler;
  bool _isLoading = false;
  bool _dstReached = false;

  @override
  void initState() {
    _controler = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            print(
                'vvvvvvxvxvxvxvxvxvxvxvxvxvxvxvvvxvxvxvvxvxvx   ${request.url}');
            if (request.url.contains('${ApiUrl.baseURL}user/transaction')) {
              Navigator.pop(context);
              // do not navigate
              return NavigationDecision.prevent;
            } else if (request.url
                .contains('${ApiUrl.baseURL}user/pay/success')) {
              setState(() {
                _dstReached = true;
              });

              // do not navigate
              return NavigationDecision.prevent;
            } else if (request.url
                .contains('https://api.kasheto.com/payment-verification?')) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return WebViewPagesStripeCont(
                    appbarTitle: widget.appbarTitle, url: request.url);
              }));
              // do not navigate
              return NavigationDecision.prevent;
            }
            // else if (request.url
            //     .contains('https://api.kasheto.com/payment-verification')) {
            //   return NavigationDecision.prevent;
            // }
            else {
              return NavigationDecision.navigate;
            }
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onProgress: (url) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  void dispose() {
    _controler.server.close();
    super.dispose();
  }

  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: _dstReached ? false : true,
          title: Text(widget.appbarTitle),
        ),
        body: _isLoading
            ? const Center(
                child: LoadingSpinner(),
              )
            : WebViewWidget(
                controller: _controler,
              ),
      ),
    );
  }
}

class WebViewPagesStripeCont extends StatefulWidget {
  final String appbarTitle;
  final String url;

  const WebViewPagesStripeCont(
      {required this.appbarTitle, required this.url, Key? key})
      : super(key: key);

  @override
  State<WebViewPagesStripeCont> createState() => _WebViewPagesStripeContState();
}

class _WebViewPagesStripeContState extends State<WebViewPagesStripeCont> {
  late WebViewControllerPlus _controler;
  bool _isLoading = false;
  bool _dstReached = false;

  @override
  void initState() {
    print(widget.url);
    _controler = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            print(
                'vvvvvvxvxvxvxvxvxvxvxvxvxvxvxvvvxvxvxvvxvxvx   ${request.url}');
            if (request.url.contains('${ApiUrl.baseURL}user/pay/success')) {
              setState(() {
                _dstReached = true;
              });

              // do not navigate
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onProgress: (url) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  void dispose() {
    _controler.server.close();
    super.dispose();
  }

  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: _dstReached ? false : true,
          title: Text(widget.appbarTitle),
        ),
        body: _isLoading
            ? const Center(
                child: LoadingSpinner(),
              )
            : WebViewWidget(
                controller: _controler,
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
  late WebViewControllerPlus _controler;

  bool _isLoading = false;
  var _dstReached = false;

  @override
  void initState() {
    _controler = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.contains('${ApiUrl.baseURL}user/transaction')) {
              Navigator.pop(context);
              // do not navigate
              return NavigationDecision.prevent;
            } else if (request.url
                .contains('${ApiUrl.baseURL}user/pay/success')) {
              setState(() {
                _dstReached = true;
              });
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return WithdrawPaypalToNaira(
                    ktcValue: widget.ktcAmount,
                  );
                }),
              );

              // do not navigate
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onProgress: (url) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  void dispose() {
    _controler.server.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.appbarTitle),
        ),
        body: _isLoading
            ? const Center(
                child: LoadingSpinner(),
              )
            : WebViewWidget(
                controller: _controler,
              ),
      ),
    );
  }
}

String removeApiPrefix(String url) {
  return url.replaceFirst('api.', '');
}


//  https://api.kasheto.com/payment-verification?reference=cs_test_a1md4mFxebLrM9vLdlmkR4zLvafGZPsNGm9xQNNlqdim3BmQzZKYRzqUbz
//  https://kasheto.com/payment-verification?reference=cs_test_a1md4mFxebLrM9vLdlmkR4zLvafGZPsNGm9xQNNlqdim3BmQzZKYRzqUbz
