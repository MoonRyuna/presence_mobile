import 'dart:async';

import 'package:background_location/background_location.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/payload/response/dashboard1_response.dart';
import 'package:presence_alpha/payload/response/today_check_response.dart';
import 'package:presence_alpha/provider/dashboard_provider.dart';
import 'package:presence_alpha/provider/date_provider.dart';
import 'package:presence_alpha/provider/office_config_provide.dart';
import 'package:presence_alpha/provider/properties_provider.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/repository/platform_repository.dart';
import 'package:presence_alpha/screen/absence_screen.dart';
import 'package:presence_alpha/screen/overtime_screen.dart';
import 'package:presence_alpha/screen/presence_screen.dart';
import 'package:presence_alpha/screen/rekap_karyawan_screen.dart';
import 'package:presence_alpha/service/supabase_service.dart';
import 'package:presence_alpha/service/user_service.dart';
import 'package:presence_alpha/storage/app_storage.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:presence_alpha/utility/common_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:presence_alpha/utility/maps_utility.dart';
import 'package:presence_alpha/utility/notification_utility.dart';
import 'package:presence_alpha/widget/bs_alert.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = PlatformRepository();
  String text = "Start Service";
  late Timer _timer;

  late String distanceBetweenPoints = "-";
  late Position _currentPosition;
  late LocationPermission locationPermission;

  CameraPosition _kOffice = const CameraPosition(
      target: LatLng(-7.011477899042147, 107.55234770202203), zoom: 17);

  CameraPosition _kCurrentPosition =
      const CameraPosition(target: LatLng(-6.9147444, 107.6098106), zoom: 17);

  void getLocation() async {}

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<bool> isMockLocationEnabled() async {
    bool result;
    try {
      final bool isLocationMocked = await _repository.isMockLocationEnabled();
      result = isLocationMocked;
    } on PlatformException catch (e) {
      // Handle platform exception
      result = false;
      print(e.message);
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        Provider.of<DateProvider>(context, listen: false)
            .setDate(DateTime.now());
      });
      _getLocation();
    }
  }

  @override
  void dispose() {
    // TrustLocation.stop();
    _timer.cancel();
    super.dispose();
  }

  void startTracking() async {
    print("startTracking");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? date = preferences.getString("date");
    String? userId = preferences.getString("userId");
    String now = CalendarUtility.dateNow();

    print("ini now $now");
    print("ini date task $date");
    print("ini user id $userId");

    if (now == date && userId != null) {
      await BackgroundLocation.setAndroidNotification(
        title: 'Jangan Khawatir',
        message: 'Posisi sedang dipantau',
        icon: '@mipmap/ic_launcher',
      );

      await BackgroundLocation.startLocationService(distanceFilter: 20);
      BackgroundLocation.getLocationUpdates((location) async {
        String latitude = location.latitude.toString();
        String longitude = location.longitude.toString();

        print("update location: ");
        print("latitude: $latitude");
        print("longitude: $longitude");

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

        print("address: $address");

        await SupabaseService().sendLocationToSupabase(
          userId,
          currentPosition.latitude.toString(),
          currentPosition.longitude.toString(),
          address,
          CalendarUtility.dateNow3(),
        );
      });
    } else {
      stopTracking();
    }
  }

  void stopTracking() async {
    print("stop background service");

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('user_id');
    await preferences.remove('date');

    BackgroundLocation.stopLocationService();
  }

  Future<void> loadData() async {
    LoadingUtility.show("Pembaruan Data");

    final tp = Provider.of<TokenProvider>(
      context,
      listen: false,
    );
    final up = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final dp = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final ocp = Provider.of<OfficeConfigProvider>(
      context,
      listen: false,
    );

    final pp = Provider.of<PropertiesProvider>(
      context,
      listen: false,
    );



    final String now = CalendarUtility.dateNow();
    final String token = tp.token;
    final requestData = {
      'date': now,
    };

    Dashboard1Response response =
        await UserService().dashboard1(requestData, token);

    print("RES1 ${response.message}");
    if (response.status == true) {
      if (response.data != null) {
        up.user = response.data!.user;
        dp.izin = response.data!.izin;
        dp.lembur = response.data!.lembur;
        dp.presensi = response.data!.presensi;
        ocp.officeConfig = response.data!.officeConfig;



        await AppStorage.localStorage.setItem(
          "ocp",
          response.data!.officeConfig,
        );

        double latOffice = -7.01147799042147;
        double lngOffice = 107.55234770202203;

        if (response.data?.officeConfig?.latitude != null) {
          latOffice = response.data?.officeConfig?.latitude as double;
        }
        if (response.data?.officeConfig?.longitude != null) {
          lngOffice = response.data?.officeConfig?.longitude as double;
        }

        setState(() {
          _kOffice = CameraPosition(
            target: LatLng(latOffice, lngOffice),
            zoom: 17,
          );
        });
      }
    }

    TodayCheckResponse response2 =
        await UserService().todayCheck(requestData, token);

    if (response2.status == true) {
      if (response2.data != null) {
        pp.todayCheckData = response2.data;

        if (pp.todayCheckData?.alreadyCheckIn == true) {
          startTracking();
        }

        if (pp.todayCheckData?.alreadyCheckOut == true) {
          stopTracking();
        }

        //set notif
        String? workSchedule = ocp.officeConfig!.workSchedule;

        if(workSchedule != null){
          // Memisahkan waktu mulai dan waktu selesai dari workSchedule
          List<String> scheduleParts = workSchedule.split(" - ");
          String startTime = scheduleParts[0]; // Misalnya: "08:00"
          String endTime = scheduleParts[1]; // Misalnya: "17:00"
          // String endTime = "12:30";

          // Memecah waktu mulai dan waktu selesai menjadi jam dan menit
          List<String> startParts = startTime.split(":");
          List<String> endParts = endTime.split(":");
          int startHour = int.parse(startParts[0]);
          int startMinute = int.parse(startParts[1]);
          int endHour = int.parse(endParts[0]);
          int endMinute = int.parse(endParts[1]);

          //set id
          String uId = up.user!.id as String;
          String idIn = "91$uId";
          String idOut = "92$uId";

          // Jadwalkan notifikasi untuk waktu mulai
          NotificationUtility notificationUtility = NotificationUtility();
          notificationUtility.initializeNotification();
          notificationUtility.cancelAll();


          notificationUtility.scheduledNotification(
              hour: startHour,
              minutes: startMinute,
              id: int.parse(idIn),
              title: "Hai Semuanya️",
              message: "Jangan lupa check-in"
          );

          // Jadwalkan notifikasi untuk waktu selesai
          notificationUtility.scheduledNotification(
              hour: endHour,
              minutes: endMinute,
              id: int.parse(idOut),
              title: "Hai Semuanya️",
              message: "Jangan lupa check-out"
          );
        }
      }
    }

    LoadingUtility.hide();
  }

  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      await checkLocationPermission();
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      bool mockLocationEnabled = await isMockLocationEnabled();
      print("mockLocation $mockLocationEnabled");
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> _getLocation() async {
    await loadData();
    await getCurrentLocation();
    setState(() {
      _kCurrentPosition = CameraPosition(
        target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        zoom: 17,
      );
    });
    calculateDistance();
  }

  Future<void> calculateDistance() async {
    double distance = MapsUtility.calculateDistance(
      _kOffice.target.latitude,
      _kOffice.target.longitude,
      _kCurrentPosition.target.latitude,
      _kCurrentPosition.target.longitude,
    );

    String dstring;
    if (distance >= 1) {
      dstring = "${distance.round()} KM";
    } else {
      dstring = "${(distance * 1000).round()} M";
    }
    setState(() {
      distanceBetweenPoints = dstring;
    });
  }

  Widget userInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Consumer<UserProvider>(
            builder: (context, userProvider, _) => profilePicture(
              userProvider.user?.profilePicture,
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.only(left: 10)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const Padding(padding: EdgeInsets.all(3)),
            Consumer<UserProvider>(
              builder: (context, userProvider, _) => Text(
                userProvider.user?.name ?? "N?A",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: ColorConstant.lightPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget boxInfo(String accountType) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            accountType,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const Padding(padding: EdgeInsets.all(2)),
          Consumer<DateProvider>(
            builder: (context, dateModel, child) => Text(
              CalendarUtility.formatBasic(dateModel.date),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromARGB(100, 110, 110, 110),
              borderRadius: BorderRadius.all(Radius.circular(13)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      "check-in",
                      style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.white),
                    ),
                    Consumer<DashboardProvider>(
                      builder: (context, dashboardProvider, child) => Text(
                        dashboardProvider.presensi?.checkIn != null
                            ? DateFormat('HH:mm:ss').format(
                                DateFormat("yyyy-MM-dd HH:mm:ss").parse(
                                    dashboardProvider.presensi!.checkIn!),
                              )
                            : "-",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white,
                  alignment: Alignment.topCenter,
                ),
                Column(
                  children: [
                    const Text(
                      "check-out",
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                    Consumer<DashboardProvider>(
                      builder: (context, dashboardProvider, child) => Text(
                        dashboardProvider.presensi?.checkOut != null
                            ? DateFormat('HH:mm:ss').format(
                                DateFormat("yyyy-MM-dd HH:mm:ss").parse(
                                    dashboardProvider.presensi!.checkOut!),
                              )
                            : "-",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget distanceLocation(String infoDistance) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
          width: (MediaQuery.of(context).size.width >= 60)
              ? (MediaQuery.of(context).size.width - 60) / 2
              : 0,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 238, 238, 238),
            borderRadius: BorderRadius.all(Radius.circular(13)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Jarak ke Kantor: ",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              Text(
                infoDistance,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
          width: (MediaQuery.of(context).size.width >= 60)
              ? (MediaQuery.of(context).size.width - 60) / 2
              : 0,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 238, 238, 238),
            borderRadius: BorderRadius.all(Radius.circular(13)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Info: ",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              Consumer<PropertiesProvider>(
                builder: (context, propertiesProvider, _) {
                  String textToShow = CommonUtility.todayStatus(
                      propertiesProvider.todayCheckData);

                  return Text(
                    textToShow,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget boxButton() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        gridButton(
          "Kehadiran",
          Icons.work_outline,
          () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PresenceScreen()),
            )
          },
        ),
        gridButton(
          "Izin",
          Icons.assignment_outlined,
          () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AbsenceScreen()),
            )
          },
        ),
        gridButton(
          "Lembur",
          Icons.access_time,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OvertimeScreen()),
            );
          },
        ),
        Consumer<UserProvider>(
          builder: (context, userProvider, _) => gridButton(
            "Rekapan",
            Icons.data_thresholding_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        RekapKaryawanScreen(id: userProvider.user!.id!)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget gridButton(String text, IconData icon, VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        decoration: BoxDecoration(
          // color: Colors.red.shade900.withOpacity(0.8),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: const Color.fromRGBO(189, 189, 189, 1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Icon(icon, size: 28, color: Colors.white),
            Icon(icon, size: 28, color: Colors.grey.shade700),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                // fontWeight: FontWeight.bold,
                // color: Colors.white,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: <Widget>[
                    const Padding(padding: EdgeInsets.all(5)),
                    userInfo(),
                    const Padding(padding: EdgeInsets.all(15)),
                    boxInfo("Karyawan"),
                    const Padding(padding: EdgeInsets.all(10)),
                    distanceLocation(distanceBetweenPoints),
                    const SizedBox(height: 20),
                    Consumer<PropertiesProvider>(builder: (context, pp, child) {
                      if (pp.todayCheckData?.isWorkday == true &&
                          pp.todayCheckData?.isAbsence == false) {
                        return Consumer<OfficeConfigProvider>(
                          builder: (context, ofc, _) => BsAlert(
                            icon: Icons.info_outline,
                            title: 'Jam Kerja',
                            message: ofc.officeConfig != null &&
                                    ofc.officeConfig!.workSchedule != null
                                ? ofc.officeConfig!.workSchedule!
                                : "-",
                            type: BsAlertType.info,
                          ),
                        );
                      } else if (pp.todayCheckData?.isAbsence == true) {
                        return const BsAlert(
                          icon: Icons.info_outline,
                          title: 'Anda Sedang Cuti',
                          message: "Gunakan Waktu Sebaik Mungkin",
                          type: BsAlertType.info,
                        );
                      } else if (pp.todayCheckData?.isWeekend == true) {
                        return const BsAlert(
                          icon: Icons.info_outline,
                          title: 'Akhir Pekan',
                          message: "Selamat Menikmati Akhir Pekan",
                          type: BsAlertType.info,
                        );
                      } else if (pp.todayCheckData?.isHoliday == true) {
                        return BsAlert(
                          icon: Icons.info_outline,
                          title: 'Hari Libur',
                          message: pp.todayCheckData != null &&
                                  pp.todayCheckData!.holidayTitle != null
                              ? pp.todayCheckData!.holidayTitle!.join(", ")
                              : "-",
                          type: BsAlertType.info,
                        );
                      }
                      return Container();
                    }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Menu",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(8)),
                    boxButton(),
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

Widget profilePicture(String? imagePath) {
  if (imagePath == null) {
    return Image.asset(
      'assets/images/default.png',
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  String profilePictureURI = "${ApiConstant.baseUrl}/$imagePath";

  return SizedBox(
    width: 50,
    height: 50,
    child: CachedNetworkImage(
      imageUrl: profilePictureURI,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/default.png',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      fit: BoxFit.cover,
    ),
  );
}
