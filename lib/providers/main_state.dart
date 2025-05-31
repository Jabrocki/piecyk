import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:piecyk/models/installation_model.dart';
import 'package:piecyk/models/panel_model.dart';
import 'package:piecyk/models/weather_model.dart';
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

  static final Panel panel1 = Panel(
    powerWatts: 1200,
    maxVoltage: 560,
    tiltAngleDegrees: 35,
    efficiencySTC: 0.18,
    areaM2: 2,
    noct: 25,
    temperatureCoeff: 0.004,
  );
  final Installation installation = Installation(
    panel: panel1,
    quantity: 5,
    tiltAngleDegrees: panel1.tiltAngleDegrees,
    azimuthDegrees: 270,
  );

  List<double> calculateProduction(WeatherModel weather) {
    return installation.calculateHourlyProduction(weather);
  }

  List<double> calculateCumulativeSum(List<double> inputList) {
    return installation.cumulativeSum(inputList);
  }
}
