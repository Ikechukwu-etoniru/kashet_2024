import 'package:flutter/material.dart';
import 'package:kasheto_flutter/screens/payment_option_screen.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';

class SellCryptoPage extends StatefulWidget {
  const SellCryptoPage({Key? key}) : super(key: key);

  @override
  State<SellCryptoPage> createState() => _SellCryptoPageState();
}

class _SellCryptoPageState extends State<SellCryptoPage> {
  final _textFieldColor = Colors.grey[200];
  final _textFieldContentPadding = const EdgeInsets.all(10);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: constraints.maxHeight * 0.05,
              ),
              const Text(
                'BTC Value',
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
                height: 15,
              ),
              const Text(
                'Value in KTC',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
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
                      'K',
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
                height: 15,
              ),
              const Text(
                'Amount in Naira',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
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
                height: 15,
              ),
              const Text(
                'Receiver\'s Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                },
                validator: ((value) {
                  if (value == null || value.isEmpty) {
                    return 'This field cannot be empty';
                  } else {
                    return null;
                  }
                }),
                onSaved: (value) {},
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  contentPadding: _textFieldContentPadding,
                  isDense: true,
                  hintText: 'Enter full name',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    Text('The current exhange rate is'),
                    SizedBox(width: 10),
                    Text(
                      '1 KTC = 0.3 NGN',
                      style: TextStyle(color: Colors.green),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '1 USD = 47658 BTC',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
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
        );
      }),
    );
  }
}
