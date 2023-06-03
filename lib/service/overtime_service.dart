import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/payload/response/absence/list_submission_admin_response.dart';
import 'package:presence_alpha/payload/response/base_response.dart';
import 'package:presence_alpha/payload/response/overtime/cancel_response.dart';
import 'package:presence_alpha/payload/response/overtime/detail_response.dart';
import 'package:presence_alpha/payload/response/overtime/list_response.dart';
import 'package:presence_alpha/payload/response/overtime/list_submission.dart';
import 'package:presence_alpha/payload/response/overtime/submission_response.dart';

class OvertimeService {
  Future<ListResponse> list(
      Map<String, dynamic> queryParams, String token) async {
    print('GET: overtime - list');

    String target = '${ApiConstant.baseApi}/overtime';
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
        return ListResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ListResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException catch (e) {
      return ListResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return ListResponse(
        status: false,
        message: e.message,
      );
    } on Exception catch (e) {
      return ListResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return ListResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<SubmissionResponse> submission(
      Map<String, dynamic> requestData, String token) async {
    print('POST: submission');

    String target = '${ApiConstant.baseApi}/overtime/submission';
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
        return SubmissionResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return SubmissionResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException catch (e) {
      return SubmissionResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return SubmissionResponse(
        status: false,
        message: e.message,
      );
    } on Exception catch (e) {
      return SubmissionResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return SubmissionResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<DetailResponse> detail(String id, String token) async {
    print('GET: overtime - detail');

    String target = '${ApiConstant.baseApi}/overtime/$id';
    print('target: ${Uri.parse(target)}');

    try {
      final response = await http.get(
        Uri.parse(target),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ).timeout(Duration(seconds: ApiConstant.timeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return DetailResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return DetailResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException catch (e) {
      return DetailResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return DetailResponse(
        status: false,
        message: e.message,
      );
    } on Exception catch (e) {
      return DetailResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return DetailResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<ListSubmissionResponse> listSubmission(String id, String token) async {
    print('GET: overtime - list_submission');

    String target = '${ApiConstant.baseApi}/overtime/submission/$id';
    print('target: ${Uri.parse(target)}');

    try {
      final response = await http.get(
        Uri.parse(target),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ).timeout(Duration(seconds: ApiConstant.timeout));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ListSubmissionResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ListSubmissionResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException catch (e) {
      return ListSubmissionResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return ListSubmissionResponse(
        status: false,
        message: e.message,
      );
    } on Exception catch (e) {
      return ListSubmissionResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return ListSubmissionResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<ListSubmissionAdminResponse> listSubmissionAdmin(
      Map<String, dynamic> queryParams, String token) async {
    print('GET: absence - list_submission_admin');

    String target = '${ApiConstant.baseApi}/overtime/list/submission';
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
        return ListSubmissionAdminResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ListSubmissionAdminResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException catch (e) {
      return ListSubmissionAdminResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return ListSubmissionAdminResponse(
        status: false,
        message: e.message,
      );
    } on Exception catch (e) {
      return ListSubmissionAdminResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return ListSubmissionAdminResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<BaseResponse> approve(
      Map<String, dynamic> requestData, String token) async {
    print('POST: approve overtime');

    String target = '${ApiConstant.baseApi}/overtime/approve';
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
        return BaseResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return BaseResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException catch (e) {
      return BaseResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return BaseResponse(
        status: false,
        message: e.message,
      );
    } on Exception catch (e) {
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

  Future<BaseResponse> reject(
      Map<String, dynamic> requestData, String token) async {
    print('POST: reject overtime');

    String target = '${ApiConstant.baseApi}/overtime/reject';
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
        return BaseResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return BaseResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException catch (e) {
      return BaseResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return BaseResponse(
        status: false,
        message: e.message,
      );
    } on Exception catch (e) {
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

  Future<CancelResponse> cancel(
      Map<String, dynamic> requestData, String token) async {
    print('POST: cancel');

    String target = '${ApiConstant.baseApi}/overtime/cancel';
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
        return CancelResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return CancelResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException catch (e) {
      return CancelResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return CancelResponse(
        status: false,
        message: e.message,
      );
    } on Exception catch (e) {
      return CancelResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return CancelResponse(
        status: false,
        message: e.toString(),
      );
    }
  }
}
