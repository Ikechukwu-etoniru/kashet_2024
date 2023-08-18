import 'package:flutter/material.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:pattern_formatter/numeric_formatter.dart';

class AddCardScreen extends StatefulWidget {
  static const routeName = '/add_card_screen.dart';
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _textFieldContentPadding = const EdgeInsets.all(10);
  final _textFieldColor = Colors.grey[200];
  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Add Card'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: _deviceHeight * 0.03,
                ),
                const Text(
                  'Card Number',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, letterSpacing: 1.5),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  style: const TextStyle(letterSpacing: 3),
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
                  inputFormatters: [CreditCardFormatter()],
                  decoration: InputDecoration(
                    contentPadding: _textFieldContentPadding,
                    filled: true,
                    fillColor: _textFieldColor,
                    isDense: true,
                    hintText: '0000-0000-0000-0000',
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
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Expiry Date',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).unfocus();
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _textFieldColor,
                              contentPadding: _textFieldContentPadding,
                              hintText: 'MM/YY',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Flexible(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CVV',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty';
                              } else if (int.tryParse(value) == null) {
                                return 'Enter a valid number';
                              } else if (value.length > 3) {
                                return 'Invalid CVV';
                              } else {
                                return null;
                              }
                            },
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).unfocus();
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _textFieldColor,
                              contentPadding: _textFieldContentPadding,
                              hintText: '***',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Card Pin',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, letterSpacing: 1.5),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  style: const TextStyle(letterSpacing: 3),
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    } else if (int.tryParse(value) == null) {
                      return 'Enter a valid pin';
                    } else if (value.length > 4) {
                      return 'Enter a valid pin';
                    } else if (value.length < 4) {
                      return 'Enter a valid pin';
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
                    hintText: '****',
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
                const Spacer(),
                SubmitButton(
                    action: () {
                      _otpConfirmBottomSheet(context: context);
                    },
                    title: 'Continue')
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _otpConfirmBottomSheet({required BuildContext context}) {
  showModalBottomSheet(
      elevation: 30,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 10),
                  height: 3,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const Text(
                  'OTP Confirmation',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                    'We have sent an OTP Code to the phone number associated with this card.'),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const TextField(
                    obscureText: true,
                    obscuringCharacter: '.',
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Enter OTP',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _cardAddedSuccessSheet(context: context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Center(
                      child: Text(
                        'Add Card',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'This action cannot be reversed.',
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
          ),
        );
      });
}

void _cardAddedSuccessSheet({required BuildContext context}) {
  showModalBottomSheet(
      isScrollControlled: true,
      elevation: 30,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5, bottom: 10),
                height: 3,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green.withOpacity(0.2),
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Card Added',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'You have successfully added a new card to your account. You can now select this card for your transactions.',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      'Okay, Thanks!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      });
}
