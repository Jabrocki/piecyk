import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class WeatherApiClient {
  final Logger logger;
  final String baseUrl;
  http.Client httpClient;

  WeatherApiClient({
    // required this.apiKey,
    required this.logger,
    required this.baseUrl,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  // TEMPORARILY fixed values of {start,end}date and parameters in json

  static DateTime startDateTime = DateTime.now().subtract(const Duration(days: 36));
  static DateTime endDateTime = DateTime.now().subtract(const Duration(days: 6));

  static String startDate = DateFormat(
    'yyyy-MM-dd',
  ).format(startDateTime);
  static String endDate = DateFormat(
    'yyyy-MM-dd',
  ).format(endDateTime);
  // date setters
  static set setStartDate(String value) {
    startDate = value;
  }

  static set setEndDate(String value) {
    endDate = value;
  }
  // date getters

  final String parameters =
      "direct_normal_irradiance,diffuse_radiation,shortwave_radiation,apparent_temperature,wind_speed_100m";

  Future<Map<String, dynamic>> fetch({
    required double lat,
    required double lon,
  }) async {
    final url = Uri.parse(
      '${baseUrl}latitude=$lat&longitude=$lon&start_date=$startDate&end_date=$endDate&hourly=$parameters',
    );

    logger.d("=== Asking weatherAPI for response... ===\n");
    logger.d("=== ask url: $url ===\n");
    final response = await httpClient.get(url);

    if (response.statusCode != 200) {
      logger.e("=== Receiving response from weatherAPI failed! ===\n");
      throw Exception(
        'OpenWeather error: ${response.statusCode}\nmessage: ${response.body}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
