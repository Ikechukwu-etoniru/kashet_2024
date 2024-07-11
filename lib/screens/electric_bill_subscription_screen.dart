import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/billings.dart';
import 'package:kasheto_flutter/provider/billing_provider.dart';
import 'package:kasheto_flutter/provider/platform_provider.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/provider/wallet_provider.dart';
import 'package:kasheto_flutter/screens/main_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/widgets/dialog_chip.dart';
import 'package:kasheto_flutter/widgets/dialog_row.dart';
import 'package:kasheto_flutter/widgets/error_widget.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/my_dropdown.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';

class ElectricBillSubscriptionScreen extends StatefulWidget {
  static const routeName = '/electric_bill_subscription_screen.dart';
  const ElectricBillSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<ElectricBillSubscriptionScreen> createState() =>
      _ElectricBillSubscriptionScreenState();
}

class _ElectricBillSubscriptionScreenState
    extends State<ElectricBillSubscriptionScreen> {
  final _textFieldContentPadding = const EdgeInsets.all(10);
  String? _ktcAmount;
  String? _dropDownValue;
  var _isLoading = false;
  var _isError = false;
  List<ElectricPlan>? _electricplanList;
  ElectricPlan? _selectedElectricPlan;
  final _amountController = TextEditingController();
  final _meterController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isButtonLoading = false;

  void _getSelectedElectricPlan() {
    final _selectedPlan = _electricplanList?.firstWhere((element) {
      return element.name == _dropDownValue;
    });
    _selectedElectricPlan = _selectedPlan;
  }

  void _getKtcAmount() {
    final _nairaAmount = _amountController.text.isEmpty
        ? 0
        : double.parse(_amountController.text);
    final _nairaToKtc =
        Provider.of<PlatformChargesProvider>(context, listen: false).nairaToKtc;
    final ktcAmount = _nairaAmount * _nairaToKtc;
    _ktcAmount = ktcAmount.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future _loadDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<BillingProvider>(context, listen: false)
          .getElectricPlans();
      _electricplanList =
          Provider.of<BillingProvider>(context, listen: false).electricPlans;
    } catch (error) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  num get _walletBalance {
    return Provider.of<WalletProvider>(context, listen: false).walletBalance;
  }

  Future _validateElectric() async {
    final _isValid = _formKey.currentState!.validate();
    if (_isValid && double.parse(_ktcAmount!) > _walletBalance) {
      return ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message: 'You have insufficient Kasheto funds to purchse this plan',
          context: context));
    } else {
      final _isConfirmed = await _confirmationDialog(
          context: context,
          amount: _amountController.text,
          subName: _dropDownValue!,
          subNumber: _meterController.text);
      if (_isConfirmed != null && _isConfirmed) {
        _payElectric();
      }
    }
  }

  Future _payElectric() async {
    try {
      setState(() {
        _isButtonLoading = true;
      });
      final _userCurrency = Provider.of<AuthProvider>(context, listen: false)
          .userList[0]
          .userCurrency;
      final url = Uri.parse('${ApiUrl.baseURL}user/bills/paybills');
      final _header = await ApiUrl.setHeaders();
      final _body = json.encode({
        'card_number': _meterController.text,
        'amount': _amountController.text,
        'ktc_value': _ktcAmount,
        'plan_id': _selectedElectricPlan!.id,
        'currency': _userCurrency,
      });
      final _response = await http.post(url, headers: _header, body: _body);
      final res = json.decode(_response.body);
      if (_response.statusCode == 200 && res['status'] == 'success') {
        Provider.of<WalletProvider>(context, listen: false)
            .reduceKtcWalletBalance(double.parse(_ktcAmount!));
        await Alert.showSuccessDialog(
            context: context,
            text: 'Your Electric bill payment was successful',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  MainScreen.routeName, (route) => false);
            });
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
        _isButtonLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformCharges = Provider.of<PlatformChargesProvider>(context);
    return _isLoading
        ? const LoadingSpinnerWithScaffold()
        : _isError
            ? const IsErrorScreen()
            : SafeArea(
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    title: const Text('Electricity Bill'),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const TextFieldText(text: 'Select Provider'),
                          const SizedBox(
                            height: 5,
                          ),
                          MyDropDown(
                              validator: (value) {
                                if (value == null) {
                                  return 'Select a provider';
                                } else {
                                  return null;
                                }
                              },
                              items: _electricplanList!.map((e) {
                                return DropdownMenuItem(
                                  value: e.name,
                                  child: Text(
                                    e.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }).toList(),
                              value: _dropDownValue,
                              onChanged: (val) {
                                setState(
                                  () {
                                    _dropDownValue = val as String?;
                                    _getSelectedElectricPlan();
                                  },
                                );
                              },
                              hint:
                                  // _dropDownValue == null
                                  //     ?
                                  const Text(
                                'E.g EKEDC',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              )
                              // : FittedBox(
                              //     child: Text(
                              //       'test',
                              //       // _dropDownValue!,
                              //       overflow: TextOverflow.ellipsis,
                              //       maxLines: 1,
                              //       softWrap: true,
                              //     ),
                              //   ),
                              ),
                          const SizedBox(
                            height: 20,
                          ),
                          const TextFieldText(text: 'Meter Number'),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: _meterController,
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
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              contentPadding: _textFieldContentPadding,
                              filled: true,
                              fillColor: MyColors.textFieldColor,
                              isDense: true,
                              hintText: 'Enter meter number',
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
                          const TextFieldText(text: 'Amount'),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 40,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: MyColors.textFieldColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    '₦',
                                    style: TextStyle(
                                        fontFamily: '',
                                        fontSize: 14,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Expanded(
                                child: TextFormField(
                                  maxLength: 19,
                                  onChanged: (value) {
                                    setState(() {
                                      _getKtcAmount();
                                    });
                                  },
                                  controller: _amountController,
                                  validator: ((value) {
                                    if (value == null || value.isEmpty) {
                                      return 'This field cannot be empty';
                                    } else if (double.tryParse(value) == null ||
                                        double.parse(value) < 0) {
                                      return 'Enter a valid number';
                                    } else {
                                      return null;
                                    }
                                  }),
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context).unfocus();
                                  },
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: InputDecoration(
                                    counterStyle: const TextStyle(
                                      height: double.minPositive,
                                    ),
                                    counterText: "",
                                    contentPadding: const EdgeInsets.all(10),
                                    filled: true,
                                    fillColor: MyColors.textFieldColor,
                                    isDense: true,
                                    hintText: '0.00',
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
                              ),
                            ],
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
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 35,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: MyColors.textFieldColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'k',
                                    style: TextStyle(
                                      fontFamily: '',
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Expanded(
                                child: TextFormField(
                                  enabled: false,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(10),
                                    filled: true,
                                    fillColor: MyColors.textFieldColor,
                                    isDense: true,
                                    hintText: _ktcAmount,
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
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              const Text(
                                'The current exhange rate is',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                '1 NGN = ${platformCharges.nairaToKtc} KTC',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (_isButtonLoading) const LoadingSpinner(),
                          if (!_isButtonLoading)
                            SubmitButton(
                                action: () {
                                  _validateElectric();
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

Future<bool?> _confirmationDialog({
  required BuildContext context,
  required String amount,
  required String subName,
  required String subNumber,
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
                  'Confirm Electric Subscribtion !!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(thickness: 1),
                DialogRow(title: 'Amount', content: amount),
                const Divider(thickness: 1),
                DialogRow(title: 'Electric Company', content: subName),
                const Divider(thickness: 1),
                DialogRow(title: 'Meter Number', content: subNumber),
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
