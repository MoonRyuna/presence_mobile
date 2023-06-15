import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/payload/response/auth_response.dart';
import 'package:presence_alpha/payload/response/base_response.dart';
import 'package:presence_alpha/payload/response/verify_otp_response.dart';

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
    } on TimeoutException {
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
    } on Exception {
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

  Future<BaseResponse> forgotPassword(Map<String, dynamic> requestData) async {
    print('POST: forgot_password');

    String target = '${ApiConstant.baseApi}/forgot_password';
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
        return BaseResponse.fromJson(responseData);
      } else {
        return BaseResponse(
          status: false,
          message: 'Unable send email',
        );
      }
    } on TimeoutException {
      return BaseResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return BaseResponse(
        status: false,
        message: e.message,
      );
    } on Exception {
      return BaseResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return BaseResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<VerifyOTPResponse> verifyOTP(Map<String, dynamic> requestData) async {
    print('POST: verify_otp');

    String target = '${ApiConstant.baseApi}/verify_otp';
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
        return VerifyOTPResponse.fromJson(responseData);
      } else {
        return VerifyOTPResponse(
          status: false,
          message: 'Unable to verify otp',
        );
      }
    } on TimeoutException {
      return VerifyOTPResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return VerifyOTPResponse(
        status: false,
        message: e.message,
      );
    } on Exception {
      return VerifyOTPResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return VerifyOTPResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<BaseResponse> changePassword(Map<String, dynamic> requestData) async {
    print('POST: change_password');

    String target = '${ApiConstant.baseApi}/change_password';
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
        return BaseResponse.fromJson(responseData);
      } else {
        return BaseResponse(
          status: false,
          message: 'Unable to change password',
        );
      }
    } on TimeoutException {
      return BaseResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return BaseResponse(
        status: false,
        message: e.message,
      );
    } on Exception {
      return BaseResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return BaseResponse(
        status: false,
        message: e.toString(),
      );
    }
  }
}
