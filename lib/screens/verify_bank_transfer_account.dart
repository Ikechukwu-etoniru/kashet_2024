import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:kasheto_flutter/models/bank.dart';
import 'package:kasheto_flutter/provider/bank_provider.dart';
import 'package:kasheto_flutter/screens/bank_transfer_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/my_dropdown.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';

class VerifyBankTransferAccount extends StatefulWidget {
  static const routeName = 'verify_bank_transfer_account.dart';
  const VerifyBankTransferAccount({Key? key}) : super(key: key);

  @override
  State<VerifyBankTransferAccount> createState() =>
      _VerifyBankTransferAccountState();
}

class _VerifyBankTransferAccountState extends State<VerifyBankTransferAccount> {
  final _textFieldContentPadding = MyPadding.textFieldContentPadding;
  final _textFieldColor = MyColors.textFieldColor;
  String _dropDownValue = 'Choose bank';
  String? _countryDropDownValue;
  String? _bankId;
  String? _beneName;
  Bank? _selectedBank;
  var _isLoading = false;
  var _isButtonLoading = false;
  List<Bank>? _isoBankList;
  List<String>? _isoBankListString;
  final _acctNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> _bankCountryList = [
    'Nigeria',
    'Kenya',
    'Ghana',
    'South Africa',
    'Tanzania'
  ];

  void _getBankId(String value) {
    _selectedBank = _isoBankList!.firstWhere((element) {
      return element.name == value;
    });
    _bankId = _selectedBank!.code;
  }

  Future _verifyAcctNumber() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    setState(() {
      _isButtonLoading = true;
    });

    try {
      final url =
          Uri.parse('${ApiUrl.baseURL}user/profile/confirm-bank-account');
      final _header = await ApiUrl.setHeaders();
      final _body = json.encode({
        'account_number': _acctNumberController.text,
        'bank_id': _selectedBank!.id,
        // 'account_bank': _selectedBank!.id,
        // 'code': _selectedBank!.code
      });
      final response = await http.post(url, body: _body, headers: _header);
      final res = json.decode(response.body);
      if (res["status"] == true && res['account_name'] != null) {
        _beneName = res['account_name'];

        final userClickContinue = await Alert.showVerifyAcctDialog(
          context: context,
          name: _beneName!,
          bank: _selectedBank!,
        );

        if (userClickContinue == null || !userClickContinue) {
          return;
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return BankTransfer(
              bank: _selectedBank!,
              acctNumber: _acctNumberController.text,
              countryDropDownValue: _countryDropDownValue!,
              beneficiaryName: _beneName!,
            );
          }));
        }
      } else if (res["status"] == false) {
        Alert.showerrorDialog(
            context: context,
            text: res["message"],
            onPressed: () {
              Navigator.of(context).pop();
            });
        _beneName = '';
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message:
              'Account number couldn\'t be verified. Check the account number and bank or try again later',
          context: context));
      _beneName = '';
      return false;
    } finally {
      setState(() {
        _isButtonLoading = false;
      });
    }
  }

  Future _getBankList(String iso) async {
    setState(() {
      _isLoading = true;
    });
    try {
      _isoBankList = await Provider.of<BankProvider>(context, listen: false)
          .getBankListByIso(iso);
      _isoBankListString = _isoBankList!.map((e) {
        return e.name;
      }).toList();
      _isoBankListString!.sort();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message: 'An error occured. Banks couldn\'t be fetched',
          context: context));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getBankIso(String val) {
    if (val == 'Nigeria') {
      return 'NG';
    } else if (val == 'Kenya') {
      return 'KE';
    } else if (val == 'Ghana') {
      return 'GH';
    } else if (val == 'South Africa') {
      return 'ZA';
    } else if (val == 'Tanzania') {
      return 'TZ';
    } else {
      return 'NG';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Bank Account'),
      ),
      body: Padding(
        padding: MyPadding.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextFieldText(text: 'Bank Country'),
              const SizedBox(
                height: 5,
              ),
              MyDropDown(
                  items: _bankCountryList.map(
                    (val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(
                          val,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                  value: _countryDropDownValue,
                  onChanged: (val) {
                    setState(
                      () {
                        _countryDropDownValue = val as String?;
                        _getBankList(_getBankIso(_countryDropDownValue!));
                      },
                    );
                  },
                  hint: _countryDropDownValue == null
                      ? const FittedBox(
                          child: Text(
                            'Choose Bank Country',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        )
                      : FittedBox(
                          child: Text(
                            _countryDropDownValue!,
                          ),
                        ),
                  validator: (value) {
                    if (value == null) {
                      return 'Choose a Bank Country';
                    } else {
                      return null;
                    }
                  }),
              const SizedBox(
                height: 20,
              ),
              const TextFieldText(text: 'Account Number'),
              const SizedBox(
                height: 5,
              ),
              if (_countryDropDownValue == null)
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
                        message: 'Choose a bank country first',
                        context: context));
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: MyColors.textFieldColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Beneficiary Account Number',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              if (_countryDropDownValue != null)
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter beneficiary account number';
                    } else if (value.length < 10) {
                      return 'Account number is short by ${10 - value.length} numbers';
                    } else if (value.length > 10) {
                      return 'Account number is too long with ${value.length - 10} extra numbers';
                    } else {
                      return null;
                    }
                  },
                  controller: _acctNumberController,
                  onFieldSubmitted: (value) async {
                    FocusScope.of(context).unfocus();
                  },
                  style: const TextStyle(fontSize: 12),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: _textFieldContentPadding,
                    isDense: true,
                    hintText: 'Beneficiary account number',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: _textFieldColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              const TextFieldText(text: 'Bank Name'),
              const SizedBox(
                height: 5,
              ),
              if (_countryDropDownValue == null)
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
                        message: 'Choose a bank country first',
                        context: context));
                  },
                  child: Container(
                    width: double.infinity,
                    padding: MyPadding.textFieldContentPadding,
                    decoration: BoxDecoration(
                      color: MyColors.textFieldColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Choose Bank',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              if (_isLoading) const LoadingSpinnerWithMargin(),
              if (_countryDropDownValue != null && _isLoading == false)
                DropdownSearch<String>(
                  validator: (value) {
                    if (value == null) {
                      return 'Choose a Bank';
                    } else {
                      return null;
                    }
                  },
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    showSelectedItems: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        contentPadding: _textFieldContentPadding,
                        isDense: true,
                        hintText: 'Search',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: _textFieldColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  items: _isoBankListString!,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      contentPadding: _textFieldContentPadding,
                      isDense: true,
                      hintText: _dropDownValue,
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: _textFieldColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  onChanged: (value) {
                    setState(
                      () {
                        _dropDownValue = value.toString();
                        _getBankId(value.toString());
                      },
                    );
                  },
                ),
              const SizedBox(
                height: 20,
              ),
              const Spacer(),
              if (_isButtonLoading) const LoadingSpinnerWithMargin(),
              if (!_isButtonLoading)
                SubmitButton(
                  action: _verifyAcctNumber,
                  title: 'Verify Account',
                )
            ],
          ),
        ),
      ),
    );
  }
}

// akinolaoladimeji507@yahoo.com
// Passme@123
