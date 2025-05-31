class WeatherModel {
  //general data
  final List<String> time;
  final List<double> dni; //direct normal irradiance DNI W/m^2
  final List<double> dif; // diffuse solar radiation DIF W/m^2
  final List<double> ghi; // shortwave solar radiation GHI W/m^2
  final List<double> temp; // apparent_temperature °C
  final List<double>
  windSpeed; // wind speed 100m (cokolwiek znaczy 100m xd) km/h
  // precise data
  final double lat;
  final double lon;
  final String timezone;
  final String timezoneAbbreviation;
  final double elevation;
  final Map<String, String> units;

  WeatherModel({
    // general data
    required this.time,
    required this.dni,
    required this.dif,
    required this.ghi,
    required this.temp,
    required this.windSpeed,

    // precise data
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.elevation,
    required this.units,
  }) {
    final len = time.length;
    if (dni.length != len ||
        dif.length != len ||
        ghi.length != len ||
        temp.length != len ||
        windSpeed.length != len) {
      throw ArgumentError(
        'Listy dni, dif, ghi, temp i windSpeed muszą mieć taką samą długość co time.',
      );
    }
  }
}
