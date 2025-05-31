import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherApiClient {
  final String apiKey;
  final String baseUrl;
  http.Client httpClient;

  WeatherApiClient({
    required this.apiKey,
    required this.baseUrl,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  final lang = "pl";
  final units = "metric";
  final exclude = "current,minutely,alerts";

  Future<Map<String, dynamic>> fetch({
    required double lat,
    required double lon,
  }) async {
    final url = Uri.parse(
      '${baseUrl}lat=$lat&lon=$lon&exclude=$exclude&units=$units&lang=$lang&appid=$apiKey',
    );

    print("=== Asking weatherAPI for response... ===\n");
    print("=== ask url: $url ===\n");
    final response = await httpClient.get(url);

    if (response.statusCode != 200) {
      print("=== Receiving response from weatherAPI failed! ===\n");
      throw Exception(
        'OpenWeather error: ${response.statusCode}\nmessage: ${response.body}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
