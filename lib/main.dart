import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_alpha/constant/env_constant.dart';
import 'package:presence_alpha/provider/dashboard_provider.dart';
import 'package:presence_alpha/provider/date_provider.dart';
import 'package:presence_alpha/provider/hr_navbar_provider.dart';
import 'package:presence_alpha/provider/navbar_provider.dart';
import 'package:presence_alpha/provider/office_config_provide.dart';
import 'package:presence_alpha/provider/properties_provider.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/screen/splash_screen.dart';
import 'package:presence_alpha/service/supabase_service.dart';
import 'package:presence_alpha/storage/app_storage.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'location_monitoring',
    'Location Monitoring',
    description: 'Service ini untuk mengirim lokasi anda.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'location_monitoring',
      initialNotificationTitle: 'Jangan Khawatir',
      initialNotificationContent: 'Lokasi Anda Sedang Dipantau',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 60), (timer) async {
    await CalendarUtility.init();
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          888,
          'COOL SERVICE',
          'Awesome ${CalendarUtility.dateNow3()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'location_monitoring',
              'Location Monitoring',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        service.setForegroundNotificationInfo(
          title: "Location Service",
          content: "Updated at ${CalendarUtility.dateNow3()}",
        );
      }
    }

    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    print('Background Service: ${DateTime.now()}');
    print('Device Info: ${device}');

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("user_id");
    String? date = preferences.getString("date");

    String now = CalendarUtility.dateNow();

    print("userId $userId");
    if (userId != null) {
      try {
        print("ini now $now");
        print("ini date task $date");
        if (now == date) {
          print("start excute task");
          final currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          List<Placemark> placemarks = await placemarkFromCoordinates(
            currentPosition.latitude,
            currentPosition.longitude,
          );

          Placemark placemark = placemarks[0];
          String address =
              "${placemark.name}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}";

          await SupabaseService().sendLocationToSupabase(
            userId,
            currentPosition.latitude.toString(),
            currentPosition.longitude.toString(),
            address,
            CalendarUtility.dateNow3(),
          );

          service.invoke(
            'update',
            {
              "current_date": DateTime.now().toIso8601String(),
              "device": device,
            },
          );
        } else {
          print("stop task yesterday");
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.remove('user_id');
          await preferences.remove('date');
          service.invoke('stopService');
        }
      } catch (e) {
        print(e.toString());
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.remove('user_id');
        await preferences.remove('date');
        service.invoke('stopService');
      }
    } else {
      print("user id null");
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove('user_id');
      await preferences.remove('date');
      service.invoke('stopService');
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();
  await CalendarUtility.init();
  await Supabase.initialize(
    url: EnvConstant.supabaseUrl,
    anonKey: EnvConstant.supabaseKey,
  );
  await initializeService();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<NavbarProvider>(create: (_) => NavbarProvider()),
    ChangeNotifierProvider<HRNavbarProvider>(create: (_) => HRNavbarProvider()),
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
        textTheme: GoogleFonts.firaSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(),
      builder: EasyLoading.init(),
    );
  }
}
