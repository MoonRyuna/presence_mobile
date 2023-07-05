// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:presence_alpha/constant/env_constant.dart';
// import 'package:presence_alpha/provider/dashboard_provider.dart';
// import 'package:presence_alpha/provider/date_provider.dart';
// import 'package:presence_alpha/provider/hr_navbar_provider.dart';
// import 'package:presence_alpha/provider/navbar_provider.dart';
// import 'package:presence_alpha/provider/office_config_provide.dart';
// import 'package:presence_alpha/provider/properties_provider.dart';
// import 'package:presence_alpha/provider/token_provider.dart';
// import 'package:presence_alpha/provider/user_provider.dart';
// import 'package:presence_alpha/screen/splash_screen.dart';
// import 'package:presence_alpha/service/supabase_service.dart';
// import 'package:presence_alpha/storage/app_storage.dart';
// import 'package:presence_alpha/utility/calendar_utility.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
// import 'package:workmanager/workmanager.dart';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     await CalendarUtility.init();
//     print("background service running: $task");

//     String? userId = inputData!['user_id'] ?? "";
//     String? date = inputData!['date'] ?? "";
//     String now = CalendarUtility.dateNow();
//     if (userId != null) {
//       print("user id $userId");
//       try {
//         print("ini now $now");
//         print("ini date task $date");
//         if (now == date) {
//           print("start excute task");
//           final currentPosition = await Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.high,
//           );

//           List<Placemark> placemarks = await placemarkFromCoordinates(
//             currentPosition.latitude,
//             currentPosition.longitude,
//           );

//           Placemark placemark = placemarks[0];
//           String address =
//               "${placemark.name}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}";

//           await SupabaseService().sendLocationToSupabase(
//             userId,
//             currentPosition.latitude.toString(),
//             currentPosition.longitude.toString(),
//             address,
//             CalendarUtility.dateNow3(),
//           );
//         } else {
//           print("stop task yesterday");
//           Workmanager().cancelAll();
//         }
//       } catch (e) {
//         print(e.toString());
//       }
//     } else {
//       print("user id null");
//     }
//     return Future.value(true);
//   });
// }

// void main2() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await AppStorage.init();
//   await CalendarUtility.init();
//   await Supabase.initialize(
//     url: EnvConstant.supabaseUrl,
//     anonKey: EnvConstant.supabaseKey,
//   );
//   Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

//   runApp(MultiProvider(providers: [
//     ChangeNotifierProvider<NavbarProvider>(create: (_) => NavbarProvider()),
//     ChangeNotifierProvider<HRNavbarProvider>(create: (_) => HRNavbarProvider()),
//     ChangeNotifierProvider<DateProvider>(create: (_) => DateProvider()),
//     ChangeNotifierProvider<TokenProvider>(create: (_) => TokenProvider()),
//     ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
//     ChangeNotifierProvider<OfficeConfigProvider>(
//         create: (_) => OfficeConfigProvider()),
//     ChangeNotifierProvider<DashboardProvider>(
//         create: (_) => DashboardProvider()),
//     ChangeNotifierProvider<PropertiesProvider>(
//         create: (_) => PropertiesProvider()),
//   ], child: const MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Sistem Presensi',
//       theme: ThemeData(
//         primarySwatch: Colors.red,
//         textTheme: GoogleFonts.firaSansTextTheme(
//           Theme.of(context).textTheme,
//         ),
//       ),
//       home: const SplashScreen(),
//       builder: EasyLoading.init(),
//     );
//   }
// }
