import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/billings.dart';
import 'package:kasheto_flutter/provider/billing_provider.dart';
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/provider/wallet_provider.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/dialog_chip.dart';
import 'package:kasheto_flutter/widgets/dialog_row.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/my_dropdown.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';

class DataPurchasePage extends StatefulWidget {
  final List<BillingPlan> dataPlan;
  const DataPurchasePage({required this.dataPlan, Key? key}) : super(key: key);

  @override
  State<DataPurchasePage> createState() => _DataPurchasePageState();
}

class _DataPurchasePageState extends State<DataPurchasePage> {
  var _isLoading = false;
  String? _planDropdownValue;
  String? _dropDownValue;
  String? _ktcAmount;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  BillingPlan? _selectedDataPlan;

  List<BillingPlan>? _operatorDataPlan;

  void _getDataPlanByOperator() {
    _operatorDataPlan = widget.dataPlan
        .where((element) => element.genName == _dropDownValue)
        .toList();
  }

  void _getSelectedDataPlan() {
    _selectedDataPlan = _operatorDataPlan!
        .firstWhere((element) => element.name == _planDropdownValue);
  }

  void _getKtcAmount() {
    if (_selectedDataPlan == null) {
      _ktcAmount = '0.00';
    }
    final _naira2ktc =
        Provider.of<PlatformChargesProvider>(context, listen: false).nairaToKtc;
    final _amount = double.parse(_selectedDataPlan!.amount) * _naira2ktc;
    _ktcAmount = _amount.toString();
  }

  List<String> get _operatorList {
    return Provider.of<BillingProvider>(context, listen: false).operatorList;
  }

  num get _walletBalance {
    return Provider.of<WalletProvider>(context, listen: false).walletBalance;
  }

