class ApiConstant {
  static String baseUrl = "http://192.168.8.108:3000";
  static String path = "api/v1";
  static String baseApi = '$baseUrl/$path';

  static List<String> tokenInvalidMessage = [
    'token:is invalid',
    'user:not found (token invalid)',
    'token:is invalid'
  ];
}
