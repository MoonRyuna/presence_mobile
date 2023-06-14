import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/payload/response/change_password_response.dart';
import 'package:presence_alpha/payload/response/create_user_response.dart';
import 'package:presence_alpha/payload/response/dashboard1_response.dart';
import 'package:presence_alpha/payload/response/delete_user_response.dart';
import 'package:presence_alpha/payload/response/list_monitoring_karyawan_response.dart';
import 'package:presence_alpha/payload/response/reset_imei_response.dart';
import 'package:presence_alpha/payload/response/today_check_response.dart';
import 'package:presence_alpha/payload/response/update_profile_response.dart';
import 'package:presence_alpha/payload/response/user/list_jatah_cuti_tahunan_response.dart';
import 'package:presence_alpha/payload/response/user_list_response.dart';

class UserService {
  Future<Dashboard1Response> dashboard1(
      Map<String, dynamic> requestData, String token) async {
    print('POST: dashboard1');

    String target = '${ApiConstant.baseApi}/user/dashboard1';
    print('target: $target');
    print('json" ${jsonEncode(json.encode(requestData))}');

    try {
      final response = await http
          .post(
            Uri.parse(target),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: json.encode(requestData),
          )
          .timeout(Duration(seconds: ApiConstant.timeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Dashboard1Response.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Dashboard1Response(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
          data: null,
        );
      }
    } on TimeoutException {
      return Dashboard1Response(
        status: false,
        message: 'Connection timed out',
        data: null,
      );
    } on SocketException catch (e) {
      return Dashboard1Response(
        status: false,
        message: e.message,
        data: null,
      );
    } on Exception {
      return Dashboard1Response(
        status: false,
        message: 'Failed to connect to server',
        data: null,
      );
    } catch (e) {
      return Dashboard1Response(
        status: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<TodayCheckResponse> todayCheck(
      Map<String, dynamic> requestData, String token) async {
    print('POST: today_check');

    String target = '${ApiConstant.baseApi}/user/today_check';
    print('target: $target');
    print('json" ${jsonEncode(json.encode(requestData))}');

    try {
      final response = await http
          .post(
            Uri.parse(target),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: json.encode(requestData),
          )
          .timeout(Duration(seconds: ApiConstant.timeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return TodayCheckResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return TodayCheckResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
          data: null,
        );
      }
    } on TimeoutException {
      return TodayCheckResponse(
        status: false,
        message: 'Connection timed out',
        data: null,
      );
    } on SocketException catch (e) {
      return TodayCheckResponse(
        status: false,
        message: e.message,
        data: null,
      );
    } on Exception {
      return TodayCheckResponse(
        status: false,
        message: 'Failed to connect to server',
        data: null,
      );
    } catch (e) {
      return TodayCheckResponse(
        status: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ChangePasswordResponse> changePassword(
      Map<String, dynamic> requestData, String id, String token) async {
    print('PUT: change_password');

    String target = '${ApiConstant.baseApi}/user/change_password/${id}';
    print('target: $target');
    print('json" ${jsonEncode(json.encode(requestData))}');

    try {
      final response = await http
          .put(
            Uri.parse(target),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: json.encode(requestData),
          )
          .timeout(Duration(seconds: ApiConstant.timeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ChangePasswordResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ChangePasswordResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
          data: null,
        );
      }
    } on TimeoutException {
      return ChangePasswordResponse(
        status: false,
        message: 'Connection timed out',
        data: null,
      );
    } on SocketException catch (e) {
      return ChangePasswordResponse(
        status: false,
        message: e.message,
        data: null,
      );
    } on Exception {
      return ChangePasswordResponse(
        status: false,
        message: 'Failed to connect to server',
        data: null,
      );
    } catch (e) {
      return ChangePasswordResponse(
        status: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<UpdateProfileResponse> updateProfile(
      Map<String, dynamic> requestData, String id, String token) async {
    print('PUT: update_profile');

    String target = '${ApiConstant.baseApi}/user/${id}';
    print('target: $target');
    print('json" ${jsonEncode(json.encode(requestData))}');

    try {
      final response = await http
          .put(
            Uri.parse(target),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: json.encode(requestData),
          )
          .timeout(Duration(seconds: ApiConstant.timeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return UpdateProfileResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return UpdateProfileResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
          data: null,
        );
      }
    } on TimeoutException {
      return UpdateProfileResponse(
        status: false,
        message: 'Connection timed out',
        data: null,
      );
    } on SocketException catch (e) {
      return UpdateProfileResponse(
        status: false,
        message: e.message,
        data: null,
      );
    } on Exception {
      return UpdateProfileResponse(
        status: false,
        message: 'Failed to connect to server',
        data: null,
      );
    } catch (e) {
      return UpdateProfileResponse(
        status: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<CreateUserResponse> createUser(
      Map<String, dynamic> requestData, String token) async {
    print('POST: create user');

    String target = '${ApiConstant.baseApi}/user';
    print('target: $target');
    print('json" ${jsonEncode(json.encode(requestData))}');

    try {
      final response = await http
          .post(
            Uri.parse(target),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: json.encode(requestData),
          )
          .timeout(Duration(seconds: ApiConstant.timeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return CreateUserResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return CreateUserResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
          data: null,
        );
      }
    } on TimeoutException {
      return CreateUserResponse(
        status: false,
        message: 'Connection timed out',
        data: null,
      );
    } on SocketException catch (e) {
      return CreateUserResponse(
        status: false,
        message: e.message,
        data: null,
      );
    } on Exception {
      return CreateUserResponse(
        status: false,
        message: 'Failed to connect to server',
        data: null,
      );
    } catch (e) {
      return CreateUserResponse(
        status: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<DeleteUserResponse> deleteUser(
      Map<String, dynamic> requestData, String id, String token) async {
    print('DELETE: create user');

    String target = '${ApiConstant.baseApi}/user/soft/$id';
    print('target: $target');
    print('json" ${jsonEncode(json.encode(requestData))}');

    try {
      final response = await http
          .delete(
            Uri.parse(target),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: json.encode(requestData),
          )
          .timeout(Duration(seconds: ApiConstant.timeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return DeleteUserResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return DeleteUserResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
          data: null,
        );
      }
    } on TimeoutException {
      return DeleteUserResponse(
        status: false,
        message: 'Connection timed out',
        data: null,
      );
    } on SocketException catch (e) {
      return DeleteUserResponse(
        status: false,
        message: e.message,
        data: null,
      );
    } on Exception {
      return DeleteUserResponse(
        status: false,
        message: 'Failed to connect to server',
        data: null,
      );
    } catch (e) {
      return DeleteUserResponse(
        status: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ResetImeiResponse> resetImei(
      Map<String, dynamic> requestData, String token) async {
    print('POST: reset imei user');

    String target = '${ApiConstant.baseApi}/user/reset_imei';
    print('target: $target');
    print('json" ${jsonEncode(json.encode(requestData))}');

    try {
      final response = await http
          .post(
            Uri.parse(target),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: json.encode(requestData),
          )
          .timeout(Duration(seconds: ApiConstant.timeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ResetImeiResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ResetImeiResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
          data: null,
        );
      }
    } on TimeoutException {
      return ResetImeiResponse(
        status: false,
        message: 'Connection timed out',
        data: null,
      );
    } on SocketException catch (e) {
      return ResetImeiResponse(
        status: false,
        message: e.message,
        data: null,
      );
    } on Exception {
      return ResetImeiResponse(
        status: false,
        message: 'Failed to connect to server',
        data: null,
      );
    } catch (e) {
      return ResetImeiResponse(
        status: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<UserListResponse> getUserList(
      {String? name,
      String? userCode,
      String? accountType,
      bool deleted = false,
      int page = 1,
      int limit = 10,
      String? order,
      String? token}) async {
    print('GET: user list');

    String target = '${ApiConstant.baseApi}/user';
    print('target: $target');

    Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'account_type': accountType.toString(),
      'deleted': deleted.toString(),
    };

    if (name != null) queryParams['name'] = name;
    if (userCode != null) queryParams['user_code'] = userCode;
    if (accountType != null) queryParams['account_type'] = accountType;
    if (order != null) queryParams['order'] = order;

    String queryString = Uri(queryParameters: queryParams).query;
    target += '?$queryString';

    try {
      final response = await http.get(
        Uri.parse(target),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return UserListResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return UserListResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch user list',
          data: null,
        );
      }
    } on SocketException catch (e) {
      return UserListResponse(
        status: false,
        message: e.message,
        data: null,
      );
    } on Exception {
      return UserListResponse(
        status: false,
        message: 'Failed to connect to server',
        data: null,
      );
    } catch (e) {
      return UserListResponse(
        status: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<ListJatahCutiTahunanResponse> listJatahCutiTahunanResponse(
      Map<String, dynamic> queryParams, String token) async {
    print('GET: user - list jatah cuti karyawan');

    String target = '${ApiConstant.baseApi}/user/list/jatah_cuti_tahunan';
    final queryParameters = Uri(queryParameters: queryParams).queryParameters;

    final queryString = Uri(queryParameters: queryParameters).query;

    print('target: ${Uri.parse("$target?$queryString")}');

    try {
      final response = await http.get(
        Uri.parse("$target?$queryString"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ).timeout(Duration(seconds: ApiConstant.timeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ListJatahCutiTahunanResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ListJatahCutiTahunanResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException {
      return ListJatahCutiTahunanResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return ListJatahCutiTahunanResponse(
        status: false,
        message: e.message,
      );
    } on Exception {
      return ListJatahCutiTahunanResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return ListJatahCutiTahunanResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<ListMonitoringKaryawanResponse> getMonitoringKaryawan(
      {String? date,
      String? name,
      int page = 1,
      int limit = 10,
      String? token}) async {
    print('GET: user list');

    String target = '${ApiConstant.baseApi}/user/list/monitor_karyawan';
    print('target: $target');

    Map<String, dynamic> queryParams = {
      'date': date,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (name != null) queryParams['name'] = name;

    String queryString = Uri(queryParameters: queryParams).query;
    target += '?$queryString';

    try {
      final response = await http.get(
        Uri.parse(target),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ListMonitoringKaryawanResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ListMonitoringKaryawanResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch user list',
          data: null,
        );
      }
    } on SocketException catch (e) {
      return ListMonitoringKaryawanResponse(
        status: false,
        message: e.message,
        data: null,
      );
    } on Exception {
      return ListMonitoringKaryawanResponse(
        status: false,
        message: 'Failed to connect to server',
        data: null,
      );
    } catch (e) {
      return ListMonitoringKaryawanResponse(
        status: false,
        message: e.toString(),
        data: null,
      );
    }
  }
}
