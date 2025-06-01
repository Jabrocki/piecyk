import 'dart:math';

import 'package:piecyk/models/panel_model.dart';
import 'package:piecyk/models/weather_model.dart';
import 'solar_coordinates.dart';

class Installation {
  final Panel panel;
  final int quantity;
  final double tiltAngleDegrees;
  final double azimuthDegrees;
  final double inverterEfficiency;
  final double temperatureCoeffPerDeg;

  /// Temperatura referencyjna (°C) dla współczynnika temperaturowego (zwykle 25°C).
  static const double referenceTemperature = 25.0;

  /// Współczynnik albedo terenu – przyjmujemy dla ogółu terenu 0.2 (trawa/ziemia).
  static const double defaultAlbedo = 0.2;

  final Map<String, List<double>> priceTariffs = {
    // Taryfa C11 – jednoprzedziałowa: ta sama cena we wszystkich godzinach
    'C11': List<double>.filled(24, 0.85),

    // Taryfa C12A – dwie strefy (tzw. dzienna i nocna)
    //
    // Noc: 00:00–06:00 (indeksy 0–5) oraz 22:00–24:00 (indeksy 22–23) @ 0.60 zł/kWh
    // Dzień: 06:00–22:00 (indeksy 6–21) @ 0.90 zł/kWh
    'C12A': [
      // 0–5: noc
      0.60, 0.60, 0.60, 0.60, 0.60, 0.60,
      // 6–21: dzień (16 h)
      0.90, 0.90, 0.90, 0.90, 0.90, 0.90,
      0.90, 0.90, 0.90, 0.90, 0.90, 0.90,
      0.90, 0.90,
      // 22–23: noc
      0.60, 0.60,
    ],

    // Taryfa C21 – dwie strefy (tzw. szczytowa i pozaszczytowa)
    //
    // Pozaszczyt: 00:00–07:00 (indeksy 0–6) oraz 15:00–24:00 (indeksy 15–23) @ 0.55 zł/kWh
    // Szczyt:     07:00–15:00 (indeksy 7–14)                         @ 0.95 zł/kWh
    'C21': [
      // 0–6: pozaszczyt  (7 h)
      0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55,
      // 7–14: szczyt    (8 h)
      0.95, 0.95, 0.95, 0.95, 0.95, 0.95, 0.95, 0.95,
      // 15–23: pozaszczyt (9 h)
      0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55, 0.55,
    ],

    // Taryfa C22 – trzy strefy (tzw. szczytowa, półszczytowa i pozaszczytowa)
    //
    // Pozaszczytowa  (off‐peak): 00:00–06:00 (0–5), 22:00–24:00 (22–23) @ 0.50 zł/kWh
    // Półszczytowa   (mid‐peak): 06:00–07:00 (6), 11:00–17:00 (11–16), 21:00–22:00 (21) @ 0.75 zł/kWh
    // Szczytowa      (peak):    07:00–11:00 (7–10), 17:00–21:00 (17–20)        @ 1.10 zł/kWh
    'C22': [
      // 0–5: pozaszczyt
      0.50, 0.50, 0.50, 0.50, 0.50, 0.50,
      // 6: półszczyt
      0.75,
      // 7–10: szczyt
      1.10, 1.10, 1.10, 1.10,
      // 11–16: półszczyt (6 godzin)
      0.75, 0.75, 0.75, 0.75, 0.75, 0.75,
      // 17–20: szczyt (4 godziny)
      1.10, 1.10, 1.10, 1.10,
      // 21: półszczyt
      0.75,
      // 22–23: pozaszczyt
      0.50, 0.50,
    ],
  };

  Installation({
    required this.panel,
    required this.quantity,
    required this.tiltAngleDegrees,
    required this.azimuthDegrees,
    this.inverterEfficiency = 0.98,
    double? temperatureCoeffPerDeg,
  }) : temperatureCoeffPerDeg =
           temperatureCoeffPerDeg ?? panel.temperatureCoeff;

