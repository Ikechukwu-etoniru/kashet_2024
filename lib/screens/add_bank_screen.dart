import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
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

  final textEditingController = TextEditingController();

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
        final res = json.decode(response.body);
        if (response.statusCode == 201 || response.statusCode == 200) {
          await Provider.of<BankProvider>(context, listen: false)
              .getUserBanksInformation();
          Alert.successDialogAddBank(context);
          Navigator.of(context).pop();
        } else if (response.statusCode == 422) {
          Alert.showerrorDialog(
              context: context, text: res['message'], onPressed: () {});
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
                          DropdownButton2<String>(
                            isExpanded: true,
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
                            hint: const Text(
                              'Choose a bank',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
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
