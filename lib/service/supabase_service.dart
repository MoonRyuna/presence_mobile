import 'dart:convert';

import 'package:presence_alpha/constant/env_constant.dart';
import 'package:http/http.dart' as http;

class SupabaseService {
  Future<void> sendLocationToSupabase(
    String userId,
    String lat,
    String lng,
    String address,
    String trackedAt,
  ) async {
    final url = '${EnvConstant.supabaseUrl}/rest/v1/user_location';
    final headers = {
      'Content-Type': 'application/json',
      'apikey': EnvConstant.supabaseKey,
      'Authorization': "Bearer ${EnvConstant.supabaseKey}"
    };

    final body = jsonEncode({
      'user_id': userId,
      'lat': lat,
      'lng': lng,
      'address': address,
      'tracked_at': trackedAt,
    });

    print('Supabase Send Location');
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 201) {
      print('Location data inserted successfully!');
    } else {
      print(
          'Failed to insert location data. Status code: ${response.statusCode}');
      print('Error message: ${response.body}');
    }
  }
}
