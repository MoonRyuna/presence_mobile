import 'dart:async';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/payload/response/dashboard1_response.dart';
import 'package:presence_alpha/payload/response/presence_response.dart';
import 'package:presence_alpha/payload/response/today_check_response.dart';
import 'package:presence_alpha/provider/dashboard_provider.dart';
import 'package:presence_alpha/provider/date_provider.dart';
import 'package:presence_alpha/provider/office_config_provide.dart';
import 'package:presence_alpha/provider/properties_provider.dart';
import 'package:presence_alpha/provider/token_provider.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:presence_alpha/service/presence_service.dart';
import 'package:presence_alpha/service/user_service.dart';
import 'package:presence_alpha/utility/amessage_utility.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:presence_alpha/utility/common_utility.dart';
import 'package:presence_alpha/utility/loading_utility.dart';
import 'package:presence_alpha/utility/maps_utility.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PresenceActionScreen extends StatefulWidget {
  const PresenceActionScreen({super.key});

  @override
  State<PresenceActionScreen> createState() => _PresenceActionScreenState();
}

class _PresenceActionScreenState extends State<PresenceActionScreen> {
  late Timer _timer;
  late String distanceBetweenPoints = "-";
  late String address = "-";
  bool showDesc = false;
  bool showType = false;

  final TextEditingController _descController = TextEditingController();

  bool isKeyboardVisible = false;

