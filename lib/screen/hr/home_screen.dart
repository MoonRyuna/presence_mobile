import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:presence_alpha/screen/absence_screen.dart';
import 'package:presence_alpha/screen/overtime_screen.dart';
import 'package:presence_alpha/screen/presence_screen.dart';
import 'package:presence_alpha/service/user_service.dart';
import 'package:presence_alpha/storage/app_storage.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:presence_alpha/utility/common_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:presence_alpha/utility/maps_utility.dart';
import 'package:presence_alpha/widget/bs_alert.dart';
import 'package:presence_alpha/widget/dashboard_box.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  late LocationPermission locationPermission;

  void getLocation() async {}

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
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
    _timer.cancel();
    super.dispose();
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
      }
    }

    TodayCheckResponse response2 =
        await UserService().todayCheck(requestData, token);

    if (response2.status == true) {
      if (response2.data != null) {
        pp.todayCheckData = response2.data;
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

  Future<void> _getLocation() async {
    await loadData();
    await checkLocationPermission();
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
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
          width: (MediaQuery.of(context).size.width - 60) / 2,
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
          width: (MediaQuery.of(context).size.width - 60) / 2,
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
          Icons.fingerprint,
          () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PresenceScreen()),
            )
          },
        ),
        gridButton(
          "Izin",
          Icons.assignment,
          () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AbsenceScreen()),
            )
          },
        ),
        gridButton(
          "Lembur",
          Icons.timer,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OvertimeScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget gridButton(String text, IconData icon, VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: const Color.fromRGBO(189, 189, 189, 1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 35, color: Colors.grey[800]),
            const SizedBox(height: 6),
            Text(text, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget profilePicture(String? imagePath) {
    print("ini woy $imagePath");
    if (imagePath == null) {
      return Image.asset(
        'assets/images/default.png',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }

    String profilePictureURI = "${ApiConstant.baseUrl}/$imagePath";

    return Image.network(
      profilePictureURI,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/default.png',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      },
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
                    const Padding(padding: EdgeInsets.all(10)),
                    Consumer<UserProvider>(builder: (context, up, child) {
                      return boxInfo(up.user?.accountType != null
                          ? up.user!.accountType!.toString().toUpperCase()
                          : "-");
                    }),
                    const SizedBox(height: 20),
                    Consumer<PropertiesProvider>(builder: (context, pp, child) {
                      if (pp.todayCheckData?.isWorkday == true) {
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
                    const Padding(padding: EdgeInsets.all(10)),
                    Consumer<PropertiesProvider>(builder: (context, pp, child) {
                      return Column(
                        children: [
                          DashboardBox(
                            color: Colors.orange,
                            icon: Icons.supervisor_account_rounded,
                            title: 'Jumlah Karyawan Terdaftar',
                            value: pp.todayCheckData?.countKaryawanActive
                                    .toString() ??
                                "0",
                          ),
                          const SizedBox(height: 20),
                          DashboardBox(
                            color: Colors.red,
                            icon: Icons.delete,
                            title: 'Jumlah Karyawan Terhapus',
                            value: pp.todayCheckData?.countKaryawanInactive
                                    .toString() ??
                                "0",
                          ),
                          const SizedBox(height: 20),
                          DashboardBox(
                            color: Colors.purple,
                            icon: Icons.access_time,
                            title: 'Lembur Belum Disetujui',
                            value: pp.todayCheckData?.submissionPendingOvertime
                                    .toString() ??
                                "0",
                          ),
                          const SizedBox(height: 20),
                          DashboardBox(
                            color: Colors.purple,
                            icon: Icons.assignment,
                            title: 'Izin Belum Disetujui',
                            value: pp.todayCheckData?.submissionPendingAbsence
                                    .toString() ??
                                "0",
                          ),
                        ],
                      );
                    }),
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
