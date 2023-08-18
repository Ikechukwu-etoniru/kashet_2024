import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kasheto_flutter/models/bank.dart';
import 'package:kasheto_flutter/provider/bank_provider.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/error_widget.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';

class AddBankScreen extends StatefulWidget {
  static const routeName = '/add_bank_screen.dart';
  const AddBankScreen({Key? key}) : super(key: key);

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _isError = false;
  var _isButtonLoading = false;
  List<Bank>? _bankList;
  List<String>? _bankListString;
  String? _bankDropdown;
  String? _acctName;
  String? _acctNumber;
  String? _bankId;

  void _getBankId(String value) {
    var _selectedBank = _bankList!.firstWhere((element) {
      return element.name == value;
    });
    _bankId = _selectedBank.id.toString();
  }

  Future _initBankList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<BankProvider>(context, listen: false)
          .getBankList(context);
      _bankList = Provider.of<BankProvider>(context, listen: false).bankList;

      _bankListString = _bankList!.map((e) {
        return e.name;
      }).toList();
      _bankListString!.sort();
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

  @override
  void initState() {
    super.initState();
    _initBankList();
  }

  Future<void> _sendBankDetails() async {
    final _isValid = _formKey.currentState!.validate();

    if (_isValid) {
      setState(() {
        _isButtonLoading = true;
      });
      try {
        _formKey.currentState!.save();
        final url = Uri.parse('${ApiUrl.baseURL}user/profile/add-bank');
        final _header = await ApiUrl.setHeaders();
        final response = await http.post(url,
            headers: _header,
            body: json.encode({
              "account_name": _acctName,
              "account_number": _acctNumber,
              "bank": _bankId
            }));
        if (response.statusCode == 201 || response.statusCode == 200) {
          await Provider.of<BankProvider>(context, listen: false).getUserBanksInformation();
          Alert.successDialogAddBank(context);
          Navigator.of(context).pop();
        } else if (response.statusCode == 422) {
          ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: response.body, context: context),
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
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingSpinnerWithScaffold()
        : _isError
            ? const IsErrorScreen()
            : SafeArea(
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    title: const Text('Bank Details'),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Name',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5),
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
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              contentPadding: MyPadding.textFieldContentPadding,
                              isDense: true,
                              hintText: 'Enter your account name',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none),
                            ),
                            onSaved: (value) {
                              _acctName = value;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'Account Number',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).unfocus();
                            },
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty';
                              } else if (int.tryParse(value) == null) {
                                return 'Enter a valid number';
                              } else if (value.length != 10) {
                                return 'Invalid length';
                              } else {
                                return null;
                              }
                            }),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: MyPadding.textFieldContentPadding,
                              isDense: true,
                              hintText: 'Enter your account number',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none),
                            ),
                            onSaved: (value) {
                              _acctNumber = value;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'Select Bank',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          /*MyDropDown(
                            items: _bankListString!.map(
                              (val) {
                                return DropdownMenuItem(
                                  value: val,
                                  child: Text(val),
                                );
                              },
                            ).toList(),
                            onChanged: (val) {
                              final value = val as String;
                              _getBankId(value);
                              setState(
                                () {
                                  _bankDropdown = val;
                                },
                              );
                            },
                            hint: FittedBox(
                              child: Text(
                                _bankDropdown ?? 'Choose a bank',
                              ),
                            ),
                            validator: (val) {
                              if (val == null) {
                                return 'Select a bank';
                              } else {
                                return null;
                              }
                            },
                          ),*/
                          DropdownSearch<String>(
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              showSelectedItems: true,
                            ),
                            items: _bankListString!,
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                isDense: true,
                                hintText: _bankDropdown ?? 'Choose a bank',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                            onChanged: (val) {
                              final value = val as String;
                              _getBankId(value);
                              setState(
                                () {
                                  _bankDropdown = val;
                                },
                              );
                            },
                          ),
                          const Spacer(),
                          if (_isButtonLoading)
                            const LoadingSpinnerWithMargin(),
                          if (!_isButtonLoading)
                            SubmitButton(
                              action: () {
                                _sendBankDetails();
                              },
                              title: 'Submit Details',
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              );
  }
}
