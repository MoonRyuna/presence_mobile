import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:presence_alpha/constant/api_constant.dart';
import 'package:http/http.dart' as http;
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
        return ListResponse(
          status: false,
          message: 'Unable to fetch data',
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
        return SubmissionResponse(
          status: false,
          message: 'Unable to fetch data',
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
        return DetailResponse(
          status: false,
          message: 'Unable to fetch data',
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
        return ListSubmissionResponse(
          status: false,
          message: 'Unable to fetch data',
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
}
