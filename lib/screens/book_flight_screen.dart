import 'package:flutter/material.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/my_dropdown.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';

class BookFlightScreen extends StatefulWidget {
  static const routeName = '/book_flight_screen.dart';
  const BookFlightScreen({Key? key}) : super(key: key);

  @override
  State<BookFlightScreen> createState() => _BookFlightScreenState();
}

class _BookFlightScreenState extends State<BookFlightScreen> {
  String? flightType;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Flight'),
        ),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: MyPadding.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Flight Class',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyDropDown(
                      items: ['ff', 'fff'].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                      },
                      hint: const Text('Select a flight class'),
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Adults',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyDropDown(
                      items: ['ff', 'fff'].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                      },
                      hint: const Text('Select number of adults'),
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Infants',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyDropDown(
                      items: ['ff', 'fff'].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                      },
                      hint: const Text('Select number of infants'),
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Flight Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyDropDown(
                      items: ['Roundtrip', 'One-way'].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          flightType = value as String?;
                        });
                      },
                      hint: const Text('Select number of infants'),
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // if (flightType == 'One-way')
                    const Text(
                      'Departure Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyDropDown(
                      items: ['r', 'O'].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                      },
                      hint: const Text('Select a date'),
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Return Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    MyDropDown(
                      items: ['R', 'O'].map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                      },
                      hint: const Text('Select a date'),
                      validator: (value) {
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SubmitButton(
                action: () {},
                title: 'Continue',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
