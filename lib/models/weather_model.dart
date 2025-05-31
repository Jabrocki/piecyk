class WeatherModel {
  final double time;
  final double dni; //direct normal irradiance DNI W/m^2
  final double dif; // diffuse solar radiation DIF W/m^2
  final double ghi; // shortwave solar radiation GHI W/m^2
  final double temp; // apparent_temperature °C
  final double windSpeed; // wind speed 100m (cokolwiek znaczy 100m xd) km/h

  WeatherModel({
    required this.time,
    required this.dni,
    required this.dif,
    required this.ghi,
    required this.temp,
    required this.windSpeed,
  });
}
