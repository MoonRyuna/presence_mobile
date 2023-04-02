import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:presence_alpha/provider/date_provider.dart';
import 'package:presence_alpha/screen/izin_screen.dart';
import 'package:presence_alpha/utility/maps_utility.dart';
import 'package:provider/provider.dart';
import 'package:presence_alpha/constant/color_constant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  late String distanceBetweenPoints = "-";
  late String address = "-";
  late Position _currentPosition;
  late LocationPermission locationPermission;

  static const LatLng mapCenter = LatLng(-6.9147444, 107.6098106);
  static const CameraPosition _kBandung =
      CameraPosition(target: mapCenter, zoom: 11.0, tilt: 0, bearing: 0);

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kOffice = CameraPosition(
    target: LatLng(-7.011477899042147, 107.55234770202203),
    zoom: 17,
  );

  CameraPosition _kCurrentPosition =
      const CameraPosition(target: LatLng(-6.9147444, 107.6098106), zoom: 17);

  Set<Circle> circles = {
    Circle(
        circleId: const CircleId("kantor_geofence"),
        center: _kOffice.target,
        radius: 20,
        fillColor: Colors.redAccent.withOpacity(0.5),
        strokeWidth: 3,
        strokeColor: Colors.redAccent)
  };

  void getLocation() async {}

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      Provider.of<DateProvider>(context, listen: false).setDate(DateTime.now());
    });
    _getLocation();
    calculateDistance();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

  Future<void> _getLocation() async {
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
        _kCurrentPosition.target.longitude);

    setState(() {
      distanceBetweenPoints = "${distance.ceil()} KM";
    });
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

  Widget userInfo(String name, String photoUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Image.network(
            photoUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
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
            Text(
              name,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: ColorConstant.lightPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget boxInfo(String accountType, String checkIn, String checkOut) {
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
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Consumer<DateProvider>(
            builder: (context, dateModel, child) => Text(
              DateFormat('dd MMMM yyyy HH:mm:ss').format(dateModel.date),
              style: const TextStyle(
                fontSize: 24,
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
                    Text(
                      checkIn,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                    Text(
                      checkOut,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  Widget boxLocation(String address) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
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
          width: (MediaQuery.of(context).size.width - 50) / 2,
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
                  fontSize: 16,
                ),
              ),
              Text(
                infoDistance,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 50) / 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 75,
                height: 75,
                child: IconButton(
                  icon: CircleAvatar(
                    backgroundColor: ColorConstant.lightPrimary,
                    radius: 30,
                    child:
                        const Icon(Icons.business_center, color: Colors.white),
                  ),
                  onPressed: () {
                    _goToOffice();
                  },
                ),
              ),
              SizedBox(
                width: 75,
                height: 75,
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 30,
                    child: Icon(Icons.gps_fixed, color: Colors.white),
                  ),
                  onPressed: () {
                    _goToCurrenPosition();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget boxButton() {
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: [
    //     Container(
    //       width: MediaQuery.of(context).size.width / 2 - 30,
    //       height: 100,
    //       decoration: BoxDecoration(
    //         border: Border.all(color: ColorConstant.lightPrimary, width: 2.0),
    //         borderRadius: BorderRadius.circular(13),
    //       ),
    //       child: TextButton.icon(
    //         onPressed: () {
    //           Navigator.push(
    //             context,
    //             MaterialPageRoute(builder: (context) => const IzinScreen()),
    //           );
    //         },
    //         icon: Icon(Icons.check, color: ColorConstant.lightPrimary),
    //         label: Text('Izin',
    //             style: TextStyle(color: ColorConstant.lightPrimary)),
    //       ),
    //     ),
    //     Container(
    //       width: MediaQuery.of(context).size.width / 2 - 30,
    //       height: 100,
    //       decoration: BoxDecoration(
    //         border: Border.all(color: ColorConstant.lightPrimary, width: 2.0),
    //         borderRadius: BorderRadius.circular(13),
    //       ),
    //       child: TextButton.icon(
    //         onPressed: () {},
    //         icon: Icon(Icons.access_time, color: ColorConstant.lightPrimary),
    //         label: Text('Lembur',
    //             style: TextStyle(color: ColorConstant.lightPrimary)),
    //       ),
    //     ),
    //   ],
    // );
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        gridButton("Kehadiran", Icons.fingerprint),
        gridButton("Izin", Icons.assignment),
        gridButton("Lembur", Icons.timer),
      ],
    );
  }

  Widget gridButton(String text, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Ketika tombol ditekan
      },
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
            Icon(icon, size: 40, color: Colors.grey[800]),
            const SizedBox(height: 6),
            Text(text, style: const TextStyle(fontSize: 12)),
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
                    userInfo("Ari Ardiansyah",
                        "https://sbcf.fr/wp-content/uploads/2018/03/sbcf-default-avatar.png"),
                    const Padding(padding: EdgeInsets.all(10)),
                    boxInfo("Karyawan", "10:10:10", "17:10:10"),
                    const Padding(padding: EdgeInsets.all(8)),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Menu",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(6)),
                    boxButton(),
                    const Padding(padding: EdgeInsets.all(10)),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(238, 238, 238, 1),
                          width: 1.5,
                        ),
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width -
                            38, // or use fixed size like 200
                        height: 180,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: _kBandung,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                          markers: {
                            Marker(
                              markerId: const MarkerId('kantor'),
                              position: _kOffice.target,
                              infoWindow: const InfoWindow(
                                  title: 'PT. Digital Amore Kriyanesia'),
                            ),
                            Marker(
                              markerId: const MarkerId('your_position'),
                              position: _kCurrentPosition.target,
                              infoWindow:
                                  const InfoWindow(title: 'Posisi Anda'),
                            ),
                          },
                          circles: circles,
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(6)),
                    boxLocation(address),
                    const Padding(padding: EdgeInsets.all(6)),
                    distanceLocation(distanceBetweenPoints),
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
