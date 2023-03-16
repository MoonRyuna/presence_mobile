import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:presence_alpha/provider/date_provider.dart';
import 'package:provider/provider.dart';
import '../constant/color_constant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  GoogleMapController? _controller;
  Location currentLocation = Location();
  final Set<Marker> _markers = {};

  void getLocation() async {
    var location = await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc) {
      _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
        zoom: 12.0,
      )));

      print(loc.latitude);
      print(loc.longitude);

      setState(() {
        _markers.add(Marker(
            markerId: const MarkerId('Home'),
            position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      Provider.of<DateProvider>(context, listen: false).setDate(DateTime.now());
    });

    setState(() {
      getLocation();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        ]),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  color: Colors.white),
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
                          color: Colors.white),
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
                          color: Colors.white),
                    ),
                    Text(
                      checkOut,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                )
              ],
            ),
            // tambahkan child atau konten di dalam container di sini
          ),
        ]));
  }

  Widget boxMap() {
    return Container(
      height: 200,
      width: double.infinity,
      child: GoogleMap(
        zoomControlsEnabled: false,
        initialCameraPosition: const CameraPosition(
          target: LatLng(48.8561, 2.2930),
          zoom: 12.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        markers: _markers,
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
                    const Padding(padding: EdgeInsets.all(10)),
                    boxMap(),
                    const Padding(padding: EdgeInsets.all(3)),
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
