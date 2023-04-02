import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/payload/response/auth_response.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<AuthResponse> auth(Map<String, dynamic> requestData) async {
    print('POST: auth');

    String target = '${ApiConstant.baseApi}/auth';
    print('target: $target');

    try {
      final response = await http
          .post(
            Uri.parse(target),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestData),
          )
          .timeout(Duration(seconds: ApiConstant.timeout));

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
    } on TimeoutException catch (e) {
      return AuthResponse(
        status: false,
        message: 'Connection timed out',
        data: null,
      );
    } on SocketException catch (e) {
      return AuthResponse(
        status: false,
        message: e.message,
        data: null,
      );
    } on Exception catch (e) {
      return AuthResponse(
        status: false,
        message: 'Failed to connect to server',
        data: null,
      );
    } catch (e) {
      return AuthResponse(
        status: false,
        message: e.toString(),
        data: null,
      );
    }
  }
}
