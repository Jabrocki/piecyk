import 'weather_model.dart';

class WeatherParser {
  static WeatherModel fromJson(Map<String, dynamic> json) {
    final hourly = json['hourly'] as Map<String, dynamic>;
    final unitsDynamic = json['hourly_units'] as Map<String, dynamic>? ?? {};
    final units = unitsDynamic.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return WeatherModel(
      time: (hourly['time']) as List<dynamic>,
      dni: (hourly['direct_normal_irradiance']) as List<dynamic>,
      dif: (hourly['diffuse_radiation']) as List<dynamic>,
      ghi: (hourly['shortwave_radiation']) as List<dynamic>,
      temp: (hourly['apparent_temperature']) as List<dynamic>,
      windSpeed: (hourly['wind_speed_100m']) as List<dynamic>,
      lat: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      lon: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: (json['timezone'] ?? "") as String,
      timezoneAbbreviation: (json['timezone_abbreviation'] ?? "") as String,
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0.0,
      units: units,
    );
  }
}
