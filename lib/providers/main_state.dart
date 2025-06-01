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
  MainState({
    required this.weatherRepo,
    required this.locationService,
    required this.logger,
  });
  List<Installation> installations = [];

  WeatherState state = WeatherDefault();

  void listenToInstallations() {
    watchInstallationData().listen((dataList) {
      print('Received installations: $dataList');
      installations = dataList.map((data) {
        final panel = Panel(
          powerWatts: data['panelPower'] ?? 0.0,
          maxVoltage: data['maximumVoltage'] ?? 0.0,
          tiltAngleDegrees: data['tilt'] ?? 0.0,
          efficiencySTC: 0.18,
          areaM2: 2,
          noct: 25,
          temperatureCoeff: 0.004,
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

      try {
        await locationService.determinePosition();
      } catch (locationError) {
        logger.e("=== error determining location: $locationError ===\n");
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

      state = WeatherLoading();
      notifyListeners();

      
      await locationService.updateLocationFromAddress(address);

      
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

  Future<void> updateCoordinatesAndFetchWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      logger.d("=== updating coordinates: lat=$latitude, lon=$longitude ===\n");

      
      state = WeatherLoading();
      notifyListeners();

      
      locationService.updateLocationFromCoordinates(latitude, longitude);

      
      try {
        final weather = await weatherRepo.getWeatherForCurrentLocation();
        logger.d(
          "=== successfully fetched weather for updated coordinates ===\n",
        );
        state = WeatherSuccess(weather);
      } catch (weatherError) {
        logger.e(
          "=== error fetching weather after coordinate update: $weatherError ===\n",
        );
        state = WeatherError(
          "Failed to fetch weather: ${weatherError.toString()}",
        );
      }

      notifyListeners();
    } catch (e) {
      logger.e("=== error in overall coordinate update process: $e ===\n");
      state = WeatherError("Failed to update weather: ${e.toString()}");
      notifyListeners();
    }
  }

  // Zwraca produkcję energii dla pierwszej instalacji z listy (jeśli istnieje)
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

  double calculateSavingsByTariff({
    required List<WeatherModel>
    weatherModels, // lista modeli pogodowych dla każdej instalacji
    required String tariff,
  }) {
    if (installations.isEmpty) return 0.0;

    double totalSavings = 0.0;

    // Zakładamy, że weatherModels.length == installations.length
    for (int idx = 0; idx < installations.length; idx++) {
      final installation = installations[idx];
      final weather = weatherModels.length > idx
          ? weatherModels[idx]
          : weatherModels.isNotEmpty
          ? weatherModels.first
          : null;
      if (weather == null) continue;

      final hourlyKwh = installation.calculateHourlyProduction(weather);

      // Sprawdzamy, czy mamy cennik dla podanej taryfy
      if (!installation.priceTariffs.containsKey(tariff)) {
        throw ArgumentError('Nie znaleziono taryfy "$tariff" w priceTariffs.');
      }
      final List<double> tariffPrices = installation.priceTariffs[tariff]!;

      // Jeśli taryfa ma 24 ceny (na dobę), powielamy ją na cały okres danych
      List<double> pricesForPeriod;
      if (tariffPrices.length == 24 && hourlyKwh.length % 24 == 0) {
        pricesForPeriod = List.generate(
          hourlyKwh.length,
          (i) => tariffPrices[i % 24],
        );
      } else if (tariffPrices.length == hourlyKwh.length) {
        pricesForPeriod = tariffPrices;
      } else {
        throw ArgumentError(
          'Długość listy cen dla taryfy "$tariff" (${tariffPrices.length}) '
          'nie pasuje do liczby godzin produkcji (${hourlyKwh.length}).',
        );
      }

      double savings = 0.0;
      for (int i = 0; i < hourlyKwh.length; i++) {
        savings += hourlyKwh[i] * pricesForPeriod[i];
      }
      totalSavings += savings;
    }

    return totalSavings;
  }
}
