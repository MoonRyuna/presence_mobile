import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/user_location_model.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';

class LocationKaryawanScreen extends StatefulWidget {
  final String id;
  final String type;
  final String name;
  final String date;

  const LocationKaryawanScreen({
    super.key,
    required this.id,
    required this.type,
    required this.name,
    required this.date,
  });

  @override
  State<LocationKaryawanScreen> createState() => _LocationKaryawanScreenState();
}

class _LocationKaryawanScreenState extends State<LocationKaryawanScreen> {
  late final _stream;

  late String distanceBetweenPoints = "-";
  int distanceInMeter = 0;
  late String address = "-";

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const LatLng mapCenter = LatLng(-6.9147444, 107.6098106);
  final CameraPosition _kBandung = const CameraPosition(
    target: mapCenter,
    zoom: 11.0,
    tilt: 0,
    bearing: 0,
  );

  final CameraPosition _kOffice = const CameraPosition(
    target: LatLng(-7.011477899042147, 107.55234770202203),
    zoom: 17,
  );

  Set<Circle>? _circlesSet;
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
    _buildCircles();
    print("ini user id ${widget.id}");
    print("ini type ${widget.type}");
    print("ini name ${widget.name}");
    print("ini date ${widget.date}");

    _stream = Supabase.instance.client
        .from('user_location')
        .select()
        .eq('user_id', widget.id)
        .like('tracked_at', '${widget.date}%');
  }

  @override
  void dispose() {
    _controller.future.then((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> getUserLocations(String userId) async {
    final response = await Supabase.instance.client
        .from('user_location')
        .select()
        .eq('user_Id', userId)
        .order('tracked_at', ascending: false);

    if (response.error != null) {
      // Error handling
      print('Error retrieving user locations: ${response.error!.message}');
      return [];
    }

    return response.data as List<Map<String, dynamic>>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        backgroundColor: ColorConstant.lightPrimary,
        title: const Text("Lokasi Karyawan"),
        centerTitle: true,
        elevation: 0, // menghilangkan shadow
      ),
      resizeToAvoidBottomInset: true,
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, true);
          return false;
        },
        child: Stack(
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
                },
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
                    heroTag: "btnToRefresh",
                    onPressed: () {},
                    child: CircleAvatar(
                      backgroundColor: ColorConstant.lightPrimary,
                      radius: 30,
                      child: const Icon(Icons.refresh, color: Colors.white),
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
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  widget.name,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: ColorConstant.lightPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.type != null
                                      ? widget.type == "wfo"
                                          ? "WFO (Kantor)"
                                          : "WFH (Jarak Jauh)"
                                      : "Belum Presensi",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  CalendarUtility.formatBasic2(
                                    DateTime.parse(widget.date),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: const Text(
                              "Riwayat Lokasi",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height - 260,
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: FutureBuilder(
                              future: _stream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  print(snapshot.data.toString());

                                  List<UserLocationModel> userLocations =
                                      (snapshot.data as List<dynamic>)
                                          .map((data) {
                                    return UserLocationModel.fromJson(data);
                                  }).toList();

                                  return ListView.builder(
                                    itemCount: userLocations.length,
                                    itemBuilder: (context, index) {
                                      final userLocation = userLocations[index];
                                      return TimelineTile(
                                        alignment: TimelineAlign.start,
                                        isFirst: index == 0,
                                        indicatorStyle: const IndicatorStyle(
                                          width: 10,
                                          color: Colors.green,
                                          padding: EdgeInsets.all(8),
                                        ),
                                        endChild: Container(
                                          constraints: const BoxConstraints(
                                            minHeight: 80,
                                          ),
                                          padding: const EdgeInsets.all(16.0),
                                          color: Colors.green.withOpacity(0.2),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userLocation!.address!,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                  'Jam ${userLocation.trackedAt!.hour}:${userLocation.trackedAt!.minute}'),
                                              const SizedBox(height: 8),
                                              Text(
                                                  'lat: ${userLocation.lat!.toString()}, lng: ${userLocation.lng.toString()}'),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
