import 'weather_model.dart';

class WeatherParser {
  static WeatherModel fromJson(Map<String, dynamic> json) {
    final hourly = json['hourly'] as Map<String, dynamic>;
    return WeatherModel(
      time: (hourly['time']) as List<String>,
      dni: (hourly['direct_normal_irradiance']) as List<double>,
      dif: (hourly['diffuse_radiation']) as List<double>,
      ghi: (hourly['shortwave_radiation']) as List<double>,
      temp: (hourly['apparent_temperature']) as List<double>,
      windSpeed: (hourly['wind_speed_100m']) as List<double>,
      lat: (json['latitude'] as num).toDouble(),
      long: (json['longituge'] as num).toDouble(),
      timezone: (json['timezon']) as String,
      timezoneAbbreviation: (json['timezone_abbreviation']) as String,
      elevation: (json['elevation'] as num).toDouble(),
      units: (json['hourly_units']) as Map<String, String>,
    );
  }
}
