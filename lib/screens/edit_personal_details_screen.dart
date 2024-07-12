import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/models/location.dart';
import 'package:kasheto_flutter/models/user.dart';
import 'package:kasheto_flutter/provider/location_provider.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/initialization_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_colors.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/date_selecter.dart';
import 'package:kasheto_flutter/widgets/error_widget.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/my_dropdown.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';

class EditPersonalDetailsScreen extends StatefulWidget {
  static const routeName = '/edit_personal_details_screen.dart';
  const EditPersonalDetailsScreen({Key? key}) : super(key: key);

  @override
  State<EditPersonalDetailsScreen> createState() =>
      _EditPersonalDetailsScreenState();
}

class _EditPersonalDetailsScreenState extends State<EditPersonalDetailsScreen> {
  final _textFieldContentPadding = MyPadding.textFieldContentPadding;
  DateTime? date;
  String? _countryDropdown;
  String? _userCity;
  String? _stateDropdown;
  var _isLoading = false;
  var _isButtonLoading = false;
  var _isError = false;
  List<CountryModel>? countriesList;
  final _formKey = GlobalKey<FormState>();
  String? _userAddress;
  String? _userName;
  int? _countryId;
  int? _stateId;
  CountryModel? _choosenCountry;
  List<States>? _stateList;

