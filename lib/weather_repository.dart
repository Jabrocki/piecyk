import '../models/weather_model.dart';
import '../models/weather_parser.dart';

class WeatherRepository {
  final dynamic _loc;
  final dynamic _weatherClient;

  WeatherRepository(this._weatherClient, this._loc);

  // klasa pogoda do zrobienia
  Future<Weather> getWeatherForCurrentLocation() async {
    final pos = await _loc.determinePosition();
    print("=== obtained position: $pos ===\n");
    final json = await _weatherClient.fetch(
      lat: pos.latitude,
      lon: pos.longitude,
    );
    // weather parser do zrobienia
    return WeatherParser.fromJson(json);
  }
}
