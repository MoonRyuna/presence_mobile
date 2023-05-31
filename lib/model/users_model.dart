import 'dart:convert';

import 'package:presence_alpha/model/user_model.dart';

class UsersModel {
  int total;
  int currentPage;
  int nextPage;
  int prevPage;
  int limit;
  List<UserModel> result;

  UsersModel({
    this.total = 0,
    this.currentPage = 0,
    this.nextPage = 0,
    this.prevPage = 0,
    this.limit = 0,
    this.result = const [],
  });

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      total: json['total'],
      currentPage: json['current_page'],
      nextPage: json['next_page'],
      prevPage: json['prev_page'],
      limit: json['limit'],
      result: json['result'] != null
          ? (json['result'] as List).map((i) => UserModel.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    List<Map<String, dynamic>> json = <Map<String, dynamic>>[];

    json = result.map((i) => i.toJson()).toList();

    data['total'] = total;
    data['current_page'] = currentPage;
    data['next_page'] = nextPage;
    data['prev_page'] = prevPage;
    data['limit'] = limit;
    data['result'] = json;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