  /// Całkowita moc nominalna instalacji w kW (STC, DC).
  ///
  /// panel.powerWatts * quantity / 1000
  double get totalPeakPowerKw => (panel.powerWatts * quantity) / 1000.0;

  /// Główna funkcja obliczeniowa:
  ///
  /// Na podstawie [weather] (dane godzinowe: dni, dif, ghi, temp, windSpeed, time)
  /// wylicza listę godzinowych produkcji energii AC (kWh) – po uwzględnieniu:
  ///  1. pozycji Słońca (kąt zenitalny, azymut) dla każdego timestampu,
  ///  2. obliczenia promieniowania na panel (POA),
  ///  3. temperatury ogniwa (model NOCT),
  ///  4. mocy DC (kW) z jednego modułu + skali ilości modułów,
  ///  5. uwzględnienia sprawności inwertera,
  ///  6. przycięcia mocy do >= 0, jeśli Słońce pod horyzontem lub w cieniu.
  ///
  /// Zwraca listę długości = weather.time.length, gdzie każdy element to
  /// energia w [kWh] wyprodukowana w danej godzinie.
  List<double> calculateHourlyProduction(WeatherModel weather) {
    final int n = weather.time.length;
    final List<double> hourlyEnergyKwh = List<double>.filled(n, 0.0);

    for (int i = 0; i < n; i++) {
      // 1. Parsujemy timestamp do DateTime (uwzględnia offset strefy)
      final dt = DateTime.parse(weather.time[i]);
      // 2. Obliczamy pozycję Słońca
      final SolarCoordinates sc = SolarCalculator.calculateSolarPosition(
        dateTime: dt,
        latitude: weather.lat,
        longitude: weather.lon,
      );
      // 3. Obliczamy promieniowanie padające na panel (POA)
      final double poaIrradiance = _calculatePoaIrradiance(
        dni: weather.dni[i],
        dif: weather.dif[i],
        ghi: weather.ghi[i],
        solarZenithDeg: sc.zenithDegrees,
        solarAzimuthDeg: sc.azimuthDegrees,
        surfaceTiltDeg: tiltAngleDegrees,
        surfaceAzimuthDeg: azimuthDegrees,
        albedo: defaultAlbedo,
      );
      // Jeżeli Słońce poniżej horyzontu, poaIrradiance może być < 0 → przycinamy do 0
      final double poa = poaIrradiance.clamp(0.0, double.infinity);

      if (poa <= 0) {
        // Brak promieniowania → brak produkcji
        hourlyEnergyKwh[i] = 0.0;
        continue;
      }

      // 4. Obliczamy temperaturę ogniwa (NOCT)
      final double tCell = _calculateCellTemperature(
        ambientTemp: weather.temp[i],
        poaGlobal: poa,
        noct: panel.noct,
        windSpeed: weather.windSpeed[i],
      );
      // 5. Sprawność modułu skorygowana temperaturą
      final double effAtTemp =
          panel.efficiencySTC *
          (1 - temperatureCoeffPerDeg * (tCell - referenceTemperature));
      // 6. Moc DC jednego modułu (kW): effAtTemp * poa [W/m²] * area [m²] / 1000
      final double pDcPerModuleKw = (effAtTemp * poa * panel.areaM2) / 1000.0;
      // 7. Cała instalacja DC (kW)
      final double pDcArrayKw = pDcPerModuleKw * quantity;
      // 8. Moc AC (kW) po inwerterze
      final double pAcKw = pDcArrayKw * inverterEfficiency;
      // 9. Energia w tej godzinie (kWh) = moc [kW] * 1h
      hourlyEnergyKwh[i] = max(0.0, pAcKw);
    }

    return hourlyEnergyKwh;
  }

  // zwraca listę częściowych sum (do wykresu)
  List<double> cumulativeSum(List<double> input) {
    final List<double> result = List<double>.filled(input.length, 0.0);
    double sum = 0.0;
    for (int i = 0; i < input.length; i++) {
      sum += input[i];
      result[i] = sum;
    }
    return result;
  }

