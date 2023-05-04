import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/payload/response/change_password_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/service/user_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:provider/provider.dart';

class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({super.key});

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _oldPasswordErrorText;
  String? _newPasswordErrorText;
  String? _confirmPasswordErrorText;

  bool _isObscureOldPassword = true;
  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void onUbahPassword() async {
    LoadingUtility.show(null);

    int errorCount = 0;

    UserModel? user = Provider.of<UserProvider>(context, listen: false).user;
    final token = Provider.of<TokenProvider>(
      context,
      listen: false,
    ).token;

    // if user is null, go to login screen
    if (user == null || user.id == null) {
      LoadingUtility.hide();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return;
    }

    // validate input
    setState(() {
      _oldPasswordErrorText = null;
      _newPasswordErrorText = null;
      _confirmPasswordErrorText = null;
    });

    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty) {
      errorCount++;
      setState(() {
        _oldPasswordErrorText = 'Password lama tidak boleh kosong';
      });
    }

    if (newPassword.isEmpty) {
      errorCount++;
      setState(() {
        _newPasswordErrorText = 'Password baru tidak boleh kosong';
      });
    }

    if (confirmPassword.isEmpty) {
      errorCount++;
      setState(() {
        _confirmPasswordErrorText = 'Konfirmasi password tidak boleh kosong';
      });
    }

    if (newPassword != confirmPassword) {
      errorCount++;
      setState(() {
        _confirmPasswordErrorText = 'Konfirmasi password tidak cocok';
      });
    }

    // if input is valid, change password
    if (errorCount != 0) {
      LoadingUtility.hide();
      return;
    }

    try {
      final requestData = {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      };

      ChangePasswordResponse response =
          await UserService().changePassword(requestData, user.id!, token);
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

      user = response.data;
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
        title: const Text("Ubah Password"),
        backgroundColor: ColorConstant.lightPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _oldPasswordController,
                      obscureText: _isObscureOldPassword,
                      decoration: InputDecoration(
                        labelText: 'Old password',
                        errorText: _oldPasswordErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscureOldPassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isObscureOldPassword = !_isObscureOldPassword;
                            });
                          },
                        ),
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
                      controller: _newPasswordController,
                      obscureText: _isObscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'New password',
                        errorText: _newPasswordErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscureNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscureNewPassword = !_isObscureNewPassword;
                            });
                          },
                        ),
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
                      controller: _confirmPasswordController,
                      obscureText: _isObscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm new password',
                        errorText: _confirmPasswordErrorText,
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isObscureConfirmPassword =
                                  !_isObscureConfirmPassword;
                            });
                          },
                        ),
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
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstant.lightPrimary,
                        minimumSize: const Size.fromHeight(50), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        onUbahPassword();
                      },
                      child: const Text(
                        'Ubah password',
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
