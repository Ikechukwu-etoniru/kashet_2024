import 'package:flutter/material.dart';
import 'package:kasheto_flutter/screens/payment_option_screen.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';

class BettingScreen extends StatefulWidget {
  static const routeName = '/betting_screen.dart';
  const BettingScreen({Key? key}) : super(key: key);

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  final _textFieldContentPadding = const EdgeInsets.all(10);
  final _textFieldColor = Colors.grey[200];
  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Betting'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: _deviceHeight * 0.05,
              ),
              const Text(
                'Select Service Provider',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20, right: 20),
                      hintText: 'E.g Bet9ja, 1960BET, etc',
                      border: InputBorder.none),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Slip ID',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                style: const TextStyle(letterSpacing: 1),
                validator: ((value) {
                  if (value == null || value.isEmpty) {
                    return 'This field cannot be empty';
                  } else if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  } else {
                    return null;
                  }
                }),
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: _textFieldContentPadding,
                  filled: true,
                  fillColor: _textFieldColor,
                  isDense: true,
                  hintText: 'Enter slip id',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSaved: (value) {},
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Amount in Naira',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                validator: ((value) {
                  if (value == null || value.isEmpty) {
                    return 'This field cannot be empty';
                  } else if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  } else {
                    return null;
                  }
                }),
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      '₦',
                      style: TextStyle(
                          fontFamily: '', fontSize: 18, color: Colors.grey),
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  filled: true,
                  fillColor: _textFieldColor,
                  isDense: true,
                  hintText: '0.00',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSaved: (value) {},
              ),
              const SizedBox(
                height: 10,
              ),
            const  Row(
                children:  [
                  Text('The current exhange rate is'),
                  SizedBox(width: 5),
                  Text(
                    '1 KTC = 0.3 NGN',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
              const Spacer(),
              SubmitButton(
                  action: () {
                    Navigator.of(context)
                        .pushNamed(PaymentOptionScreen.routeName);
                  },
                  title: 'Continue')
            ],
          ),
        ),
      ),
    );
  }
}