  Future _validateData() async {
    final _isValid = _formKey.currentState!.validate();
    if (_isValid) {
      if (double.parse(_ktcAmount!) > _walletBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(
              message:
                  'You have insufficient Kasheto funds to purchase the choosen plan',
              context: context),
        );
      } else {
        final isConfirmed = await _confirmationDialog(
            context: context,
            amount: _selectedDataPlan!.amount,
            operatorName: _dropDownValue!,
            planName: _planDropdownValue!,
            operatorNumber: _phoneController.text);
        if (isConfirmed != null && isConfirmed) {
          _buyData();
        }
      }
    }
  }

  Future _buyData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final _userCurrency = Provider.of<AuthProvider>(context, listen: false)
          .userList[0]
          .userCurrency;
      final url =
          Uri.parse('${ApiUrl.baseURL}user/bills/paybills?is_airtime=true');
      final _header = await ApiUrl.setHeaders();
      final _body = json.encode({
        'card_number': _phoneController.text,
        'amount': _selectedDataPlan!.amount,
        'ktc_value': _ktcAmount,
        'plan_id': _selectedDataPlan!.id.toString(),
        'currency': _userCurrency,
      });
      final _response = await http.post(url, headers: _header, body: _body);
      final res = json.decode(_response.body);

      if (res['status'] == 'success') {
        Provider.of<WalletProvider>(context, listen: false)
            .reduceKtcWalletBalance(double.parse(_ktcAmount!));
        await Alert.showDataPurchaseSuccessDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: ApiUrl.errorString, context: context),
        );
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert.snackBar(message: ApiUrl.internetErrorString, context: context),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert.snackBar(message: ApiUrl.errorString, context: context),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      const TextFieldText(text: 'Select Operator'),
                      const SizedBox(
                        height: 5,
                      ),
                      MyDropDown(
                        validator: (value) {
                          if (value == null) {
                            return 'Choose an operator';
                          } else {
                            return null;
                          }
                        },
                        value: _dropDownValue,
                        hint: _dropDownValue == null
                            ? const FittedBox(
                                child: Text(
                                  'E.g MTN, Airtel, etc.',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : FittedBox(
                                child: Text(
                                  _dropDownValue!.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        items: _operatorList.map(
                          (val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(
                                val.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (val) {
                          setState(
                            () {
                              _dropDownValue = val as String?;
                              _getDataPlanByOperator();
                            },
                          );
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const TextFieldText(text: 'Phone Number'),
                      const SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: _phoneController,
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'This field cannot be empty';
                          } else if (int.tryParse(value) == null) {
                            return 'Enter a valid number';
                          } else if (value.length > 11) {
                            return 'Phone number too long';
                          } else if (value.length < 11) {
                            return 'Phone number too short';
                          } else if (!value.startsWith('0')) {
                            return 'Enter a valid number';
                          } else {
                            return null;
                          }
                        }),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: MyPadding.textFieldContentPadding,
                          filled: true,
                          fillColor: MyColors.textFieldColor,
                          isDense: true,
                          hintText: 'E.g 08135467889',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
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
                      const TextFieldText(text: 'Select Plan'),
                      const SizedBox(
                        height: 5,
                      ),
                      if (_operatorDataPlan == null)
                        Container(
                          width: double.infinity,
                          padding: MyPadding.textFieldContentPadding,
                          decoration: BoxDecoration(
                            color: MyColors.textFieldColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text('Select an operator'),
                        ),
                      if (_operatorDataPlan != null)
                        MyDropDown(
                          value: _planDropdownValue,
                          validator: (value) {
                            if (value == null) {
                              return 'Choose a Data Plan';
                            } else {
                              return null;
                            }
                          },
                          hint: FittedBox(
                            child: Text(
                              _planDropdownValue ?? "Select a data plan",
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          items: _operatorDataPlan!.map(
                            (val) {
                              return DropdownMenuItem<String>(
                                value: val.name,
                                child: Text(
                                  val.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (val) {
                            setState(
                              () {
                                _planDropdownValue = (val as String?)!;
                                _getSelectedDataPlan();
                                _getKtcAmount();
                              },
                            );
                          },
                        ),
                      const SizedBox(
                        height: 15,
                      ),
                      const TextFieldText(text: 'Amount'),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: double.infinity,
                        padding: MyPadding.textFieldContentPadding,
                        decoration: BoxDecoration(
                            color: MyColors.textFieldColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          _selectedDataPlan == null
                              ? '0.00'
                              : _selectedDataPlan!.amount,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          const TextFieldText(text: 'Value in KTC'),
                          const Spacer(),
                          Text(
                            'k ${_walletBalance.toString()}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontFamily: '',
                              fontSize: 11,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: double.infinity,
                        padding: MyPadding.textFieldContentPadding,
                        decoration: BoxDecoration(
                          color: MyColors.textFieldColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _ktcAmount ?? '0.00',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          const Text(
                            'The current exhange rate is',
                            style: TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'NGN 1 = K ${Provider.of<PlatformChargesProvider>(context, listen: false).nairaToKtc}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_isLoading) const LoadingSpinnerWithMargin(),
                if (!_isLoading)
                  SubmitButton(
                      action: () {
                        _validateData();
                      },
                      title: 'Continue')
              ],
            ),
          ),
        );
      }),
    );
  }
}

Future<bool?> _confirmationDialog({
  required BuildContext context,
  required String amount,
  required String operatorName,
  required String planName,
  required String operatorNumber,
}) {
  return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 30,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Confirm Data Purchase !!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(thickness: 1),
                DialogRow(title: 'Amount', content: amount),
                const Divider(thickness: 1),
                DialogRow(title: 'Operator', content: operatorName),
                const Divider(thickness: 1),
                DialogRow(title: 'Data Plan', content: planName),
                const Divider(thickness: 1),
                DialogRow(title: 'Phone Number', content: operatorNumber),
                const Divider(thickness: 1),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Spacer(),
                    DialogChip(
                        onTap: () {
                          Navigator.of(context).pop(false);
                        },
                        text: 'Cancel',
                        color: Colors.red),
                    const SizedBox(
                      width: 15,
                    ),
                    DialogChip(
                        onTap: () {
                          Navigator.of(context).pop(true);
                        },
                        text: 'Continue',
                        color: Colors.green),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        );
      });
}
