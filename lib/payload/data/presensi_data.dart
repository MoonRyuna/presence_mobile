import 'dart:convert';

class PresensiData {
  String? checkIn;
  String? checkOut;

  PresensiData({this.checkIn, this.checkOut});

  PresensiData.fromJson(Map<String, dynamic> json) {
    checkIn = json['check_in'];
    checkOut = json['check_out'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['check_in'] = checkIn;
    data['check_out'] = checkOut;
    return data;
  }

  String toPlain() {
    return 'PresensiData{ checkIn: $checkIn, checkOut: $checkOut }';
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
