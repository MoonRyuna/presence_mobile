// ignore_for_file: avoid_print

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/payload/response/auth_response.dart';
import 'package:presence_alpha/service/auth_service.dart';
import 'package:presence_alpha/utility/loading_utility.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? usernameError;
  String? passwordError;

  late String imei = "";
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    setImei();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> checkPermission() async {
    final status = await Permission.phone.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.phone.request();
      if (result.isDenied || result.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  Future<void> setImei() async {
    await checkPermission();
    String? gImei = await DeviceInformation.deviceIMEINumber;

    setState(() {
      imei = gImei;
    });
  }

  void onLogin(BuildContext ctx) async {
    LoadingUtility.show(null);

    int errorCount = 0;

    setState(() {
      usernameError = null;
      passwordError = null;
    });

    String? username = _usernameController.text.trim();
    String? password = _passwordController.text.trim();

    // ignore: avoid_print
    print('username: $username');
    print('password: $password');

    if (username.isEmpty) {
      setState(() {
        usernameError = "Wajib Diisi";
      });
      errorCount++;
    }

    if (password.isEmpty) {
      setState(() {
        passwordError = "Wajib Diisi";
      });
      errorCount++;
    }

    if (errorCount > 0) {
      LoadingUtility.hide();
      return;
    }

    Future.delayed(const Duration(seconds: 1), () async {
      try {
        final requestData = {
          'username': username,
          'password': password,
          'imei': imei,
        };
        print(requestData);

        AuthResponse response = await AuthService().auth(requestData);
        print(response.toString());

        String rTitle = "";
        String rMessage = "";
        TipType rType = TipType.COMPLETE;

        if (response.status == false) {
          rTitle = "Gagal";
          rMessage = response.message!;
          rType = TipType.ERROR;
        }

        Navigator.push(
          ctx,
          AwesomeMessageRoute(
            awesomeMessage: AwesomeHelper.createAwesome(
              title: rTitle,
              message: rMessage,
              tipType: rType,
            ),
          ),
        );
      } catch (error) {
        print('Error: $error');

        Navigator.push(
          ctx,
          AwesomeMessageRoute(
            awesomeMessage: AwesomeHelper.createAwesome(
              title: "Gagal",
              message: error.toString(),
              tipType: TipType.ERROR,
            ),
          ),
        );
      } finally {
        LoadingUtility.hide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(ColorConstant.lightPrimary);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 70, 25, 100),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sistem Presensi",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(3)),
                    const Text(
                      "PT. Digital Amore Kriyanesia",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(3)),
                    Text(
                      "IMEI: $imei",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Masuk",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        errorText: usernameError,
                        errorStyle: const TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color.fromRGBO(183, 28, 28, 1),
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: passwordError,
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstant.lightPrimary,
                        minimumSize: const Size.fromHeight(50), // NEW
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        onLogin(context);
                      },
                      child: const Text(
                        'Masuk',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.bottomLeft,
                      child: TextButton(
                        onPressed: () => {},
                        child: const Text(
                          'Lupa Password?',
                          style: TextStyle(fontSize: 16),
                        ),
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
