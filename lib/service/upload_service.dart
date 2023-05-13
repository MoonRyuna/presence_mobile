import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:http/http.dart' as http;
import 'package:presence_alpha/payload/response/upload_response.dart';

class UploadService {
  Future<UploadResponse> image(MultipartFile file, String token) async {
    print('POST: upload - image');

    String target = '${ApiConstant.baseApi}/upload/image';

    print('target: $target');

    try {
      final headers = {'Authorization': 'Bearer $token'};
      final request = http.MultipartRequest('POST', Uri.parse(target));
      request.files.add(file);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      print("ini status code ${response.statusCode}");
      if (response.statusCode == 200) {
        String data = await response.stream.bytesToString();
        print(data);

        Map<String, dynamic> responseData = jsonDecode(data);
        return UploadResponse.fromJson(responseData);
      } else {
        String data = await response.stream.bytesToString();
        final Map<String, dynamic> responseData = jsonDecode(data);
        return UploadResponse(
          status: false,
          message: responseData['message'] ?? 'Unable to fetch data',
        );
      }
    } on TimeoutException catch (e) {
      return UploadResponse(
        status: false,
        message: 'Connection timed out',
      );
    } on SocketException catch (e) {
      return UploadResponse(
        status: false,
        message: e.message,
      );
    } on Exception catch (e) {
      return UploadResponse(
        status: false,
        message: 'Failed to connect to server',
      );
    } catch (e) {
      return UploadResponse(
        status: false,
        message: e.toString(),
      );
    }
  }
}