  void selectDate(DateTime selectedDate) {
    date = selectedDate;
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
      countriesList =
          Provider.of<LocationProvider>(context, listen: false).countriesList;
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

  User get _user {
    return Provider.of<AuthProvider>(context, listen: false).userList[0];
  }

  void _getCountry(Object countryName) {
    _choosenCountry = Provider.of<LocationProvider>(context, listen: false)
        .getCountry(countryName as String);
    _countryId = _choosenCountry!.id;
    _stateList = _choosenCountry!.states;
  }

  void _getStateId(Object stateName) {
    var _choosenState = _choosenCountry!.states
        .firstWhere((element) => element.name == stateName);

    _stateId = _choosenState.stateId;
  }

  bool _verifyDetails() {
    final _isValid = _formKey.currentState!.validate();
    if (!_isValid) {
      return false;
    } else if (date == null && _user.dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message: 'Choose your date of birth', context: context));
      return false;
    } else if (date == null && _user.dob != null) {
      return true;
    } else {
      return true;
    }
  }

  Future<void> _updateProfile() async {
    // Validate form first
    final _isValid = _verifyDetails();
    if (_isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isButtonLoading = true;
      });
      try {
        final url = Uri.parse('${ApiUrl.baseURL}user/profile/personal_details');
        final _header = await ApiUrl.setHeaders();
        final response = await http.post(url,
            headers: _header,
            body: json.encode({
              "dob": _user.dob != null && date == null
                  ? _user.dob
                  : date.toString().substring(0, 10),
              "city": _userCity,
              "country_id": _user.country != null && _countryId == null
                  ? _user.country
                  : _countryId.toString(),
              "state_id": _user.state != null && _stateId == null
                  ? _user.state
                  : _stateId.toString(),
              "name": _userName,
              "address": _userAddress
            }));
        final res = json.decode(response.body);
        if (response.statusCode == 200 && res['success'] == 'true') {
          _shoSuccessDialog(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              Alert.snackBar(message: ApiUrl.errorString, context: context));
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
                    title: const Text('Edit your Personal Details'),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                const TextFieldText(text: 'First Name'),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  initialValue: _user.firstName,
                                  textCapitalization: TextCapitalization.words,
                                  onSaved: (value) {
                                    _userName = value;
                                  },
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
                                  style: const TextStyle(fontSize: 13),
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    contentPadding: _textFieldContentPadding,
                                    isDense: true,
                                    hintText: 'Enter Your First Name',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide.none),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const TextFieldText(text: 'Last Name'),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  initialValue: _user.lastName,
                                  textCapitalization: TextCapitalization.words,
                                  onSaved: (value) {
                                    _userName = value;
                                  },
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
                                  style: const TextStyle(fontSize: 13),
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    contentPadding: _textFieldContentPadding,
                                    isDense: true,
                                    hintText: 'Enter Your Last Name',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide.none),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const TextFieldText(text: 'Date Of Birth'),
                                const SizedBox(
                                  height: 5,
                                ),
                                DateSelecterForDob(
                                    selectDate: selectDate,
                                    initialDOB: _user.dob),
                                const SizedBox(
                                  height: 20,
                                ),
                                const TextFieldText(text: 'Address'),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  initialValue: _user.address ?? '',
                                  textCapitalization: TextCapitalization.words,
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context).unfocus();
                                  },
                                  onSaved: (value) {
                                    _userAddress = value;
                                  },
                                  validator: ((value) {
                                    if (value == null || value.isEmpty) {
                                      return 'This field cannot be empty';
                                    } else {
                                      return null;
                                    }
                                  }),
                                  style: const TextStyle(fontSize: 13),
                                  keyboardType: TextInputType.streetAddress,
                                  decoration: InputDecoration(
                                    contentPadding: _textFieldContentPadding,
                                    isDense: true,
                                    hintText: 'Enter your home address',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide.none),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const TextFieldText(text: 'Country'),
                                const SizedBox(
                                  height: 5,
                                ),
                                MyDropDown(
                                  items: countriesList!.map(
                                    (val) {
                                      return DropdownMenuItem(
                                        value: val.name,
                                        child: Text(
                                          val.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                  value: _countryDropdown,
                                  onChanged: (val) {
                                    // Use country to show states and send is to backend
                                    _getCountry(val!);
                                    setState(
                                      () {
                                        _countryDropdown = val as String;
                                        _stateDropdown = null;
                                      },
                                    );
                                  },
                                  hint: FittedBox(
                                    child: Text(
                                      (_user.country == null ||
                                                  _user.country == 'null') &&
                                              _countryDropdown == null
                                          ? 'Select a Country'
                                          : (_user.country != null ||
                                                      _user.country ==
                                                          'null') &&
                                                  _countryDropdown == null
                                              ? Provider.of<LocationProvider>(
                                                      context,
                                                      listen: false)
                                                  .getCountryById(
                                                      int.parse(_user.country!))
                                              : _countryDropdown!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  validator: (val) {
                                    if ((_user.country == null ||
                                            _user.country == 'null') &&
                                        val == null) {
                                      return 'Pick a Country';
                                    } else if ((_user.country == null ||
                                            _user.country == 'null') &&
                                        _choosenCountry == null) {
                                      return 'Choose a country first';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const TextFieldText(text: 'State'),
                                const SizedBox(
                                  height: 5,
                                ),
                                if (_choosenCountry == null)
                                  Container(
                                    padding: MyPadding.textFieldContentPadding,
                                    decoration: BoxDecoration(
                                      color: MyColors.textFieldColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      _user.state == null ||
                                              _user.state == 'null'
                                          ? 'No Country Selected'
                                          : Provider.of<LocationProvider>(
                                                  context,
                                                  listen: false)
                                              .getStateById(
                                                  int.parse(_user.state!)),
                                      style: const TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                if (_choosenCountry != null)
                                  // Remember
                                  MyDropDown(
                                    value: _stateDropdown,
                                    items: _stateList!.map(
                                      (val) {
                                        return DropdownMenuItem(
                                          value: val.name,
                                          child: Text(
                                            val.name,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: (val) {
                                      // Will send state id to database
                                      _getStateId(val!);
                                      setState(
                                        () {
                                          _stateDropdown = val as String;
                                        },
                                      );
                                    },
                                    hint: FittedBox(
                                      child: Text(
                                        (_user.state == null ||
                                                    _user.state == 'null') &&
                                                _stateDropdown == null
                                            ? 'Select a State'
                                            : (_user.state != null ||
                                                        _user.state ==
                                                            'null') &&
                                                    _stateDropdown == null
                                                ? Provider.of<LocationProvider>(
                                                        context,
                                                        listen: false)
                                                    .getStateById(
                                                        int.parse(_user.state!))
                                                : _stateDropdown!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    validator: (val) {
                                      if ((_user.state == null ||
                                              _user.state == 'null') &&
                                          val == null) {
                                        return 'Pick a State';
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const TextFieldText(text: 'City'),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  initialValue: _user.city ?? '',
                                  textCapitalization: TextCapitalization.words,
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context).unfocus();
                                  },
                                  onSaved: (value) {
                                    _userCity = value;
                                  },
                                  style: const TextStyle(fontSize: 13),
                                  validator: ((value) {
                                    if (value == null || value.isEmpty) {
                                      return 'This field cannot be empty';
                                    } else {
                                      return null;
                                    }
                                  }),
                                  keyboardType: TextInputType.streetAddress,
                                  decoration: InputDecoration(
                                    contentPadding: _textFieldContentPadding,
                                    isDense: true,
                                    hintText: 'Enter your City',
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide.none),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          if (_isButtonLoading)
                            const LoadingSpinnerWithMargin(),
                          if (!_isButtonLoading)
                            SubmitButton(
                              action: () {
                                if (Provider.of<AuthProvider>(context)
                                        .userVerified ==
                                    IDStatus.approved) {
                                  Alert.showerrorDialog(
                                      context: context,
                                      text:
                                          'You cant change your personal details after your identity has been verified',
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      });
                                  return;
                                }

                                _updateProfile();
                              },
                              title: 'Update Profile',
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              );
  }
}

Future<void> _shoSuccessDialog(BuildContext context) async {
  showDialog(
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
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: Image.asset(
                    'images/happy_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Good Job !!!!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  'You have updated your details',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: InkWell(
                    onTap: (() {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          InitializationScreen.routeName, (route) => false);
                    }),
                    child: Chip(
                      backgroundColor: Colors.green,
                      label: const Text(
                        'Close',
                        style: TextStyle(color: Colors.white),
                      ),
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      });
}
