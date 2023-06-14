import 'dart:convert';

class UserLocationModel {
  final int? id;
  final DateTime? createdAt;
  final String? userId;
  final double? lat;
  final double? lng;
  final String? address;
  final DateTime? trackedAt;

  UserLocationModel({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.lat,
    required this.lng,
    required this.address,
    required this.trackedAt,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      lat: double.parse(json['lat']),
      lng: double.parse(json['lng']),
      address: json['address'],
      trackedAt: DateTime.parse(json['tracked_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'created_at': createdAt.toString(),
      'userId': userId.toString(),
      'lat': lat.toString(),
      'lng': lng.toString(),
      'address': address,
      'tracked_at': trackedAt.toString(),
    };
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
