import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_alpha/provider/date_provider.dart';
import 'package:presence_alpha/provider/navbar_provider.dart';
import 'package:presence_alpha/screen/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<NavbarProvider>(create: (_) => NavbarProvider()),
    ChangeNotifierProvider<DateProvider>(create: (_) => DateProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Presensi',
      theme: ThemeData(
        primarySwatch: Colors.red,
        textTheme: GoogleFonts.lexendDecaTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(),
      builder: EasyLoading.init(),
    );
  }
}
