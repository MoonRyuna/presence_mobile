import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presence_alpha/model/user_auth_model.dart';
import 'package:presence_alpha/payload/response/auth_response.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/screen/app.dart';
import 'package:presence_alpha/screen/hr/app.dart' as hrApp;
import 'package:presence_alpha/screen/login_screen.dart';
import 'package:presence_alpha/screen/offline_screen.dart';
import 'package:presence_alpha/service/auth_service.dart';
import 'package:presence_alpha/storage/app_storage.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  startSplashScreen() async {
    final Map<String, dynamic>? usrJson =
        await AppStorage.localStorage.getItem('usr');

    if (usrJson != null) {
      UserAuthModel userAuthModel = UserAuthModel.fromJson(usrJson);
      print("userAuthModel ${userAuthModel.toJsonString()}");
      String? username = userAuthModel.username;
      String? password = userAuthModel.password;
      String? imei = userAuthModel.imei;

      final requestData = {
        'username': username,
        'password': password,
        'imei': imei,
      };
      print(requestData);

      AuthResponse response = await AuthService().auth(requestData);
      if (!mounted) return;
      print(response.toPlain());

      if (response.status == true) {
        final tokenProvider = Provider.of<TokenProvider>(
          context,
          listen: false,
        );

        if (response.data!.token != null) {
          tokenProvider.setToken(response.data!.token as String);

          final accountType = response.data!.accountType;

          UserAuthModel userAuthModel = UserAuthModel(
            username: username,
            password: password,
            imei: imei,
          );

          String strUser = jsonEncode(userAuthModel.toJson());
          debugPrint(strUser);

          AppStorage.localStorage.setItem("usr", userAuthModel);

          Duration duration = const Duration(seconds: 5);
          return Timer(duration, () {
            if (accountType == "hrd" || accountType == "admin") {
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (_) {
                return const hrApp.App();
              }));
              return;
            } else if (accountType == "karyawan") {
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (_) {
                return const App();
              }));
              return;
            }

            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) {
              return const OfflineScreen();
            }));
          });
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
            return const OfflineScreen();
          }));
        }
      }

      if (response.message == "Connection timed out" ||
          response.message == "Connection Failed" ||
          response.message == "Failed to connect to server") {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
          return const OfflineScreen();
        }));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
          return const LoginScreen();
        }));
      }
    } else {
      Duration duration = const Duration(seconds: 5);
      return Timer(duration, () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
          return const LoginScreen();
        }));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                "assets/images/default-logo.png",
                width: 250.0,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "©SKRIPSI - ARI",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
