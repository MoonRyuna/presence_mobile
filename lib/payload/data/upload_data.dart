import 'dart:convert';

class UploadData {
  String? fieldname;
  String? originalname;
  String? encoding;
  String? mimetype;
  String? destination;
  String? filename;
  String? path;
  int? size;

  UploadData({
    required this.fieldname,
    required this.originalname,
    required this.encoding,
    required this.mimetype,
    required this.destination,
    required this.filename,
    required this.path,
    required this.size,
  });

  factory UploadData.fromJson(Map<String, dynamic> json) {
    return UploadData(
      fieldname: json['fieldname'],
      originalname: json['originalname'],
      encoding: json['encoding'],
      mimetype: json['mimetype'],
      destination: json['destination'],
      filename: json['filename'],
      path: json['path'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fieldname'] = fieldname;
    data['originalname'] = originalname;
    data['encoding'] = encoding;
    data['mimetype'] = mimetype;
    data['destination'] = destination;
    data['filename'] = filename;
    data['path'] = path;
    data['size'] = size;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
