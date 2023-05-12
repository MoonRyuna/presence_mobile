import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_alpha/provider/dashboard_provider.dart';
import 'package:presence_alpha/provider/office_config_provide.dart';
import 'package:presence_alpha/provider/properties_provider.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/date_provider.dart';
import 'package:presence_alpha/provider/navbar_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/screen/splash_screen.dart';
import 'package:presence_alpha/storage/app_storage.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();
  await CalendarUtility.init();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<NavbarProvider>(create: (_) => NavbarProvider()),
    ChangeNotifierProvider<DateProvider>(create: (_) => DateProvider()),
    ChangeNotifierProvider<TokenProvider>(create: (_) => TokenProvider()),
    ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
    ChangeNotifierProvider<OfficeConfigProvider>(
        create: (_) => OfficeConfigProvider()),
    ChangeNotifierProvider<DashboardProvider>(
        create: (_) => DashboardProvider()),
    ChangeNotifierProvider<PropertiesProvider>(
        create: (_) => PropertiesProvider()),
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
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(),
      builder: EasyLoading.init(),
    );
  }
}