  /// Sumuje listę godzinowych energii kWh i zwraca łączny roczny/miesięczny/etc. uzysk.
  double sumTotalEnergy(List<double> hourlyEnergyKwh) {
    return hourlyEnergyKwh.fold(0.0, (sum, e) => sum + e);
  }

  /// Oblicza irradiancję POA (plane-of-array) [W/m²]
  /// na podstawie podanych składowych:
  ///  - dni (W/m²),
  ///  - dif (W/m²),
  ///  - ghi (W/m²),
  ///  - kąt zenitalny Słońca (°),
  ///  - azymut Słońca (°),
  ///  - kąt nachylenia panelu (°),
  ///  - azymut panelu (°),
  ///  - albedo (domyślnie 0.2).
  double _calculatePoaIrradiance({
    required double dni,
    required double dif,
    required double ghi,
    required double solarZenithDeg,
    required double solarAzimuthDeg,
    required double surfaceTiltDeg,
    required double surfaceAzimuthDeg,
    required double albedo,
  }) {
    // Konwersja na radiany
    final double zenithRad = solarZenithDeg * pi / 180.0;
    final double solarAzRad = solarAzimuthDeg * pi / 180.0;
    final double tiltRad = surfaceTiltDeg * pi / 180.0;
    final double surfAzRad = surfaceAzimuthDeg * pi / 180.0;

    // 1) Składowa bezpośrednia (beam) na POA:
    //    I_b_POA = DNI * cos(theta_i)
    //    cos(theta_i) = cos(zenith)*cos(tilt)
    //                   + sin(zenith)*sin(tilt)*cos(azimuth_sun - azimuth_panel)
    double cosIncidence =
        cos(zenithRad) * cos(tiltRad) +
        sin(zenithRad) * sin(tiltRad) * cos(solarAzRad - surfAzRad);
    if (cosIncidence < 0) {
      cosIncidence = 0.0;
    }
    final double iBpoa = dni * cosIncidence;

    // 2) Składowa rozproszona (diffuse) – model izotropowy:
    //    I_d_POA = DHI * (1 + cos(beta)) / 2
    final double iDpoa = dif * (1 + cos(tiltRad)) / 2.0;

    // 3) Składowa odbita (albedo):
    //    I_r_POA = GHI * albedo * (1 - cos(beta)) / 2
    final double iRpoa = ghi * albedo * (1 - cos(tiltRad)) / 2.0;

    // 4) Suma:
    final double poaGlobal = iBpoa + iDpoa + iRpoa;
    return poaGlobal;
  }

  double _calculateCellTemperature({
    required double ambientTemp,
    required double poaGlobal,
    required double noct,
    required double windSpeed,
  }) {
    return ambientTemp + (poaGlobal / 800.0) * (noct - 20.0);
  }

  double calculateSavingsByTariff({
    required List<double> hourlyKwh,
    required String tariff,
  }) {
    // Sprawdzamy, czy mamy cennik dla podanej taryfy
    if (!priceTariffs.containsKey(tariff)) {
      throw ArgumentError('Nie znaleziono taryfy "$tariff" w priceTariffs.');
    }
    final List<double> tariffPrices = priceTariffs[tariff]!;

    // 3. Sprawdzamy, czy długość listy cen się zgadza z liczbą godzin w danych
    if (tariffPrices.length != hourlyKwh.length) {
      throw ArgumentError(
        'Długość listy cen dla taryfy "$tariff" (${tariffPrices.length}) '
        'różni się od liczby pomiarów pogodowych (${hourlyKwh.length}).',
      );
    }

    // 4. Sumujemy: każda godzina -> kWh × cena
    double totalSavings = 0.0;
    for (int i = 0; i < hourlyKwh.length; i++) {
      totalSavings += hourlyKwh[i] * tariffPrices[i];
    }
    return totalSavings;
  }
}
