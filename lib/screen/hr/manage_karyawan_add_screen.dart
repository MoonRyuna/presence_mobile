import 'dart:io';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/payload/response/create_user_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/service/user_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:provider/provider.dart';

class ManageKaryawanAddScreen extends StatefulWidget {
  const ManageKaryawanAddScreen({super.key});

  @override
  State<ManageKaryawanAddScreen> createState() =>
      _ManageKaryawanAddScreenState();
}

class _ManageKaryawanAddScreenState extends State<ManageKaryawanAddScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startedWorkAtController =
      TextEditingController();

  bool _canWfh = false;
  bool _deviceTracker = false;
  bool _isObscure = true;
  bool _isObscureConfirmation = true;
  String? _userId;
  File? _image;
  String? _accountType;
  DateTime? _selectedDate;

  String? _usernameErrorText;
  String? _emailErrorText;
  String? _phoneNumberErrorText;
  String? _nameErrorText;
  String? _addressErrorText;
  String? _descriptionErrorText;
  String? _accountTypeErrorText;
  String? _startedWorkAtErrorText;
  String? _passwordErrorText;
  String? _passwordConfirmationErrorText;

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
    final image = File(imagePicked!.path);
    setState(() {
      _image = image;
    });
  }

  Future<void> onTambahKaryawan() async {
    LoadingUtility.show(null);

    int errorCount = 0;

    UserModel? user = Provider.of<UserProvider>(context, listen: false).user;
    final token = Provider.of<TokenProvider>(context, listen: false).token;

    if (user == null || user.id == null) {
      if (!mounted) return;
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
      _accountTypeErrorText = null;
      _startedWorkAtErrorText = null;
      _passwordErrorText = null;
    });

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final accountType = _accountType?.trim() ?? "karyawan";
    final description = _descriptionController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirmation = _passwordConfirmationController.text.trim();
    final startedWorkAt = _startedWorkAtController.text.trim();
    final deviceTracker = _deviceTracker ?? false;

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

    if (password.isEmpty) {
      setState(() {
        _passwordErrorText = "Password tidak boleh kosong";
      });
      errorCount++;
    }

    if (passwordConfirmation.isEmpty) {
      setState(() {
        _passwordErrorText = "Konfirmasi password tidak boleh kosong";
      });
      errorCount++;
    }

    if (password != passwordConfirmation) {
      setState(() {
        _passwordErrorText = "Password dan konfirmasi password tidak sama";
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
        "password": password,
        "password_confirmation": passwordConfirmation,
        "email": email,
        "phone_number": phoneNumber,
        "account_type": accountType,
        "name": name,
        "address": address,
        "description": description,
        "started_work_at": startedWorkAt,
        "device_tracker": deviceTracker,
        "created_by": user.id,
        "can_wfh": _canWfh,
        "profile_picture": "images/default.png",
      };

      CreateUserResponse response =
          await UserService().createUser(requestData, token);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Karyawan"),
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
                              child: Consumer<UserProvider>(
                                builder: (context, userProvider, _) =>
                                    Image.network(
                                  userProvider.user?.profilePicture != null
                                      ? "${ApiConstant.publicUrl}/${userProvider.user?.profilePicture}"
                                      : "https://sbcf.fr/wp-content/uploads/2018/03/sbcf-default-avatar.png",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
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
                      controller: _passwordController,
                      obscureText: _isObscure ?? true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: _passwordErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ?? true
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: ColorConstant.lightPrimary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
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
                      controller: _passwordConfirmationController,
                      obscureText: _isObscureConfirmation ?? true,
                      decoration: InputDecoration(
                        labelText: 'Password Confirmation',
                        errorText: _passwordConfirmationErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscureConfirmation
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: ColorConstant.lightPrimary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscureConfirmation = !_isObscureConfirmation;
                            });
                          },
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
                        prefixIcon: const Icon(Icons.calendar_month),
                        errorStyle: const TextStyle(color: Colors.red),
                        labelStyle: const TextStyle(color: Colors.grey),
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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: ColorConstant.lightPrimary,
                          value: _deviceTracker,
                          onChanged: (value) {
                            setState(() {
                              _deviceTracker = value ?? false;
                            });
                          },
                        ),
                        const Expanded(child: Text("Device Tracker")),
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
                        await onTambahKaryawan();
                      },
                      child: const Text(
                        'Tambah Karyawan',
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
