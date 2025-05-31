import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class WeatherApiClient {
  // final String _apiKey;
  final String baseUrl;
  final Logger logger;
  http.Client httpClient;

  WeatherApiClient( /*this._apiKey,*/ {
    required this.baseUrl,
    required this.logger,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  //latitude=50.0236&longitude=20.9879&start_date=2024-04-30&end_date=2025-04-01&hourly=temperature_2m,global_tilted_irradiance,direct_normal_irradiance,diffuse_radiation,direct_radiation&models=ecmwf_ifs&timezone=Europe%2FLondon

  final String startDate = '2024-04-30';
  final String endDate = '2025-04-01';
  final String parameters =
      'direct_normal_irradiance,diffuse_radiation,shortwave_radiation,apparent_temperature,wind_speed_100m';

  Future<Map<String, dynamic>> fetch({
    required double lat,
    required double lon,
    // required String startDate,
    // required String endDate,
  }) async {
    final url = Uri.parse(
      '${baseUrl}latitude=$lat&longtitude=$lon&start_date=$startDate&end_date=$endDate&hourly=$parameters',
    );

    logger.d("=== Asking weatherAPI for response... ===\n");
    logger.d("=== ask url: $url ===\n");
    final response = await httpClient.get(url);

    if (response.statusCode != 200) {
      logger.w("=== Receiving response from weatherAPI failed! ===\n");
      throw Exception(
        'OpenWeather error: ${response.statusCode}\nmessage: ${response.body}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
