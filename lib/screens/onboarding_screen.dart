import 'package:flutter/material.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '/screens/login_screen.dart';
import '/screens/signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  var _isLastPage = false;

  // To show onboarding screen only for new user. Will use saved data to check
  void _saveNotFirstTimeUser() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setBool('old user', true);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: MyPadding.screenPadding,
          child: Column(
            children: [
              SizedBox(
                height: _deviceHeight * 0.2,
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  children: const [
                    OnboardPage(
                      image: 'images/onboarding_pic_1.png',
                      title: 'Send Money with Ease',
                      content:
                          'Kasheto offers a simple approach to sending \n money across diffrent banks. All you need \n is a few clicks',
                    ),
                    OnboardPage(
                      image: 'images/onboarding_pic_2.png',
                      title: 'Pay Bills within Seconds',
                      content:
                          'Handle all your bill payment needs from your \n phone. We cover Electricity Bill, Airtime &\n Data Purchase, Cable TV and  more.',
                    ),
                    OnboardPage(
                      image: 'images/onboarding_pic_3.png',
                      title: 'Track Transactions',
                      content:
                          'You can know what you spend your money on.\n Keep track of your expenses with our \n transaction management options. ',
                    ),
                  ],
                ),
              ),
              SmoothPageIndicator(
                onDotClicked: (index) {
                  if (index == 2) {
                    setState(() {
                      _isLastPage = true;
                    });
                  } else {
                    setState(() {
                      _isLastPage = false;
                    });
                  }
                  _controller.animateToPage(index,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeIn);
                },
                controller: _controller,
                count: 3,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.green,
                  dotColor: Colors.green.withOpacity(0.4),
                  dotHeight: 5,
                  dotWidth: 10,
                  spacing: 3,
                  expansionFactor: 2,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              if (!_isLastPage)
                GestureDetector(
                  onTap: () {
                    if (_controller.page! > 0 && _controller.page! <= 1) {
                      setState(() {
                        _isLastPage = true;
                      });
                    }
                    _controller.animateToPage(
                      int.parse(_controller.page!.toStringAsFixed(0)) + 1,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              if (!_isLastPage)
                const SizedBox(
                  height: 20,
                ),
              if (_isLastPage)
                SubmitButton(
                    action: () {
                      Navigator.of(context).pushNamed(SignupScreen.routeName);
                      // Prevents user from seein this screen after the first time.
                      _saveNotFirstTimeUser();
                    },
                    title: 'Sign up with Email'),
              if (_isLastPage)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(LoginScreen.routeName);
                        _saveNotFirstTimeUser();
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.only(left: 3),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.green,
                          decorationThickness: 2,
                        ),
                      ),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final String image;
  final String title;
  final String content;
  const OnboardPage(
      {required this.image,
      required this.content,
      required this.title,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Image.asset(
            image,
            fit: BoxFit.fill,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          content,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
