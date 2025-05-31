import 'package:piecyk/services/weather_api_client.dart';

import '../../models/weather_model.dart';
import '../services/location_service.dart';
import '../../models/weather_parser.dart';

class WeatherRepository {
  final LocationService locationClient;
  final WeatherApiClient weatherClient;

  WeatherRepository({
    required this.weatherClient,
    required this.locationClient,
  });

  // klasa pogoda do zrobienia
  Future<WeatherModel> getWeatherForCurrentLocation() async {
    final pos = await locationClient.determinePosition();
    print("=== obtained position: $pos ===\n");
    final json = await weatherClient.fetch(
      lat: pos.latitude,
      lon: pos.longitude,
    );
    // weather parser do zrobienia
    return WeatherParser.fromJson(json);
  }
}
