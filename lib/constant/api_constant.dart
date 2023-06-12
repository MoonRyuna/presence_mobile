class ApiConstant {
  // static String baseUrl = "http://149.28.151.15:3000";
  static String baseUrl = "http://192.168.8.108:3000";
  static String path = "api/v1";
  static String baseApi = '$baseUrl/$path';
  static int timeout = 10;

  static List<String> tokenInvalidMessage = [
    'token:is invalid',
    'user:not found (token invalid)',
    'token:is invalid'
  ];

  static String publicPath = "public";
  static String publicUrl = '$baseUrl/$publicPath';

  static List<String> role = [
    "karyawan",
    "hrd",
    "admin",
  ];
}
