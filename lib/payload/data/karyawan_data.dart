import 'dart:convert';

class KaryawanData {
  String? userId;
  String? name;
  String? profilePicture;
  String? type;
  String? checkIn;
  String? checkOut;

  KaryawanData({
    this.userId,
    this.name,
    this.profilePicture,
    this.type,
    this.checkIn,
    this.checkOut,
  });

  factory KaryawanData.fromJson(Map<String, dynamic> json) {
    return KaryawanData(
      userId: json['user_id'],
      name: json['name'],
      profilePicture: json['profile_picture'],
      type: json['type'],
      checkIn: json['check_in'],
      checkOut: json['check_out'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'name': name,
      'profile_picture': profilePicture,
      'type': type,
      'check_in': checkIn,
      'check_out': checkOut,
    };
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
