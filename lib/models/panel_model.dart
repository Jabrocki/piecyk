/// Model pojedynczego modułu fotowoltaicznego.
///
/// [nominalPowerWatts]       – moc modułu w warunkach STC (W),
/// [efficiencyAtSTC]         – sprawność modułu przy STC (liczba z przedziału 0–1),
/// [surfaceAreaM2]           – powierzchnia modułu w metrach kwadratowych,
/// [noctCelsius]             – Nominal Operating Cell Temperature (°C),
/// [temperatureCoeffPerC]    – współczynnik temperaturowy mocy [%/°C] (np. 0.004 = 0,4%/°C).
///                            W kodzie traktujemy to jako dodatnią wartość, ale w formułach
///                            zawsze odejmujemy wpływ temperatury (im wyższa, tym moc mniejsza).
class Panel {
  /// Moc modułu w warunkach STC (W).
  final double nominalPowerWatts;

  /// Maksymalne napięcie modułu (V). Nie jest obecnie bezpośrednio wykorzystywane
  /// w obliczeniach energetycznych, ale może być przydatne przy doborze stringów.
  final double maxVoltage;

  /// Kąt nachylenia modułu (°) względem poziomu.
  ///
  /// Uwaga: Zwykle kąt nachylenia definiuje się na poziomie instalacji (Installation),
  /// ale można też mieć modul z fabrycznie ustalonym kątem (np. do montażu na balkonie).
  final double tiltAngleDegrees;

  /// Sprawność modułu przy STC (np. 0.18 = 18%).
  final double efficiencyAtSTC;

  /// Powierzchnia modułu (m²).
  final double surfaceAreaM2;

  /// NOCT (Nominal Operating Cell Temperature), °C.
  final double noctCelsius;

  /// Współczynnik temperaturowy mocy [%/°C], np. 0.004 = 0,4%/°C.
  final double temperatureCoeffPerC;

  Panel({
    required this.nominalPowerWatts,
    required this.maxVoltage,
    required this.tiltAngleDegrees,
    required this.efficiencyAtSTC,
    required this.surfaceAreaM2,
    required this.noctCelsius,
    required this.temperatureCoeffPerC,
  });

  /// Moc modułu w kW (STC).
  double get nominalPowerKw => nominalPowerWatts / 1000.0;
}
