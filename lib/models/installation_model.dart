import 'dart:math';

import 'package:piecyk/models/panel_model.dart';
import 'package:piecyk/models/weather_model.dart';
import 'solar_coordinates.dart';

/// Model instalacji PV składającej się z [panelCount] modułów typu [panel].
///
/// [tiltAngleDeg]         – kąt nachylenia paneli względem poziomu (°),
/// [azimuthDeg]           – azymut instalacji (° od północy, południe = 180°),
/// [inverterEfficiency]   – sprawność inwertera (domyślnie 0.98 = 98%),
/// [referenceTemperature] – temperatura referencyjna (°C), zwykle 25°C.
/// [temperatureCoeffPerDeg] – współczynnik temperaturowy mocy (%/°C, np. 0.004).
class Installation {
  final Panel panel;
  final int panelCount;
  final double tiltAngleDeg;
  final double azimuthDeg;
  final double inverterEfficiency;
  final double temperatureCoeffPerDeg;

  /// Temperatura referencyjna (°C) dla współczynnika temperaturowego (zwykle 25°C).
  static const double referenceTemperature = 25.0;

  /// Współczynnik albedo terenu – domyślnie 0.2 (trawa/ziemia).
  static const double defaultAlbedo = 0.2;

  Installation({
    required this.panel,
    required this.panelCount,
    required this.tiltAngleDeg,
    required this.azimuthDeg,
    this.inverterEfficiency = 0.98,
    double? temperatureCoeffPerDeg,
  }) : temperatureCoeffPerDeg =
           temperatureCoeffPerDeg ?? panel.temperatureCoeffPerC;

  /// Całkowita moc nominalna instalacji w kW (STC, DC).
  ///
  /// panel.powerWatts * panelCount / 1000
  double get totalPeakPowerKw => (panel.nominalPowerKw * panelCount) / 1000.0;

  /// Główna funkcja obliczeniowa:
  ///
  /// Na podstawie [weather] (dane godzinowe: dni, dif, ghi, temp, windSpeed, time)
  /// wylicza listę godzinowych produkcji energii AC (kWh) – po uwzględnieniu:
  ///  1. pozycji Słońca (kąt zenitalny, azymut) dla każdego czasu,
  ///  2. obliczenia promieniowania na panel (POA),
  ///  3. temperatury ogniwa (model NOCT),
  ///  4. mocy DC (kW) z jednego modułu + skali ilości modułów,
  ///  5. sprawności inwertera,
  ///  6. przycięcia mocy do >= 0, jeśli Słońce pod horyzontem lub w cieniu.
  ///
  /// Zwraca listę długości = weather.time.length, gdzie każdy element to
  /// energia w [kWh] wyprodukowana w danej godzinie.
  List<double> calculateHourlyProduction(WeatherModel weather) {
    final int hoursCount = weather.time.length;
    final List<double> hourlyEnergyKwh = List<double>.filled(hoursCount, 0.0);

    for (int i = 0; i < hoursCount; i++) {
      // 1. Parsujemy timestamp do DateTime (uwzględnia strefę czasową)
      final dateTime = DateTime.parse(weather.time[i]);
      // 2. Obliczamy pozycję Słońca
      final SolarCoordinates sunPosition =
          SolarCalculator.calculateSolarPosition(
            dateTime: dateTime,
            latitude: weather.lat,
            longitude: weather.lon,
          );
      // 3. Obliczamy promieniowanie padające na panel (POA)
      final double poaIrradiance = _calculatePoaIrradiance(
        dni: weather.dni[i],
        dif: weather.dif[i],
        ghi: weather.ghi[i],
        solarZenithDeg: sunPosition.zenithAngleDeg,
        solarAzimuthDeg: sunPosition.azimuthAngleDeg,
        surfaceTiltDeg: tiltAngleDeg,
        surfaceAzimuthDeg: azimuthDeg,
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
      final double cellTemperature = _calculateCellTemperature(
        ambientTemp: weather.temp[i],
        poaGlobal: poa,
        noct: panel.noctCelsius,
        windSpeed: weather.windSpeed[i],
      );
      // 5. Sprawność modułu skorygowana temperaturą
      final double moduleEfficiencyAtTemp =
          panel.efficiencyAtSTC *
          (1 -
              temperatureCoeffPerDeg *
                  (cellTemperature - referenceTemperature));
      // 6. Moc DC jednego modułu (kW): effAtTemp * poa [W/m²] * area [m²] / 1000
      final double dcPowerPerModuleKw =
          (moduleEfficiencyAtTemp * poa * panel.surfaceAreaM2) / 1000.0;
      // 7. Cała instalacja DC (kW)
      final double dcPowerArrayKw = dcPowerPerModuleKw * panelCount;
      // 8. Moc AC (kW) po inwerterze
      final double acPowerKw = dcPowerArrayKw * inverterEfficiency;
      // 9. Energia w tej godzinie (kWh) = moc [kW] * 1h
      hourlyEnergyKwh[i] = max(0.0, acPowerKw);
    }

    return hourlyEnergyKwh;
  }

  /// Sumuje listę godzinowych energii kWh i zwraca łączny uzysk (np. roczny).
  double sumAnnualEnergy(List<double> hourlyEnergyKwh) {
    return hourlyEnergyKwh.fold(0.0, (sum, e) => sum + e);
  }

  /// Oblicza irradiancję POA (plane-of-array) [W/m²]
  /// na podstawie podanych składowych:
  ///  - dni (W/m²) – promieniowanie bezpośrednie,
  ///  - dif (W/m²) – promieniowanie rozproszone,
  ///  - ghi (W/m²) – całkowite promieniowanie na poziomie,
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
    final double directOnPanel = dni * cosIncidence;

    // 2) Składowa rozproszona (diffuse) – model izotropowy:
    //    I_d_POA = DHI * (1 + cos(beta)) / 2
    final double diffuseOnPanel = dif * (1 + cos(tiltRad)) / 2.0;

    // 3) Składowa odbita (albedo):
    //    I_r_POA = GHI * albedo * (1 - cos(beta)) / 2
    final double reflectedOnPanel = ghi * albedo * (1 - cos(tiltRad)) / 2.0;

    // 4) Suma:
    final double poaGlobal = directOnPanel + diffuseOnPanel + reflectedOnPanel;
    return poaGlobal;
  }

  /// Oblicza temperaturę ogniwa PV na podstawie temperatury otoczenia,
  /// promieniowania na panelu, parametru NOCT oraz prędkości wiatru.
  double _calculateCellTemperature({
    required double ambientTemp,
    required double poaGlobal,
    required double noct,
    required double windSpeed,
  }) {
    // uproszczony model: temp ogniwa = temp otoczenia + wpływ promieniowania
    return ambientTemp + (poaGlobal / 800.0) * (noct - 20.0);
  }
}
