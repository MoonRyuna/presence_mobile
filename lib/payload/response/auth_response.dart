import 'package:presence_alpha/model/token_model.dart';
import 'package:presence_alpha/payload/response/base_response.dart';

class AuthResponse extends BaseResponse {
  final TokenModel? data;

  AuthResponse({
    required bool status,
    required String message,
    this.data,
  }) : super(status: status, message: message);

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? TokenModel.fromJson(json['data']) : null,
    );
  }

  @override
  String toString() {
    return 'AuthResponse{ status: $status, message: $message, data: $data }';
  }
}
