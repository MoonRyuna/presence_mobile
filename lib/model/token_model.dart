class TokenModel {
  String? token;

  TokenModel({
    this.token,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      token: json['token'],
    );
  }

  String toPlain() {
    return 'TokenModel{ token: $token }';
  }
}
