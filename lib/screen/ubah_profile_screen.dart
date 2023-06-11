import 'dart:io';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/payload/response/update_profile_response.dart';
import 'package:presence_alpha/payload/response/upload_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/service/upload_service.dart';
import 'package:presence_alpha/service/user_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:provider/provider.dart';

class UbahProfileScreen extends StatefulWidget {
  const UbahProfileScreen({super.key});

  @override
  State<UbahProfileScreen> createState() => _UbahProfileScreenState();
}

class _UbahProfileScreenState extends State<UbahProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _canWfh = false;

  String? _usernameErrorText;
  String? _emailErrorText;
  String? _phoneNumberErrorText;
  String? _nameErrorText;
  String? _addressErrorText;
  String? _descriptionErrorText;
  File? _image;
  String? _imagePath;
  String? _accountType;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _usernameController.text = user.username ?? '';
      _emailController.text = user.email ?? '';
      _phoneNumberController.text = user.phoneNumber ?? '';
      _nameController.text = user.name ?? '';
      _addressController.text = user.address ?? '';
      _descriptionController.text = user.description ?? '';
      _canWfh = user.canWfh ?? false;
      _accountType = user.accountType ?? '';
      _imagePath = user.profilePicture;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future pickImage() async {
    final ImagePicker imagePicker = ImagePicker();

    final XFile? imagePicked =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (imagePicked != null) {
      setState(() {
        _image = File(imagePicked.path);
      });
    }

    if (_image?.path != null) {
      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    LoadingUtility.show("Melakukan Upload");
    try {
      final tp = Provider.of<TokenProvider>(
        context,
        listen: false,
      );
      String token = tp.token;

      if (_image?.path == null) {
        AmessageUtility.show(
          context,
          "Info",
          "Tidak memilih file",
          TipType.INFO,
        );
        return;
      }

      final mimeType = MediaType('image', 'jpeg');
      MultipartFile file = await MultipartFile.fromPath(
        'image',
        _image!.path,
        contentType: mimeType,
      );

      UploadResponse response = await UploadService().image(file, token);
      if (!mounted) return;

      if (response.data?.path == null) {
        String msg = response.message ?? "melakukan upload ke server";

        AmessageUtility.show(
          context,
          "Gagal",
          msg,
          TipType.ERROR,
        );

        setState(() {
          _image = null;
          _imagePath = null;
        });
        return;
      } else {
        if (response.data?.path != null) {
          setState(() {
            _imagePath = response.data!.path;
          });
        }

        print("file upload $_imagePath");
      }
    } catch (error) {
      print('Error: $error');

      AmessageUtility.show(context, "Gagal", error.toString(), TipType.ERROR);
    } finally {
      LoadingUtility.hide();
    }
  }

  Future<void> onUbahProfile() async {
    LoadingUtility.show(null);

    int errorCount = 0;

    UserModel? user = Provider.of<UserProvider>(context, listen: false).user;
    final token = Provider.of<TokenProvider>(context, listen: false).token;

    if (user == null || user.id == null) {
      LoadingUtility.hide();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return;
    }

    setState(() {
      _usernameErrorText = null;
      _emailErrorText = null;
      _phoneNumberErrorText = null;
      _nameErrorText = null;
      _addressErrorText = null;
      _descriptionErrorText = null;
    });

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final description = _descriptionController.text.trim();

    if (username.isEmpty) {
      setState(() {
        _usernameErrorText = "Username tidak boleh kosong";
      });
      errorCount++;
    }

    if (email.isEmpty) {
      setState(() {
        _emailErrorText = "Email tidak boleh kosong";
      });
      errorCount++;
    }

    if (phoneNumber.isEmpty) {
      setState(() {
        _phoneNumberErrorText = "Nomor telepon tidak boleh kosong";
      });
      errorCount++;
    }

    if (name.isEmpty) {
      setState(() {
        _nameErrorText = "Nama tidak boleh kosong";
      });
      errorCount++;
    }

    if (address.isEmpty) {
      setState(() {
        _addressErrorText = "Alamat tidak boleh kosong";
      });
      errorCount++;
    }

    if (description.isEmpty) {
      setState(() {
        _descriptionErrorText = "Deskripsi tidak boleh kosong";
      });
      errorCount++;
    }

    if (errorCount > 0) {
      LoadingUtility.hide();
      return;
    }

    try {
      final requestData = {
        "username": username,
        "email": email,
        "phone_number": phoneNumber,
        "account_type": user.accountType,
        "name": name,
        "address": address,
        "description": description,
        "started_work_at": user.startedWorkAt,
        "device_tracker": user.deviceTracker,
        "updated_by": user.id,
        "can_wfh": _canWfh,
        "profile_picture": _imagePath,
      };

      UpdateProfileResponse response =
          await UserService().updateProfile(requestData, user.id!, token);
      if (!mounted) return;

      if (response.status != true || response.data == null) {
        LoadingUtility.hide();
        AmessageUtility.show(
          context,
          "Gagal",
          response.message!,
          TipType.ERROR,
        );
        return;
      }

      LoadingUtility.hide();
      AmessageUtility.show(
        context,
        "Berhasil",
        response.message!,
        TipType.COMPLETE,
      );

      UserProvider? up = Provider.of<UserProvider>(context, listen: false);

      up.user = response.data;
    } catch (e) {
      LoadingUtility.hide();
      AmessageUtility.show(
        context,
        "Gagal",
        e.toString(),
        TipType.ERROR,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Profile"),
        backgroundColor: ColorConstant.lightPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  SizedBox(
                    height: 210.0,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              await pickImage();
                            },
                            child: ClipOval(
                              child: _imagePath != null
                                  ? profilePicture(_imagePath)
                                  : Consumer<UserProvider>(
                                      builder: (context, userProvider, _) =>
                                          profilePicture(
                                        userProvider.user?.profilePicture,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          profileInfo(context),
                          const SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        errorText: _usernameErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: ColorConstant.lightPrimary,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: _emailErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: ColorConstant.lightPrimary,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone number',
                        errorText: _phoneNumberErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: ColorConstant.lightPrimary,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        errorText: _nameErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: ColorConstant.lightPrimary,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        errorText: _addressErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: ColorConstant.lightPrimary,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        errorText: _descriptionErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: ColorConstant.lightPrimary,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: ColorConstant.lightPrimary,
                          value: _canWfh,
                          onChanged: (value) {
                            if (_accountType == "admin" ||
                                _accountType == "hrd") {
                              setState(() {
                                _canWfh = value ?? false;
                              });
                            }
                          },
                        ),
                        const Text("Can work from home"),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstant.lightPrimary,
                        minimumSize: const Size.fromHeight(50), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async {
                        await onUbahProfile();
                      },
                      child: const Text(
                        'Ubah profile',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget profileInfo(BuildContext context) {
  const locale = Locale('id', 'ID');

  return Consumer<UserProvider>(
    builder: (context, userProvider, _) => Text(
      (userProvider.user?.accountType ?? "N/A") +
          (userProvider.user?.startedWorkAt != null
              ? " sejak ${DateFormat('d MMMM y', locale.toString()).format(
                  DateTime.parse(userProvider.user?.startedWorkAt ?? '')
                      .toLocal(),
                )}"
              : ""),
      style: TextStyle(
        fontSize: 14.0,
        color: Colors.grey.shade400,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}

Widget profilePicture(String? imagePath) {
  if (imagePath == null) {
    return Image.asset(
      'assets/images/default.png',
      width: 100,
    );
  }

  String profilePictureURI = "${ApiConstant.baseUrl}/$imagePath";

  return Image.network(
    profilePictureURI,
    width: 100,
    height: 100,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Image.asset(
        'assets/images/default.png',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    },
  );
}
