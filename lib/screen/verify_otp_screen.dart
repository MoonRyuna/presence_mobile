import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/payload/response/verify_otp_response.dart';
import 'package:presence_alpha/screen/new_password_screen.dart';
import 'package:presence_alpha/service/auth_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';

class VerifikasiOTPScreen extends StatefulWidget {
  const VerifikasiOTPScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifikasiOTPScreen> createState() => _VerifikasiOTPScreenState();
}

class _VerifikasiOTPScreenState extends State<VerifikasiOTPScreen> {
  final TextEditingController _otpController = TextEditingController();

  String? _otpErrorText;

  @override
  void initState() {
    super.initState();
    _otpController.text = '';
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> onVerifyOTP() async {
    LoadingUtility.show(null);

    int errorCount = 0;

    setState(() {
      _otpErrorText = null;
    });

    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      setState(() {
        _otpErrorText = "OTP tidak boleh kosong";
      });
      errorCount++;
    }
    if (errorCount > 0) {
      LoadingUtility.hide();
      return;
    }

    try {
      final requestData = {"email": widget.email, "otp": otp};

      VerifyOTPResponse response = await AuthService().verifyOTP(requestData);
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

      if (response.data!.userId == null) {
        LoadingUtility.hide();
        AmessageUtility.show(
          context,
          "Gagal",
          "User tidak ditemukan",
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

      String userId = response.data!.userId!;

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return NewPasswordScreen(id: userId);
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
        title: const Text("Verifikasi OTP"),
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
                      controller: _otpController,
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        errorText: _otpErrorText,
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
                        await onVerifyOTP();
                      },
                      child: const Text(
                        'Verifikasi',
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
