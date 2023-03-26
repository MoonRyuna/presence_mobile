import 'dart:convert';

import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/payload/response/auth_response.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<AuthResponse> auth(Map<String, dynamic> requestData) async {
    // ignore: avoid_print
    print('POST: auth');

    String target = '${ApiConstant.baseApi}/auth';
    // ignore: avoid_print
    print('target: $target');

    final response = await http.post(
      Uri.parse(target),
      body: json.encode(requestData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return AuthResponse.fromJson(responseData);
    } else {
      return AuthResponse(
        status: false,
        message: 'Unable to authenticate user',
        data: null,
      );
    }
  }
}
