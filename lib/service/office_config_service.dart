import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/payload/response/update_office_config_response.dart';

class OfficeConfigService {
  Future<UpdateOfficeConfigResponse> updateConfig(
      Map<String, dynamic> requestData, String id, String token) async {
    print('POST: update office_config');

    String target = '${ApiConstant.baseApi}/office_config/update/$id';
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
        return UpdateOfficeConfigResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return UpdateOfficeConfigResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
          data: null,
        );
      }
    } on TimeoutException catch (e) {
      return UpdateOfficeConfigResponse(
        status: false,
        message: 'Connection timed out',
        data: null,
      );
    } on SocketException catch (e) {
      return UpdateOfficeConfigResponse(
        status: false,
        message: e.message,
        data: null,
      );
    } on Exception catch (e) {
      final error = e.toString();
      log("Exception: $error");
      return UpdateOfficeConfigResponse(
        status: false,
        message: 'Failed to connect to server',
        data: null,
      );
    } catch (e) {
      return UpdateOfficeConfigResponse(
        status: false,
        message: e.toString(),
        data: null,
      );
    }
  }
}
