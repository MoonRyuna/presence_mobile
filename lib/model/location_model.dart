import 'dart:convert';

class LocationModel {
  String? lat;
  String? lng;
  String? address;

  LocationModel({
    this.lat,
    this.lng,
    this.address,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: json['lat'],
      lng: json['lng'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    data['address'] = address;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