  Position _currentPosition = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);
  late LocationPermission locationPermission;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const LatLng mapCenter = LatLng(-6.9147444, 107.6098106);
  final CameraPosition _kBandung =
      const CameraPosition(target: mapCenter, zoom: 11.0, tilt: 0, bearing: 0);

  CameraPosition _kOffice = const CameraPosition(
      target: LatLng(-7.011477899042147, 107.55234770202203), zoom: 17);

  CameraPosition _kCurrentPosition =
      const CameraPosition(target: LatLng(-6.9147444, 107.6098106), zoom: 17);

  late Set<Circle>? _circlesSet;
  double radiusGeofence = 20;

  Set<Circle> _buildCircles() {
    return {
      Circle(
        circleId: const CircleId("kantor_geofence"),
        center: _kOffice.target,
        radius: radiusGeofence,
        fillColor: Colors.redAccent.withOpacity(0.5),
        strokeWidth: 3,
        strokeColor: Colors.redAccent,
      )
    };
  }

  final List<String> _optionsType = ['WFO', 'WFH'];
  int _selectedType = 0;

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

  Future<void> getCurrentLocation() async {
    try {
      await checkLocationPermission();
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark placemark = placemarks[0];
      String formattedAddress =
          "${placemark.name}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}";

      setState(() {
        address = formattedAddress;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> calculateDistance() async {
    double distance = MapsUtility.calculateDistance(
        _kOffice.target.latitude,
        _kOffice.target.longitude,
        _kCurrentPosition.target.latitude,
        _kCurrentPosition.target.longitude);

    setState(() {
      distanceBetweenPoints = "${distance.round()} KM";
    });
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

    if (response.status == true) {
      if (response.data!.user != null) {
        up.user = response.data!.user;
        dp.izin = response.data!.izin;
        dp.lembur = response.data!.lembur;
        dp.presensi = response.data!.presensi;
        ocp.officeConfig = response.data!.officeConfig;

        double rGeonfence = response.data?.officeConfig?.radius as double;

        setState(() {
          radiusGeofence = rGeonfence;

          _circlesSet = _buildCircles();
        });

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
        setState(() {
          showType = false;
          showDesc = false;
        });

        if (response2.data?.alreadyCheckIn as bool == true) {
          setState(() {
            showDesc = true;
          });
        } else {
          setState(() {
            showType = true;
          });
        }

        if ((response2.data?.isHoliday as bool == true ||
                response2.data?.isWeekend as bool == true) &&
            response2.data?.haveOvertime as bool) {
          setState(() {
            showType = true;
          });
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

  Future<void> _goToOffice() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kOffice));
    _getLocation();
  }

  Future<void> _goToCurrenPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kCurrentPosition));
    _getLocation();
  }

  final PanelController _panelCtl = PanelController();

  void _togglePanel() {
    print("diklik");

    if (_panelCtl.isPanelOpen) {
      _panelCtl.close();
    } else {
      _panelCtl.open();
    }
  }

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
      _circlesSet = const <Circle>{};

      KeyboardVisibilityController keyboardCtl = KeyboardVisibilityController();

      keyboardCtl.onChange.listen((bool visible) {
        print("keyboard_status $visible");
        setState(() {
          isKeyboardVisible = visible;
        });
      });
    }
  }

  void onConfirmation() async {
    // print("WOW $radiusGeofence");
    // return;
    try {
      LoadingUtility.show("Sedang Proses");
      final tp = Provider.of<TokenProvider>(
        context,
        listen: false,
      );
      final pp = Provider.of<PropertiesProvider>(
        context,
        listen: false,
      );

      final up = Provider.of<UserProvider>(
        context,
        listen: false,
      );

      final dp = Provider.of<DateProvider>(
        context,
        listen: false,
      );

      final ocd = Provider.of<OfficeConfigProvider>(
        context,
        listen: false,
      );

      // 1 = Belum Check In
      // 2 = Belum Check Out
      // 3 = Sudah Check Out
      // 4 = Lembur Belum Dimulai
      // 5 = Lembur Belum Diakhiri
      // 6 = Lembur Telah Berakhir
      // 7 = Cuti/Sakit
      // 8 = Akhir Pekan
      // 9 = Hari Libur
      // 10 = Lembur Belum Dimulai
      // 11 = Lembur Belum Diakhiri
      // 12 = Lembur Telah Berakhir

      String infoType = CommonUtility.getInfoType(pp.todayCheckData);
      print("info type $infoType");

      String _address = address;
      String _latitude = _currentPosition.latitude.toString();
      String _longitude = _currentPosition.longitude.toString();
      String? _user_id = up.user?.id;
      String _desc = _descController.text.trim();
      String _type = _optionsType[_selectedType].toLowerCase();
      String _time = CalendarUtility.formatDB(dp.date);
      String token = tp.token;

      double geofence = radiusGeofence;
      print("geofence $geofence");

      double jarakM =
          double.parse((distanceBetweenPoints.replaceAll(" KM", ""))) * 1000;
      print("jarak dalam meter $jarakM");
      // return;

      if (_type == 'wfo') {
        // cek jarak kantor ke lokasi
        if (jarakM > geofence) {
          AmessageUtility.show(
            context,
            "Info",
            "Anda Diluar Kantor",
            TipType.WARN,
          );
          return;
        }
      }

      final _location = {
        'lat': _latitude,
        'lng': _longitude,
        'address': _address,
      };

      if (infoType == "1") {
        final requestData = {
          "user_id": _user_id,
          "check_in": _time,
          "position_check_in": _location,
          "type": _type
        };

        PresenceResponse response =
            await PresenceService().checkIn(requestData, token);
        if (!mounted) return;
        print(response.toJsonString());

        if (response.status == true) {
          AmessageUtility.show(
            context,
            "Berhasil",
            response.message!,
            TipType.COMPLETE,
          );
        } else {
          AmessageUtility.show(
            context,
            "Gagal",
            response.message!,
            TipType.ERROR,
          );
        }
      } else if (infoType == "2") {
        final requestData = {
          "user_id": _user_id,
          "check_out": _time,
          "position_check_out": _location,
          "description": _desc
        };

        PresenceResponse response =
            await PresenceService().checkOut(requestData, token);
        if (!mounted) return;
        print(response.toJsonString());

        if (response.status == true) {
          AmessageUtility.show(
            context,
            "Berhasil",
            response.message!,
            TipType.COMPLETE,
          );
        } else {
          AmessageUtility.show(
            context,
            "Gagal",
            response.message!,
            TipType.ERROR,
          );
        }
      } else if (infoType == "3") {
      } else if (infoType == "4") {
      } else if (infoType == "5") {
      } else if (infoType == "6") {
      } else if (infoType == "7") {
      } else if (infoType == "8") {
      } else if (infoType == "9") {
      } else if (infoType == "10") {
      } else if (infoType == "11") {
      } else if (infoType == "12") {}
    } catch (error) {
      print('Error: $error');

      AmessageUtility.show(context, "Gagal", error.toString(), TipType.ERROR);
    } finally {
      LoadingUtility.hide();
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.lightPrimary,
        title: const Text("Presensi"),
        centerTitle: true,
        elevation: 0, // menghilangkan shadow
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: <Widget>[
          SizedBox(
            height: (MediaQuery.of(context).size.height * 0.8),
            child: GoogleMap(
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              initialCameraPosition: _kBandung,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: {
                Marker(
                  markerId: const MarkerId('kantor'),
                  position: _kOffice.target,
                  infoWindow:
                      const InfoWindow(title: 'PT. Digital Amore Kriyanesia'),
                ),
                Marker(
                  markerId: const MarkerId('your_position'),
                  position: _kCurrentPosition.target,
                  infoWindow: const InfoWindow(title: 'Posisi Anda'),
                ),
              },
              circles: _circlesSet ?? const <Circle>{},
            ),
          ),
          Positioned(
            bottom: ((MediaQuery.of(context).size.height * 0.168) + 16),
            right: 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "btnToOffice",
                  onPressed: () {
                    _goToOffice();
                  },
                  child: CircleAvatar(
                    backgroundColor: ColorConstant.lightPrimary,
                    radius: 30,
                    child:
                        const Icon(Icons.business_center, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: "btnToCurrentPosition",
                  onPressed: () {
                    _goToCurrenPosition();
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 30,
                    child: Icon(Icons.gps_fixed, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SlidingUpPanel(
            controller: _panelCtl,
            maxHeight: (MediaQuery.of(context).size.height),
            minHeight: (MediaQuery.of(context).size.height * 0.168),
            boxShadow: const [],
            padding: const EdgeInsets.all(0.0),
            border: const Border(
              top: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            panel: SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    onTap: _togglePanel,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 15),
                        height: 10,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.fromLTRB(25, 20, 25, 20),
                              width:
                                  (MediaQuery.of(context).size.width - 60) / 2,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 238, 238, 238),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(13)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Jarak ke Kantor: ",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    distanceBetweenPoints,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.fromLTRB(25, 20, 25, 20),
                              width:
                                  (MediaQuery.of(context).size.width - 60) / 2,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 238, 238, 238),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(13)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Info: ",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Consumer<PropertiesProvider>(
                                    builder: (context, propertiesProvider, _) {
                                      String textToShow =
                                          CommonUtility.todayStatus(
                                              propertiesProvider
                                                  .todayCheckData);

                                      return Text(
                                        textToShow,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.all(10)),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lokasi Anda:',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                address,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Latitude & Longitude:',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_currentPosition.latitude}, ${_currentPosition.longitude}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Waktu Presensi:',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Consumer<DateProvider>(
                                builder: (context, dateModel, child) => Text(
                                  CalendarUtility.formatBasic(dateModel.date),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Presensi:',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Consumer<PropertiesProvider>(
                                builder: (context, propertiesProvider, _) {
                                  String textToShow =
                                      CommonUtility.presenceStatus(
                                          propertiesProvider.todayCheckData);

                                  return Text(
                                    textToShow,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              if (showType)
                                const Text(
                                  'Pilih Jenis Kehadiran',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              if (showType) const SizedBox(height: 8),
                              if (showType)
                                ToggleButtons(
                                  isSelected: List.generate(_optionsType.length,
                                      (index) => _selectedType == index),
                                  onPressed: (int index) {
                                    final up = Provider.of<UserProvider>(
                                      context,
                                      listen: false,
                                    );

                                    // print('Can WFH ${up.user?.canWfh}');
                                    if (_optionsType[index] == "WFH" &&
                                        up.user?.canWfh == false) {
                                      AmessageUtility.show(
                                        context,
                                        "Info",
                                        "Anda Belum Bisa WFH",
                                        TipType.WARN,
                                      );
                                    } else {
                                      setState(() {
                                        _selectedType = index;
                                      });
                                    }
                                  },
                                  children: _optionsType
                                      .map((value) => Text(value))
                                      .toList(),
                                ),
                              if (showType) const SizedBox(height: 16),
                              if (showDesc)
                                const Text(
                                  'Catatan Harian',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              if (showDesc) const SizedBox(height: 8),
                              if (showDesc)
                                TextField(
                                  maxLines: 4,
                                  controller: _descController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        width: 2,
                                        color: Color.fromRGBO(183, 28, 28, 1),
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              if (showDesc) const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorConstant.lightPrimary,
                                  minimumSize: const Size.fromHeight(50), // NEW
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                onPressed: onConfirmation,
                                child: const Text(
                                  'Konfirmasi',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isKeyboardVisible)
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      width: 50,
                      child: SizedBox(
                        height: (MediaQuery.of(context).size.height * 0.4),
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
