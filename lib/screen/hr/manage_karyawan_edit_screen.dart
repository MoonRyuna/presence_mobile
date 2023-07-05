import 'dart:io';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class ManageKaryawanEditScreen extends StatefulWidget {
  const ManageKaryawanEditScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<ManageKaryawanEditScreen> createState() =>
      _ManageKaryawanEditScreenState();
}

class _ManageKaryawanEditScreenState extends State<ManageKaryawanEditScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordChangeController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startedWorkAtController =
      TextEditingController();

  bool _canWfh = false;
  String? _userId;
  File? _image;
  String? _imagePath;
  String? _accountType;
  DateTime? _selectedDate;

  String? _usernameErrorText;
  String? _emailErrorText;
  String? _phoneNumberErrorText;
  String? _nameErrorText;
  String? _addressErrorText;
  String? _descriptionErrorText;
  String? _accountTypeErrorText;
  String? _passwordChangeErrorText;
  String? _startedWorkAtErrorText;

  @override
  void initState() {
    super.initState();
    _userId = widget.user.id ?? "";
    _usernameController.text = widget.user.username ?? '';
    _emailController.text = widget.user.email ?? '';
    _phoneNumberController.text = widget.user.phoneNumber ?? '';
    _nameController.text = widget.user.name ?? '';
    _addressController.text = widget.user.address ?? '';
    _descriptionController.text = widget.user.description ?? '';
    _startedWorkAtController.text = DateFormat("dd-MM-yyyy").format(
      DateTime.parse(widget.user.startedWorkAt ?? "").toLocal(),
    );

    _canWfh = widget.user.canWfh ?? false;
    _accountType = widget.user.accountType ?? '';
    _selectedDate = DateTime.parse(widget.user.startedWorkAt ?? "").toLocal();

    _imagePath = widget.user.profilePicture;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordChangeController.dispose();
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
      }
    } catch (error) {
      AmessageUtility.show(context, "Gagal", error.toString(), TipType.ERROR);
    } finally {
      LoadingUtility.hide();
    }
  }

  Future<void> onDeleteUser() async {
    LoadingUtility.show(null);

    final user = Provider.of<UserProvider>(context, listen: false).user;
    final token = Provider.of<TokenProvider>(context, listen: false).token;

    if (!mounted) return;
    if (user == null || user.id == null) {
      LoadingUtility.hide();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return;
    }

    try {
      final requestData = {
        "deleted_by": user.id,
      };

      final response =
          await UserService().deleteUser(requestData, _userId ?? "", token);
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

  Future<void> onResetImei() async {
    LoadingUtility.show(null);

    final token = Provider.of<TokenProvider>(context, listen: false).token;

    if (!mounted) return;
    try {
      final requestData = {
        "user_id": _userId!,
      };

      final response = await UserService().resetImei(requestData, token);
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

  Future<void> onUbahData() async {
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
      _passwordChangeErrorText = null;
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
    final passwordChange = _passwordChangeController.text.trim();
    final address = _addressController.text.trim();
    final accountType = _accountType?.trim() ?? "karyawan";
    final description = _descriptionController.text.trim();
    final startedWorkAt = _startedWorkAtController.text.trim();
    final deviceTracker = widget.user.deviceTracker ?? true;

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

    if (accountType.isEmpty) {
      setState(() {
        _accountTypeErrorText = "Tipe akun tidak boleh kosong";
      });
      errorCount++;
    }

    if (startedWorkAt.isEmpty) {
      setState(() {
        _startedWorkAtErrorText = "Tanggal mulai kerja tidak boleh kosong";
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
        "account_type": accountType,
        "name": name,
        "address": address,
        "description": description,
        "started_work_at": startedWorkAt,
        "device_tracker": deviceTracker,
        "updated_by": user.id,
        "can_wfh": _canWfh,
        "profile_picture": _imagePath,
      };

      // BUG: password change not working, check the api?
      if (passwordChange.isNotEmpty) {
        requestData["password"] = passwordChange;
      }

      UpdateProfileResponse response =
          await UserService().updateProfile(requestData, _userId ?? "", token);
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

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _startedWorkAtController.text =
            DateFormat('dd-MM-yyyy').format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          title: const Text("Edit Karyawan"),
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
                      height: 180.0,
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
                        controller: _passwordChangeController,
                        decoration: InputDecoration(
                          labelText: 'Change Password',
                          errorText: _passwordChangeErrorText,
                          helperText: "Kosongkan jika tidak ingin mengubah",
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
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Jabatan',
                          errorText: _accountTypeErrorText,
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
                        value: _accountType,
                        items: ApiConstant.role
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _accountType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _startedWorkAtController,
                        readOnly: true,
                        onTap: () async {
                          await _selectDate(context);
                        },
                        decoration: InputDecoration(
                          labelText: 'Started Work At',
                          errorText: _startedWorkAtErrorText,
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
                              setState(() {
                                _canWfh = value ?? false;
                              });
                            },
                          ),
                          const Expanded(child: Text("Can work from home")),
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
                          await onUbahData();
                        },
                        child: const Text(
                          'Update Data',
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
      ),
    );
  }
}

Widget profilePicture(String? imagePath) {
  if (imagePath == null) {
    return Image.asset(
      'assets/images/default.png',
      width: 100,
      height: 100,
      fit: BoxFit.cover,
    );
  }

  String profilePictureURI = "${ApiConstant.baseUrl}/$imagePath";

  return SizedBox(
    width: 100,
    height: 100,
    child: CachedNetworkImage(
      imageUrl: profilePictureURI,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/default.png',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
      fit: BoxFit.cover,
    ),
  );
}
