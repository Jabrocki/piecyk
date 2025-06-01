import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:piecyk/models/installation_model.dart';
import 'package:piecyk/models/panel_model.dart';
import 'package:piecyk/models/weather_model.dart';
import 'package:piecyk/providers/weather_state.dart';
import 'package:piecyk/repositories/weather_repository.dart';
import 'package:piecyk/services/firestore/installtions.dart';

class MainState extends ChangeNotifier {
  final WeatherRepository weatherRepo;
  final Logger logger;
  MainState({required this.weatherRepo, required this.logger});
  List<Installation> installations = [];

  WeatherState state = WeatherDefault();

  void listenToInstallations() {
    watchInstallationData().listen((dataList) {
      print('Received installations: $dataList');
      installations = dataList.map((data) {
        // Parse Firestore data to Installation and Panel
        final panel = Panel(
          powerWatts: data['panelPower'] ?? 0.0,
          maxVoltage: data['maximumVoltage'] ?? 0.0,
          tiltAngleDegrees: data['tilt'] ?? 0.0,
          efficiencySTC: 0.18, // or parse if stored
          areaM2: 2, // or parse if stored
          noct: 25, // or parse if stored
          temperatureCoeff: 0.004, // or parse if stored
        );
        return Installation(
          panel: panel,
          quantity: data['panelNumber'] ?? 0,
          tiltAngleDegrees: data['tilt'] ?? 0.0,
          azimuthDegrees: data['azimuth'] ?? 0.0,
        );
      }).toList();
      notifyListeners();
    });
  }

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

  /// Zwraca produkcję energii dla pierwszej instalacji z listy (jeśli istnieje)
  List<double> calculateProduction(WeatherModel weather) {
    if (installations.isNotEmpty) {
      return installations.first.calculateHourlyProduction(weather);
    }
    return [];
  }

  /// Zwraca częściowe sumy dla podanej listy energii (jeśli jest instalacja)
  List<double> calculateCumulativeSum(List<double> inputList) {
    if (installations.isNotEmpty) {
      return installations.first.cumulativeSum(inputList);
    }
    return [];
  }
}
