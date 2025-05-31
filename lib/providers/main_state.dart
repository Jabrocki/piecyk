import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:piecyk/providers/weather_state.dart';
import 'package:piecyk/repositories/weather_repository.dart';

class MainState extends ChangeNotifier {
  final WeatherRepository weatherRepo;
  final Logger logger;
  MainState({required this.weatherRepo, required this.logger});

  WeatherState state = WeatherDefault();

  Future<void> loadWeatherForCurrentLocation() async {
    try {
      logger.d("=== state: loading ===\n");
      state = WeatherLoading();
      notifyListeners();

      final weather = await weatherRepo.getWeatherForCurrentLocation();
      logger.d("=== state: success ===\n");
      state = WeatherSuccess(weather);
    } catch (e) {
      logger.e(e.toString());
      state = WeatherError(e.toString());
    }
    notifyListeners();
  }
}
