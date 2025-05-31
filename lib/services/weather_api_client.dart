import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
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
  String _startDate = "2024-05-01";
  String _endDate = "2024-05-02";
  // getters for dates
  String get startDate => _startDate;
  String get endDate => _endDate;
  // setters for dates
  set startDate(String value) {
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      _startDate = value;
    } else {
      throw FormatException(
        'Incorrect date dormat: $value, expected YYYY-MM-DD',
      );
    }
  }

  set endDate(String value) {
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      _endDate = value;
    } else {
      throw FormatException(
        'Incorrect date dormat: $value, expected YYYY-MM-DD',
      );
    }
  }

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
