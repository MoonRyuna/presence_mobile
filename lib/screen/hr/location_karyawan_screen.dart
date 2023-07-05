import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presence_alpha/constant/color_constant.dart';
import 'package:presence_alpha/model/user_location_model.dart';
import 'package:presence_alpha/provider/office_config_provide.dart';
import 'package:presence_alpha/utility/calendar_utility.dart';
import 'package:provider/provider.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:timeline_tile/timeline_tile.dart';

class LocationKaryawanScreen extends StatefulWidget {
  final String id;
  final String type;
  final String name;
  final String date;
  final String profilePicture;

  const LocationKaryawanScreen({
    super.key,
    required this.id,
    required this.type,
    required this.name,
    required this.date,
    required this.profilePicture,
  });

  @override
  State<LocationKaryawanScreen> createState() => _LocationKaryawanScreenState();
}

class _LocationKaryawanScreenState extends State<LocationKaryawanScreen> {
  dynamic _stream;
  final Set<Marker> _markers = {};

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

  CameraPosition _kOffice = const CameraPosition(
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

  void _createMarkers() async {
    final ocp = Provider.of<OfficeConfigProvider>(
      context,
      listen: false,
    );

    dynamic ss = await Supabase.instance.client
        .from('user_location')
        .select()
        .eq('user_id', widget.id)
        .like('tracked_at', '${widget.date}%')
        .order('tracked_at', ascending: true);
    List<UserLocationModel> userLocations = (ss as List<dynamic>).map((data) {
      return UserLocationModel.fromJson(data);
    }).toList();

    if (!mounted) return;
    final userMarker = await _createMarkerImage('user-marker.png', 150, 150);
    final officeMarker =
        await _createMarkerImage('office-marker.png', 150, 150);

    setState(() {
      _markers.clear();
      for (UserLocationModel userLocation in userLocations) {
        print("ini ah ${userLocation.toJsonString()}");
        Marker mm = Marker(
          markerId: MarkerId(userLocation.id.toString()),
          position: LatLng(userLocation.lat ?? 0.0, userLocation.lng ?? 0.0),
          icon: userMarker ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: widget.name,
            snippet: userLocation.address,
          ),
        );
        _markers.add(mm);
      }
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
  }

  @override
  void initState() {
    super.initState();
    _buildCircles();
    print("ini user id ${widget.id}");
    print("ini type ${widget.type}");
    print("ini name ${widget.name}");
    print("ini date ${widget.date}");

    getList();
    Supabase.instance.client.channel('public:user_location').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: '*', schema: 'public', table: 'user_location'),
      (payload, [ref]) {
        print('Change received: ${payload.toString()}');
        getList();
      },
    ).subscribe();

    setKantorMarker();
  }

  void setKantorMarker() {
    final ocp = Provider.of<OfficeConfigProvider>(
      context,
      listen: false,
    );

    double latOffice = -7.01147799042147;
    double lngOffice = 107.55234770202203;

    if (ocp.officeConfig?.latitude != null) {
      latOffice = ocp.officeConfig?.latitude as double;
    }
    if (ocp.officeConfig?.longitude != null) {
      lngOffice = ocp.officeConfig?.longitude as double;
    }
    setState(() {
      _kOffice = CameraPosition(
        target: LatLng(latOffice, lngOffice),
        zoom: 17,
      );
      radiusGeofence = ocp.officeConfig?.radius!.toDouble() ?? 20;
      _circlesSet = _buildCircles();
    });
  }

  @override
  void dispose() {
    Supabase.instance.client.channel('public:user_location').unsubscribe();
    _controller.future.then((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void getList() async {
    setState(() {
      _stream = Supabase.instance.client
          .from('user_location')
          .select()
          .eq('user_id', widget.id)
          .like('tracked_at', '${widget.date}%')
          .order('tracked_at', ascending: true);
    });
    _createMarkers();
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
                // markers: {
                //   Marker(
                //     markerId: const MarkerId('kantor'),
                //     position: _kOffice.target,
                //     infoWindow:
                //         const InfoWindow(title: 'PT. Digital Amore Kriyanesia'),
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
                    heroTag: "btnToRefresh",
                    onPressed: () {
                      getList();
                    },
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
                                    DateTime.parse(widget.date).toLocal(),
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
                                                  'Jam ${CalendarUtility.getTime(userLocation.trackedAt!)}'),
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
