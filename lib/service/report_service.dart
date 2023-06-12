import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/payload/response/base_response.dart';
import 'package:presence_alpha/payload/response/report/create_response.dart';
import 'package:presence_alpha/payload/response/report/download_response.dart';
import 'package:presence_alpha/payload/response/report/list_response.dart';
import 'package:presence_alpha/payload/response/report/rekap_detail_karyawan_response.dart';

class ReportService {
  Future<ListResponse> list(
      Map<String, dynamic> queryParams, String token) async {
    print('GET: report - list');

    String target = '${ApiConstant.baseApi}/report';
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
    } on TimeoutException {
      return ListResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return ListResponse(
        status: false,
        message: e.message,
      );
    } on Exception {
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

  Future<CreateResponse> create(
      Map<String, dynamic> requestData, String token) async {
    print('Post: report - create');

    String target = '${ApiConstant.baseApi}/report/create';
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
        return CreateResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return CreateResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException {
      return CreateResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return CreateResponse(
        status: false,
        message: e.message,
      );
    } on Exception {
      return CreateResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return CreateResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<BaseResponse> generate(int id, String token) async {
    print('Post: report - generate');

    String target = '${ApiConstant.baseApi}/report/generate/$id';
    print('target: $target');

    try {
      final response = await http.post(
        Uri.parse(target),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ).timeout(Duration(seconds: ApiConstant.timeout));

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

  Future<DownloadResponse> download(int id, String token) async {
    print('Get: report - download');

    String target = '${ApiConstant.baseApi}/report/download_excel/$id';
    print('target: $target');

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
        return DownloadResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return DownloadResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException {
      return DownloadResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return DownloadResponse(
        status: false,
        message: e.message,
      );
    } on Exception {
      return DownloadResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return DownloadResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<RekapDetailKaryawanResponse> rekapDetailKaryawan(
      Map<String, dynamic> requestData, String token) async {
    print('Post: report - rekap detail karyawan');

    String target = '${ApiConstant.baseApi}/report/rekap_detail_karyawan';
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
        return RekapDetailKaryawanResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return RekapDetailKaryawanResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException {
      return RekapDetailKaryawanResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return RekapDetailKaryawanResponse(
        status: false,
        message: e.message,
      );
    } on Exception {
      return RekapDetailKaryawanResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return RekapDetailKaryawanResponse(
        status: false,
        message: e.toString(),
      );
    }
  }
}
