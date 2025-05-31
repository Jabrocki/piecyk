import '../models/weather_model.dart';

abstract class WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherDefault extends WeatherState {}

class WeatherSuccess extends WeatherState {
  final WeatherModel weather;
  WeatherSuccess(this.weather);
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}
