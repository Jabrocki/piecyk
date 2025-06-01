import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:piecyk/models/installation_model.dart';
import 'package:piecyk/models/panel_model.dart';
import 'package:piecyk/models/weather_model.dart';
import 'package:piecyk/providers/weather_state.dart';
import 'package:piecyk/repositories/weather_repository.dart';
import 'package:piecyk/services/location_service.dart';

class MainState extends ChangeNotifier {
  final WeatherRepository weatherRepo;
  final LocationService locationService;
  final Logger logger;
  MainState({required this.weatherRepo, required this.locationService, required this.logger});

  WeatherState state = WeatherDefault();

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
