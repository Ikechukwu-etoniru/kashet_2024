import 'package:flutter/material.dart';
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';

import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:provider/provider.dart';

class BuyCryptoPage extends StatefulWidget {
  const BuyCryptoPage({Key? key}) : super(key: key);

  @override
  State<BuyCryptoPage> createState() => _BuyCryptoPageState();
}

class _BuyCryptoPageState extends State<BuyCryptoPage> {
  final _textFieldColor = Colors.grey[200];
  final _textFieldContentPadding = const EdgeInsets.all(10);
  final _btcAmountController = TextEditingController();
  final _valueController = TextEditingController();
  final _receiverAddressController = TextEditingController();
  double? _ktcValue;
  var _btcChargeAmount = '0';
  var _dropDownValue = 'NGN';
  final _formKey = GlobalKey<FormState>();

  void _calculateCharge(String val) {
    setState(() {
      if (val.isEmpty) {
        _btcChargeAmount = '0';
      } else if (double.tryParse(val) == null) {
        _btcChargeAmount = 'Error';
      } else {
        // Remember to put real charge
        _btcChargeAmount = (double.parse(val) * 0.01).toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        return Form(
          key: _formKey,
          child: SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(
                        height: constraints.maxHeight * 0.03,
                      ),
                      const Text(
                        'BTC',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        style: const TextStyle(
                          letterSpacing: 1,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field cannot be empty';
                          } else if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (val) {
                          _calculateCharge(val);
                        },
                        controller: _btcAmountController,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: _textFieldContentPadding,
                          filled: true,
                          fillColor: _textFieldColor,
                          isDense: true,
                          hintText: '0',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'Charge (BTC)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          contentPadding: _textFieldContentPadding,
                          filled: true,
                          fillColor: _textFieldColor,
                          isDense: true,
                          hintText: _btcChargeAmount.toString(),
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
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
                                  fontFamily: '',
                                  fontSize: 18,
                                  color: Colors.grey),
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
                        'Value',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Stack(
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.number,
                            maxLength: 19,
                            controller: _valueController,
                            validator: (value) {
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              counterText: '',
                              errorStyle: const TextStyle(fontSize: 10),
                              filled: true,
                              fillColor: MyColors.textFieldColor,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: constraints.maxWidth * 0.2),
                              //  MyPadding.textFieldContentPadding,
                              hintText: '0.00',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: constraints.maxWidth * 0.15,
                            height: 50,
                            child: Text(
                              _dropDownValue == 'NGN' ? '₦' : '\$',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20,
                                  fontFamily: ''),
                            ),
                          ),
                          Positioned(
                            right: 2,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              alignment: Alignment.center,
                              width: constraints.maxWidth * 0.2,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: DropdownButton(
                                focusColor: Colors.black,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                iconEnabledColor: Colors.grey,
                                iconDisabledColor: Colors.grey,
                                underline: const SizedBox(),
                                elevation: 0,
                                hint: Text(_dropDownValue),
                                isExpanded: true,
                                items: ['NGN', 'USD'].map(
                                  (val) {
                                    return DropdownMenuItem<String>(
                                      value: val,
                                      child: FittedBox(
                                        child: Text(val),
                                      ),
                                    );
                                  },
                                ).toList(),
                                onChanged: (val) {
                                  setState(
                                    () {
                                      _dropDownValue = val as String;
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
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
                        controller: _receiverAddressController,
                        validator: (value) {
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: _textFieldContentPadding,
                          filled: true,
                          fillColor: _textFieldColor,
                          isDense: true,
                          hintText: 'E.g XXighhdgsgdgdgfhfjjddh',
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
                      Container(
                        margin: const EdgeInsets.only(top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('The current exhange rate is'),
                            const SizedBox(width: 10),
                            Text(
                              'NGN 1 = K ${Provider.of<PlatformChargesProvider>(context, listen: false).nairaToKtc}',
                              style: const TextStyle(color: Colors.green),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              '1 USD = 47658 BTC',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SubmitButton(
                  action: () async {
                    final _isConfirmed =
                        await Alert.confirmCryptoPurchaseDialog(
                      context: context,
                      btcAmount: _btcAmountController.text,
                      btcCharge: _btcChargeAmount,
                      receiverAddress: _receiverAddressController.text,
                      ktcValue: _ktcValue.toString(),
                    );
                  },
                  title: 'Continue',
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
