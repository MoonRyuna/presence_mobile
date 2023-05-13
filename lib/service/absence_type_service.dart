import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:presence_alpha/constant/api_constant.dart';
import 'package:http/http.dart' as http;
import 'package:presence_alpha/payload/response/absence_type/all_response.dart';

class AbsenceTypeService {
  Future<AllResponse> all(String token) async {
    print('GET: absence_type - all');

    String target = '${ApiConstant.baseApi}/absence_type/all';
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
        return AllResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return AllResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException catch (e) {
      return AllResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return AllResponse(
        status: false,
        message: e.message,
      );
    } on Exception catch (e) {
      return AllResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return AllResponse(
        status: false,
        message: e.toString(),
      );
    }
  }
}
