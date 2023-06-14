import 'dart:async';

import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:presence_alpha/widget/bs_alert.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:ui' as ui;

import 'package:workmanager/workmanager.dart';

class PresenceActionScreen extends StatefulWidget {
  const PresenceActionScreen({super.key});

  @override
  State<PresenceActionScreen> createState() => _PresenceActionScreenState();
}

class _PresenceActionScreenState extends State<PresenceActionScreen> {
  late Timer _timer;
  late String distanceBetweenPoints = "-";
  int distanceInMeter = 0;
  late String address = "-";
  bool showDesc = false;
  bool showType = false;
  bool showBtn = false;

  final TextEditingController _descController = TextEditingController();

  bool isKeyboardVisible = false;

  final Set<Marker> _markers = {};

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
    final ocp = Provider.of<OfficeConfigProvider>(
      context,
      listen: false,
    );

    await loadData();
    await getCurrentLocation();
    final userMarker = await _createMarkerImage('user-marker.png', 150, 150);
    final officeMarker =
        await _createMarkerImage('office-marker.png', 150, 150);

    setState(() {
      _kCurrentPosition = CameraPosition(
        target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        zoom: 17,
      );

      _markers.clear();

      _markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position:
              LatLng(_currentPosition.latitude, _currentPosition.longitude),
          icon: userMarker ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: 'Lokasi Anda',
            snippet: address,
          ),
        ),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('kantor'),
          position: _kOffice.target,
          icon: officeMarker ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: 'Kantor',
            snippet: ocp.officeConfig?.name,
          ),
        ),
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

    String dstring;
    if (distance >= 1) {
      dstring = "${distance.round()} KM";
    } else {
      dstring = "${(distance * 1000).round()} M";
    }
    setState(() {
      distanceInMeter = (distance * 1000).round();
      distanceBetweenPoints = dstring;
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
          radiusGeofence = ocp.officeConfig?.radius!.toDouble() ?? 20;
          _circlesSet = _buildCircles();

          //set marker office
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
          showBtn = false;
        });

        if (response2.data?.alreadyCheckIn == true) {
          showDesc = true;
          showBtn = true;
        } else if (response2.data?.alreadyCheckIn == false &&
            response2.data?.isWorkday == true) {
          showType = true;
          showBtn = true;
        }

        if (response2.data?.alreadyCheckOut == true) {
          showType = false;
          showDesc = false;
          showBtn = false;
        }

        if (response2.data?.isWorkday == true &&
            response2.data?.alreadyCheckOut == true &&
            response2.data?.haveOvertime == true) {
          showBtn = true;

          if (response2.data?.alreadyOvertimeEnded == true) {
            showBtn = false;
          }
        }

        if (response2.data?.isHoliday == true ||
            response2.data?.isWeekend == true) {
          showType = false;
          showDesc = false;
          showBtn = false;
        }

        if ((response2.data?.isHoliday == true ||
                response2.data?.isWeekend == true) &&
            response2.data?.haveOvertime == true) {
          showBtn = true;

          if (response2.data?.alreadyOvertimeEnded == true) {
            showBtn = false;
          }
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

  Future<BitmapDescriptor>? _createMarkerImage(
    String icon,
    double width,
    double height,
  ) async {
    final Uint8List byteList = await _getBytesFromAsset('assets/images/$icon');
    final ui.Codec codec = await ui.instantiateImageCodec(byteList);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    final ui.Image image = frameInfo.image;
    final ui.Image resizedImage = await _resizeImage(image, width, height);

    final ByteData? byteData =
        await resizedImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? resizedByteList = byteData?.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedByteList!);
  }

  Future<Uint8List> _getBytesFromAsset(String path) async {
    final ByteData byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  }

  Future<ui.Image> _resizeImage(ui.Image image, double width, double height) {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..filterQuality = FilterQuality.high;

    canvas.drawImageRect(
      image,
      Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTRB(0, 0, width, height),
      paint,
    );

    final ui.Picture picture = pictureRecorder.endRecording();

    return picture.toImage(width.toInt(), height.toInt());
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

  void startTracking() {
    final up = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    String userId = up.user!.id!;

    Workmanager().registerPeriodicTask(
      "send-location-task",
      "user-$userId",
      frequency: const Duration(
        minutes: 15,
      ),
      inputData: {
        'user_id': userId,
        'date': CalendarUtility.dateNow(),
      },
    );
  }

  void stopTracking() {
    print("stop all task");
    Workmanager().cancelAll();
  }

  void onConfirmation() async {
    final pp = Provider.of<PropertiesProvider>(
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
    // 10 = Lembur Belum Dimulai (akhir pekan/holiday)
    // 11 = Lembur Belum Diakhiri (akhir pekan/holiday)
    // 12 = Lembur Telah Berakhir (akhir pekan/holiday)

    String infoType = CommonUtility.getInfoType(pp.todayCheckData);
    print("info type $infoType");

    String msg = "";
    switch (infoType) {
      case "1":
        msg = "Lanjutkan untuk melakukan check-in?";
        break;
      case "2":
        msg = "Lanjutkan untuk melakukan check-out?";
        break;
      case "4":
        msg = "Lanjutkan untuk memulai lembur?";
        break;
      case "5":
        msg = "Lanjutkan untuk mengakhiri lembur?";
        break;
      case "10":
        msg = "Lanjutkan untuk memulai lembur di akhir pekan/hari libur? ";
        break;
      case "11":
        msg = "Lanjutkan untuk mengakhiri lembur di akhir pekan/hari libur?";
        break;
      default:
    }

    try {
      bool isConfirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Konfirmasi"),
            content: Text(msg),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Lanjut"),
              ),
            ],
          );
        },
      );

      if (isConfirmed == true) {
        if (!mounted) return;
        LoadingUtility.show("Sedang Proses");
        final tp = Provider.of<TokenProvider>(
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

        int jarakM = distanceInMeter;
        print("jarak dalam meter $jarakM");
        // return;

        final _location = {
          'lat': _latitude,
          'lng': _longitude,
          'address': _address,
        };

        if (infoType == "1") {
          if (_type == 'wfo') {
            // cek jarak kantor ke lokasi
            if (jarakM > geofence) {
              AmessageUtility.show(
                context,
                "Info",
                "Anda berada diluar area kantor",
                TipType.WARN,
              );
              return;
            }
          }
          stopTracking();

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
            startTracking();
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
            stopTracking();
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
          final requestData = {
            "user_id": _user_id,
            "overtime_start_at": _time,
          };

          PresenceResponse response =
              await PresenceService().startOvertime(requestData, token);
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
        } else if (infoType == "5") {
          final requestData = {
            "user_id": _user_id,
            "overtime_end_at": _time,
          };

          PresenceResponse response =
              await PresenceService().endOvertime(requestData, token);
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
        } else if (infoType == "6") {
        } else if (infoType == "7") {
        } else if (infoType == "8") {
        } else if (infoType == "9") {
        } else if (infoType == "10") {
          final requestData = {
            "user_id": _user_id,
            "overtime_start_at": _time,
          };

          PresenceResponse response =
              await PresenceService().startHolidayOvertime(requestData, token);
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
        } else if (infoType == "11") {
          final requestData = {
            "user_id": _user_id,
            "overtime_end_at": _time,
          };

          PresenceResponse response =
              await PresenceService().endHolidayOvertime(requestData, token);
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
        } else if (infoType == "12") {}
      }
    } catch (error) {
      print('Error: $error');

      AmessageUtility.show(context, "Gagal", error.toString(), TipType.ERROR);
    } finally {
      loadData();
      LoadingUtility.hide();
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _timer.cancel();
    _controller.future.then((controller) {
      controller.dispose();
    });
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
              // markers: {
              //   Marker(
              //     markerId: const MarkerId('kantor'),
              //     position: _kOffice.target,
              //     infoWindow:
              //         const InfoWindow(title: 'PT. Digital Amore Kriyanesia'),
              //   ),
              //   Marker(
              //     markerId: const MarkerId('your_position'),
              //     position: _kCurrentPosition.target,
              //     infoWindow: const InfoWindow(title: 'Posisi Anda'),
              //   ),
              // },
              markers: _markers,
              circles: _circlesSet ?? const <Circle>{},
            ),
          ),
          Positioned(
            bottom: ((MediaQuery.of(context).size.height * 0.16) + 16),
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
            minHeight: (MediaQuery.of(context).size.height * 0.16),
            boxShadow: const [],
            padding: const EdgeInsets.all(0.0),
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.3),
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
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    distanceBetweenPoints,
                                    style: const TextStyle(
                                        fontSize: 14,
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
                                      fontSize: 14,
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
                                          fontSize: 14,
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
                              color: Colors.grey.withOpacity(0.3),
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
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                address,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Latitude & Longitude:',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_currentPosition.latitude}, ${_currentPosition.longitude}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Waktu Presensi:',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Consumer<DateProvider>(
                                builder: (context, dateModel, child) => Text(
                                  CalendarUtility.formatBasic(dateModel.date),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<PropertiesProvider>(
                                builder: (context, propertiesProvider, _) {
                                  String textToShow =
                                      CommonUtility.presenceStatus(
                                          propertiesProvider.todayCheckData);

                                  return BsAlert(
                                    icon: Icons.info_outline,
                                    title: 'Status',
                                    message: textToShow,
                                    type: BsAlertType.info,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              if (showType)
                                const Text(
                                  'Pilih Jenis Kehadiran',
                                  style: TextStyle(
                                    fontSize: 14,
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
                                    fontSize: 14,
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
                              if (showBtn)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorConstant.lightPrimary,
                                    minimumSize:
                                        const Size.fromHeight(50), // NEW
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
