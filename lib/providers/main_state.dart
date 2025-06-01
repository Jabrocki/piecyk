import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:piecyk/models/installation_model.dart';
import 'package:piecyk/models/panel_model.dart';
import 'package:piecyk/models/weather_model.dart';
import 'package:piecyk/providers/weather_state.dart';
import 'package:piecyk/repositories/weather_repository.dart';
import 'package:piecyk/services/location_service.dart';
import 'package:piecyk/services/firestore/installtions.dart';

class MainState extends ChangeNotifier {
  final WeatherRepository weatherRepo;
  final LocationService locationService;
  final Logger logger;
  MainState({required this.weatherRepo, required this.locationService, required this.logger});
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

      // First make sure we have a location
      try {
        await locationService.determinePosition();
      } catch (locationError) {
        logger.e("=== error determining location: $locationError ===\n");
        // Continue with the weather fetch - it will try to get location again if needed
      }

      final weather = await weatherRepo.getWeatherForCurrentLocation();
      logger.d("=== state: success ===\n");
      state = WeatherSuccess(weather);
    } catch (e) {
      logger.e(e.toString());
      state = WeatherError(e.toString());
    }
    notifyListeners();
  }

  Future<void> updateAddressAndFetchWeather(String address) async {
    try {
      logger.d("=== updating address: $address ===\\n");
      
      // Set loading state to indicate something is happening
      state = WeatherLoading();
      notifyListeners();
      
      // Update location from address - this should handle city names or coordinates
      await locationService.updateLocationFromAddress(address);
      
      // After updating location, simply load weather for the current location
      final weather = await weatherRepo.getWeatherForCurrentLocation();
      logger.d("=== successfully fetched weather after location update ===\\n");
      state = WeatherSuccess(weather);
      notifyListeners();
    } catch (e) {
      logger.e("=== error updating address and fetching weather: $e ===\\n");
      state = WeatherError("Failed to update weather: ${e.toString()}");
      notifyListeners();
    }
  }

  Future<void> updateCoordinatesAndFetchWeather(double latitude, double longitude) async {
    try {
      logger.d("=== updating coordinates: lat=$latitude, lon=$longitude ===\n");
      
      // Set loading state while we update coordinates
      state = WeatherLoading();
      notifyListeners();
      
      // Update coordinates directly - this should always succeed
      locationService.updateLocationFromCoordinates(latitude, longitude);
      
      // Get weather for the new coordinates
      try {
        final weather = await weatherRepo.getWeatherForCurrentLocation();
        logger.d("=== successfully fetched weather for updated coordinates ===\n");
        state = WeatherSuccess(weather);
      } catch (weatherError) {
        logger.e("=== error fetching weather after coordinate update: $weatherError ===\n");
        state = WeatherError("Failed to fetch weather: ${weatherError.toString()}");
      }
      
      notifyListeners();
    } catch (e) {
      logger.e("=== error in overall coordinate update process: $e ===\n");
      state = WeatherError("Failed to update weather: ${e.toString()}");
      notifyListeners();
    }
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
