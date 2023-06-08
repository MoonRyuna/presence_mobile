import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String label;

  const MyMapWidget(
      {super.key,
      required this.latitude,
      required this.longitude,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          height: 170,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: MarkerId(label),
                position: LatLng(latitude, longitude),
              ),
            },
          ),
        ),
      ],
    );
  }
}
