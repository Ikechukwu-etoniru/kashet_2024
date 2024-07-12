import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasheto_flutter/models/id_model.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/main_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/my_padding.dart';
import 'package:kasheto_flutter/widgets/image_with_placeholder.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/my_dropdown.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:http/http.dart' as http;
import 'package:kasheto_flutter/widgets/text_field_text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyIdCardScreen extends StatefulWidget {
  static const routeName = '/verify_id_card_screen.dart';
  const VerifyIdCardScreen({Key? key}) : super(key: key);

  @override
  State<VerifyIdCardScreen> createState() => _VerifyIdCardScreenState();
}

class _VerifyIdCardScreenState extends State<VerifyIdCardScreen> {
  final _idTypeList = [
    'NIN',
    'PVC',
    "Driver's License",
    'International Passport',
  ];

  String? _selectedDocument;
  final _idNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  var _isLoading = false;

  File? pickedImageFront;
  File? pickedImageBack;

  // akinolaoladimeji507@yahoo.com
  // Passme@123

  Future _uploadDucument() async {
    final _isValid = _formKey.currentState!.validate();
    if (!_isValid) {
      return;
    }
    if (pickedImageBack == null || pickedImageFront == null) {
      ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
          message: 'Upload the front and back of ur valid ID',
          context: context));
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var token = localStorage.getString('token');
      final url =
          Uri.parse('${ApiUrl.baseURL}user/profile/verification/verify');

      final request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      });

      request.files.add(
        await http.MultipartFile.fromPath('doc_front', pickedImageFront!.path),
      );

      request.files.add(
        await http.MultipartFile.fromPath('doc_back', pickedImageBack!.path),
      );

      request.fields['doc_type'] = _selectedDocument!;
      request.fields['doc_no'] = _idNumberController.text;

      // Send the request
      final response = await request.send();

      final responseString = await response.stream.bytesToString();

      final res = json.decode(responseString);

      print(res);
      print(response.statusCode);
      if (response.statusCode == 200 && res["status"] == true) {
        await Provider.of<AuthProvider>(context, listen: false)
            .checkVerificationStatus();
        Alert.showSuccessDialog(
            context: context,
            text: res['message'],
            onPressed: () {
              Navigator.of(context).pushNamed(MainScreen.routeName);
            });
      } else if ((response.statusCode == 200 || response.statusCode == 201) &&
          res["status"] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: res["message"], context: context));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(Alert.snackBar(
            message: 'An error occurred while uploading your document',
            context: context));
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        Alert.snackBar(
            message: 'An error occurred while uploading your document',
            context: context),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IdModel? get userId {
    return Provider.of<AuthProvider>(context, listen: false).userId;
  }

  Future<bool> _goBackToMenu() async {
    return await (showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                title: const Text(
                  'Confirm Exit',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                content: const Text(
                    'Are you sure you want to go back without submiting an ID'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(MainScreen.routeName);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      SharedPreferences localStorage =
                          await SharedPreferences.getInstance();
                      if (localStorage.containsKey('token')) {
                        localStorage.remove('token');
                      }
                      Navigator.of(context).pop(true);

                      Navigator.of(context).pushNamedAndRemoveUntil(
                          MainScreen.routeName, (route) => false);
                    },
                    child: const Text('Yes'),
                  )
                ],
              );
            })) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _goBackToMenu,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Verify Your identity'),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  MainScreen.routeName, (route) => false);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 15,
            ),
          ),
        ),
        body: Padding(
          padding: MyPadding.screenPadding,
          child: Form(
            key: _formKey,
            child: Provider.of<AuthProvider>(context).userVerified ==
                    IDStatus.pending
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellow[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'Your identity verification is still pending. Below are the details of the ID you submitted',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          'Document Number',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            hintText: userId != null
                                ? userId!.documentNumber
                                : 'No document number',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Document Type',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            hintText: userId != null
                                ? userId!.type
                                : 'No document type',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Document Front',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ImageWithPlaceholder(
                              networkImage:
                                  '${ApiUrl.imageLoader}${userId!.frontImage}',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Document Back',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ImageWithPlaceholder(
                              networkImage:
                                  '${ApiUrl.imageLoader}${userId!.backImage}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'Please upload a high resolution uncropped and/or scanned image document to get verified and unlock the full power of your dashboard.',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'It is important to note that the name on this document must match the name you used in signing up your account to be verified and it cannot be changed after verification.',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const TextFieldText(text: 'Document Type'),
                        const SizedBox(
                          height: 10,
                        ),
                        MyDropDown(
                          items: _idTypeList.map(
                            (val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(
                                  val,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            },
                          ).toList(),
                          value: _selectedDocument,
                          onChanged: (value) {
                            _selectedDocument = value as String;
                          },
                          hint: const Text(
                            'Pick Document',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'This field can\'t be empty';
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const TextFieldText(text: 'Document Number'),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _idNumberController,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).unfocus();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field can\'t be empty';
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            hintText: '',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const TextFieldText(text: 'Upload A Valid ID (Front)'),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _selectImageDialog(1);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    width: 1.5,
                                    color: Colors.black,
                                  ),
                                ),
                                child: const Text('Choose File'),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              pickedImageFront == null
                                  ? 'No file choosen'
                                  : 'File Selected',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            if (pickedImageFront != null)
                              const Icon(
                                Icons.check_box,
                                color: Colors.green,
                                size: 18,
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const TextFieldText(text: 'Upload A Valid ID (Back)'),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _selectImageDialog(2);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    width: 1.5,
                                    color: Colors.black,
                                  ),
                                ),
                                child: const Text('Choose File'),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              pickedImageBack == null
                                  ? 'No file choosen'
                                  : 'File Selected',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            if (pickedImageBack != null)
                              const Icon(
                                Icons.check_box,
                                color: Colors.green,
                                size: 18,
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (_isLoading)
                          const Center(
                            child: LoadingSpinnerWithMargin(),
                          ),
                        if (!_isLoading)
                          SubmitButton(
                            action: _uploadDucument,
                            title: 'Upload',
                          ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _selectImageDialog(int pos) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Center(
              child: Text(
                'Select Source',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final selectedImage = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (selectedImage == null) {
                          Navigator.of(context).pop();
                        }
                        Navigator.of(context).pop();
                        if (pos == 1) {
                          setState(() {
                            pickedImageFront = File(selectedImage!.path);
                          });
                        } else {
                          setState(() {
                            pickedImageBack = File(selectedImage!.path);
                          });
                        }
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.picture_in_picture),
                          SizedBox(
                            height: 5,
                          ),
                          Text('Gallery')
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final selectedImage =
                            await _picker.pickImage(source: ImageSource.camera);
                        if (selectedImage == null) {
                        } else {
                          setState(() {
                            Navigator.of(context).pop();
                            if (pos == 1) {
                              pickedImageFront = File(selectedImage.path);
                            } else {
                              pickedImageBack = File(selectedImage.path);
                            }
                          });
                        }
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.camera),
                          SizedBox(
                            height: 5,
                          ),
                          Text('Camera')
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Close',
                  ),
                )
              ],
            ),
          );
        });
  }
}
