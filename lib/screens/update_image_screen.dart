import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasheto_flutter/provider/auth_provider.dart';
import 'package:kasheto_flutter/screens/initialization_screen.dart';
import 'package:kasheto_flutter/screens/login_screen.dart';
import 'package:kasheto_flutter/utils/alerts.dart';
import 'package:kasheto_flutter/utils/api_url.dart';
import 'package:kasheto_flutter/utils/cloudinary_helper.dart';
import 'package:kasheto_flutter/widgets/loading_spinner.dart';
import 'package:kasheto_flutter/widgets/submit_button.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateImageScreen extends StatefulWidget {
  // Adding id when i load this screen from within the app to change photo
  final int? id;
  static const routeName = '/update_profile_screen.dart';
  const UpdateImageScreen({this.id, Key? key}) : super(key: key);

  @override
  State<UpdateImageScreen> createState() => _UpdateImageScreenState();
}

class _UpdateImageScreenState extends State<UpdateImageScreen> {
  var _isLoading = false;
  String? _imageUrl;
  Future<bool> _saveToCloudinary(String filePath, String fileName) async {
    setState(() {
      _isLoading = true;
    });
    final isSent = await CloudinaryHelper.sendImage(
        filePath: filePath, fileName: fileName);
    if (isSent.statusCode == 200) {
      _imageUrl = isSent.secureUrl;
      setState(() {
        _isLoading = false;
      });
      return true;
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        Alert.snackBar(message: 'An error occured', context: context),
      );
      setState(() {
        _isLoading = false;
      });
      return false;
    }
  }

  Future<bool> _sendImageToDatabase() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final url =
          Uri.parse('${ApiUrl.baseURL}user/profile/profile/upload-pics');
      final _header = await ApiUrl.setHeaders();
      final _body = {'photo': _imageUrl};
      final _httpResponse = await http.post(
        url,
        headers: _header,
        body: json.encode(_body),
      );
      final res = json.decode(_httpResponse.body);

      if (_httpResponse.statusCode == 200 && res['success'] == true) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          Alert.snackBar(
              message: 'Your picture has been updated', context: context),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            Alert.snackBar(message: ApiUrl.errorString, context: context));
        return false;
      }
    } on SocketException {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        Alert.snackBar(message: ApiUrl.internetErrorString, context: context),
      );
      return false;
    } catch (error) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        Alert.snackBar(message: 'An error occured', context: context),
      );
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? imagePath;
  void getPath(String path) {
    imagePath = path;
  }

  Future<bool> _closeApp() async {
    return await (showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                title: const Text(
                  'Confirm Exit...!!!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                content: const Text('Are you sure you want to logout'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
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

                      Navigator.of(context)
                          .pushReplacementNamed(LoginScreen.routeName);
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
    final user =
        Provider.of<AuthProvider>(context).userList[0].fullName;
    return widget.id == null
        ? WillPopScope(
            onWillPop: _closeApp,
            child: SafeArea(
              child: Scaffold(
            
                appBar: AppBar(
                  title: const Text('Add a Profile Image'),
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 100,
                      ),
                      ImagePickerBox(getPath: getPath),
                      const Spacer(),
                      if (_isLoading) const LoadingSpinnerWithMargin(),
                      if (!_isLoading)
                        SubmitButton(
                            action: () async {
                              if (imagePath == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    Alert.snackBar(
                                        message: 'Add an image first',
                                        context: context));
                                return;
                              }
            
                              final _isSavedToCloud = await _saveToCloudinary(
                                  imagePath!,
                                  "user: $user ${DateTime.now().microsecond}");
                              if (_isSavedToCloud) {
                                final _isSavedToDatabase =
                                    await _sendImageToDatabase();
                                if (_isSavedToDatabase) {
                                  Navigator.of(context)
                                      .pushNamed(InitializationScreen.routeName);
                                }
                              }
                            },
                            title: 'Continue')
                    ],
                  ),
                ),
              ),
            ),
          )
        : SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: const Text('Change Profile Image'),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    ImagePickerBox(getPath: getPath),
                    const Spacer(),
                    if (_isLoading) const LoadingSpinnerWithMargin(),
                    if (!_isLoading)
                      SubmitButton(
                          action: () async {
                            if (imagePath == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  Alert.snackBar(
                                      message: 'Add an image first',
                                      context: context));
                              return;
                            }
        
                            final _isSavedToCloud = await _saveToCloudinary(
                                imagePath!,
                                "user: $user ${DateTime.now().microsecond}");
                            if (_isSavedToCloud) {
                              final _isSavedToDatabase =
                                  await _sendImageToDatabase();
                              if (_isSavedToDatabase) {
                                Navigator.of(context)
                                    .pushNamed(InitializationScreen.routeName);
                              }
                            }
                          },
                          title: 'Change Image')
                  ],
                ),
              ),
            ),
        );
  }
}

class ImagePickerBox extends StatefulWidget {
  final Function getPath;
  const ImagePickerBox({required this.getPath, Key? key}) : super(key: key);

  @override
  State<ImagePickerBox> createState() => _ImagePickerBoxState();
}

class _ImagePickerBoxState extends State<ImagePickerBox> {
  File? pickedImage;

  void _getPath() {
    widget.getPath(pickedImage!.path);
  }

  final ImagePicker _picker = ImagePicker();

  void _selectImageDialog() {
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Row(
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
                        setState(() {
                          pickedImage = File(selectedImage!.path);
                          _getPath();
                        });
                      },
                      child: const Column(
                        children:  [
                          Icon(Icons.picture_in_picture),
                          SizedBox(
                            height: 5,
                          ),
                          Text('Gallery')
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        final selectedImage =
                            await _picker.pickImage(source: ImageSource.camera);
                        if (selectedImage == null) {
                        } else {
                          setState(() {
                            Navigator.of(context).pop();
                            pickedImage = File(selectedImage.path);
                            _getPath();
                          });
                        }
                      },
                      child: const Column(
                        children:  [
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
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text(
                    'Close',
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage: pickedImage == null ? null : FileImage(pickedImage!),
          child: pickedImage == null
              ? IconButton(
                  onPressed: _selectImageDialog,
                  icon: const Icon(
                    Icons.add,
                    size: 40,
                  ))
              : const Text(''),
          radius: 80,
        ),
        const SizedBox(
          height: 20,
        ),
        TextButton.icon(
          onPressed: _selectImageDialog,
          icon: const Icon(Icons.image),
          label: Text(
            pickedImage == null ? 'Add Image' : 'Change Image',
            style: const TextStyle(fontSize: 22),
          ),
        )
      ],
    );
  }
}
