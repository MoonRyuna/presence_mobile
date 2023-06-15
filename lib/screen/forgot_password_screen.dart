import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/payload/response/base_response.dart';
import 'package:presence_alpha/screen/verify_otp_screen.dart';
import 'package:presence_alpha/service/auth_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  String? _emailErrorText;

  @override
  void initState() {
    super.initState();
    _emailController.text = '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> onForgotPassword() async {
    LoadingUtility.show(null);

    int errorCount = 0;

    setState(() {
      _emailErrorText = null;
    });

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailErrorText = "Email tidak boleh kosong";
      });
      errorCount++;
    }
    if (errorCount > 0) {
      LoadingUtility.hide();
      return;
    }

    try {
      final requestData = {
        "email": email,
      };

      BaseResponse response = await AuthService().forgotPassword(requestData);
      if (!mounted) return;

      if (response.status != true) {
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

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return VerifikasiOTPScreen(email: email);
      }));
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
        title: const Text("Forgot Password"),
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
                  children: <Widget>[
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
                        await onForgotPassword();
                      },
                      child: const Text(
                        'Send Email',
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
