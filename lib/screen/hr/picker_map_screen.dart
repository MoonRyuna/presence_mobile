import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:presence_alpha/constant/env_constant.dart';

class PickerMapScreen extends StatefulWidget {
  final double lat;
  final double lng;

  const PickerMapScreen({super.key, required this.lat, required this.lng});

  @override
  State<PickerMapScreen> createState() => _PickerMapScreenState();
}

class _PickerMapScreenState extends State<PickerMapScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: SafeArea(
        child: PlacePicker(
          apiKey: EnvConstant.googleMapKey,
          hintText: "Cari lokasi ...",
          searchingText: "Silakan tunggu ...",
          selectText: "Pilih lokasi",
          outsideOfPickAreaText: "Lokasi diluar area",
          // useCurrentLocation: true,
          selectInitialPosition: true,
          usePinPointingSearch: true,
          usePlaceDetailSearch: true,
          zoomGesturesEnabled: true,
          initialPosition: LatLng(widget.lat, widget.lng),
          onMapCreated: (GoogleMapController controller) {
            print("Map created");
          },
          onPlacePicked: (PickResult result) {
            print("Place picked: ${result.formattedAddress}");
            print("lat: ${result.geometry?.location.lat}");
            print("lng: ${result.geometry?.location.lng}");
            Navigator.pop(context, {
              'lat': result.geometry?.location.lat,
              'lng': result.geometry?.location.lng
            });
          },
          onTapBack: () {
            Navigator.pop(context, {'lat': widget.lat, 'lng': widget.lng});
          },
        ),
      ),
    );
  }
}
