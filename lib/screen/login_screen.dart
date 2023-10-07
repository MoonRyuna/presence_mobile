// ignore_for_file: avoid_print

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// ignore: import_of_legacy_library_into_null_safe
// import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/office_config_model.dart';
import 'package:presence_alpha/model/user_auth_model.dart';
import 'package:presence_alpha/payload/response/auth_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/screen/app.dart';
import 'package:presence_alpha/screen/forgot_password_screen.dart';
import 'package:presence_alpha/screen/hr/app.dart' as hr_app;
import 'package:presence_alpha/service/auth_service.dart';
import 'package:presence_alpha/storage/app_storage.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:provider/provider.dart';

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

  late String deviceUnique = "";
  bool _isObscure = true;

  String? officeName;

  @override
  void initState() {
    super.initState();
    setDeviceUnique();
    getConfig();
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

  Future<void> setDeviceUnique() async {
    await checkPermission();
    String? gDeviceUnique = await DeviceInformation.deviceIMEINumber;

    setState(() {
      deviceUnique = gDeviceUnique;
    });
  }

  Future<void> getConfig() async {
    final Map<String, dynamic>? officeJson =
        await AppStorage.localStorage.getItem('ocp');

    if (officeJson != null) {
      OfficeConfigModel ocp = OfficeConfigModel.fromJson(officeJson);
      if (ocp.name != null) {
        setState(() {
          officeName = ocp.name;
        });
      }
    }
  }

  void onLogin() async {
    LoadingUtility.show(null);

    int errorCount = 0;

    setState(() {
      usernameError = null;
      passwordError = null;
    });

    String? username = _usernameController.text.trim();
    String? password = _passwordController.text.trim();

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
          'device_unique': deviceUnique,
        };
        print(requestData);

        AuthResponse response = await AuthService().auth(requestData);
        if (!mounted) return;
        print(response.toPlain());

        if (response.status == false) {
          AmessageUtility.show(
            context,
            "Gagal",
            response.message!,
            TipType.ERROR,
          );
        } else {
          final tokenProvider = Provider.of<TokenProvider>(
            context,
            listen: false,
          );

          final accountType = response.data!.accountType;

          if (response.data!.token != null) {
            tokenProvider.setToken(response.data!.token as String);

            UserAuthModel userAuthModel = UserAuthModel(
              username: username,
              password: password,
              deviceUnique: deviceUnique,
            );

            await AppStorage.localStorage.setItem("usr", userAuthModel);

            final usr = await AppStorage.localStorage.getItem("usr");
            print("WOW $usr");
            if (!mounted) return;

            AmessageUtility.show(
              context,
              "Berhasil",
              "melakukan login",
              TipType.COMPLETE,
            );

            print("accountType $accountType");

            //stop tracking
            stopTracking();
            if (accountType == "hrd" || accountType == "admin") {
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (_) {
                return const hr_app.App();
              }));
              return;
            } else if (accountType == "karyawan") {
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (_) {
                return const App();
              }));
              return;
            }

            AmessageUtility.show(
              context,
              "Gagal",
              "User group tidak diketahui",
              TipType.ERROR,
            );
          } else {
            AmessageUtility.show(
              context,
              "Gagal",
              "tidak dapat response dari server",
              TipType.ERROR,
            );
          }
        }
      } catch (error) {
        print('Error: $error');

        AmessageUtility.show(context, "Gagal", error.toString(), TipType.ERROR);
      } finally {
        LoadingUtility.hide();
      }
    });
  }

  void stopTracking() async {
    print("stop all task");
    // Workmanager().cancelAll();
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (isRunning) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove('user_id');
      await preferences.remove('date');
      service.invoke("stopService");
    }
  }

  @override
  Widget build(BuildContext context) {
    // FlutterStatusbarcolor.setStatusBarColor(ColorConstant.lightPrimary);

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
                    Text(
                      (officeName ?? "PT. Digital Amore Kriyanesia"),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(3)),
                    Text(
                      "DEVICE UNIQUE: $deviceUnique",
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
                        onLogin();
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
                        onPressed: () => {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          )
                        },
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
