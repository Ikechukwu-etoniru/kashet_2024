import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/bank.dart';
import 'package:kasheto_flutter/provider/bank_provider.dart';
import 'package:kasheto_flutter/screens/user_bank_list.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/error_widget.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';

class EditBankScreen extends StatefulWidget {
  final UserBank bank;
  const EditBankScreen({required this.bank, Key? key}) : super(key: key);

  @override
  State<EditBankScreen> createState() => _EditBankScreenState();
}

class _EditBankScreenState extends State<EditBankScreen> {
  String? _acctName;
  String? _acctNumber;
  List<Bank>? _bankList;
  List<String>? _bankListString;
  String? _bankId;
  String? _bankDropdown;
  var _isLoading = false;
  var _isError = false;
  var _isButtonLoading = false;
  final _formKey = GlobalKey<FormState>();
  final textEditingController = TextEditingController();

  void _getBankId(String value) {
    var _selectedBank = _bankList!.firstWhere((element) {
      return element.name == value;
    });
    _bankId = _selectedBank.code;
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initBankList();
  }

  Future _updateBankDetails() async {
    final _isValid = _formKey.currentState!.validate();
    if (!_isValid) {
      return;
    }
    _formKey.currentState!.save();
    if (_bankDropdown == null &&
        _acctName == widget.bank.acctName &&
        _acctNumber == widget.bank.acctNumber) {
      return ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message: 'You did not make any changes', context: context));
    }
    try {
      setState(() {
        _isButtonLoading = true;
      });
      final url =
          Uri.parse('${ApiUrl.baseURL}user/profile/change-bank-details');
      final _header = await ApiUrl.setHeaders();
      final _body = json.encode({
        "account_name": _acctName,
        "account_number": _acctNumber,
        "bank": _bankDropdown == null ? widget.bank.bankCode : _bankId,
        "user_bank_id": widget.bank.id
      });
      final response = await http.put(url, headers: _header, body: _body);
      final res = json.decode(response.body);
      if (res["message"] == "Updated Successfully") {
        ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: res['message'], context: context));
        Navigator.of(context).pushReplacementNamed(UserBankList.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: ApiUrl.errorString, context: context));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(message: ApiUrl.errorString, context: context));
    } finally {
      setState(() {
        _isButtonLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingSpinnerWithScaffold(
            title: Text('Edit Bank Information'),
          )
        : _isError
            ? const IsErrorScreen()
            : SafeArea(
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    title: const Text('Edit Bank Information'),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TextFieldText(text: 'Account Name'),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            initialValue: widget.bank.acctName,
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
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              contentPadding: MyPadding.textFieldContentPadding,
                              isDense: true,
                              hintText: 'Enter your account name',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
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
                          const TextFieldText(text: 'Account Number'),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            initialValue: widget.bank.acctNumber,
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
                            style:
                                const TextStyle(fontSize: 12, letterSpacing: 2),
                            decoration: InputDecoration(
                              contentPadding: MyPadding.textFieldContentPadding,
                              isDense: true,
                              hintText: 'Enter your account number',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
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
                          const TextFieldText(text: 'Select Bank'),
                          const SizedBox(
                            height: 5,
                          ),
                          DropdownButton2<String>(
                            isExpanded: true,
                            underline: Container(),
                            selectedItemBuilder: (context) {
                              return _bankListString!
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList();
                            },
                            iconStyleData: const IconStyleData(
                              iconEnabledColor: Colors.grey,
                              iconSize: 18,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                              ),
                            ),
                            hint: FittedBox(
                              child: Text(
                                _bankDropdown ?? widget.bank.bankName!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            items: _bankListString!
                                .map(
                                  (e) => DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(
                                      e,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            value: _bankDropdown,
                            onChanged: (val) {
                              final value = val as String;
                              _getBankId(value);
                              setState(
                                () {
                                  _bankDropdown = val;
                                },
                              );
                            },

                            buttonStyleData: ButtonStyleData(
                              padding: const EdgeInsets.only(
                                right: 5,
                                top: 1,
                                bottom: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            dropdownStyleData: const DropdownStyleData(
                              maxHeight: 200,
                              decoration: BoxDecoration(color: Colors.white),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                                height: 50,
                                selectedMenuItemBuilder: (ctx, child) {
                                  return Container(
                                    color: Colors.white,
                                    child: child,
                                  );
                                }),
                            dropdownSearchData: DropdownSearchData(
                              searchController: textEditingController,
                              searchInnerWidgetHeight: 40,
                              searchInnerWidget: Container(
                                height: 40,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 1,
                                  right: 8,
                                  left: 8,
                                ),
                                child: TextFormField(
                                  controller: textEditingController,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: InputDecoration(
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Icon(
                                        Icons.search,
                                        size: 13,
                                      ),
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                      maxHeight: 30,
                                      maxWidth: 50,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                      vertical: 8,
                                    ),
                                    fillColor: Colors.white,
                                    hintText: 'Search',
                                    hintStyle: const TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            //This to clear the search value when you close the menu
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {
                                textEditingController.clear();
                              }
                            },
                          ),
                          const Spacer(),
                          if (_isButtonLoading)
                            const LoadingSpinnerWithMargin(),
                          if (!_isButtonLoading)
                            SubmitButton(
                                action: () {
                                  _updateBankDetails();
                                },
                                title: 'Submit Details')
                        ],
                      ),
                    ),
                  ),
                ),
              );
  }
}
