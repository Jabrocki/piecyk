/// Model pojedynczego modułu fotowoltaicznego.
///
/// [powerWatts]       – moc modułu w warunkach STC (W),
/// [efficiencySTC]    – sprawność modułu przy STC (liczba z przedziału 0–1),
/// [areaM2]           – powierzchnia modułu w metrach kwadratowych,
/// [noct]             – Nominal Operating Cell Temperature (°C),
/// [temperatureCoeff] – współczynnik temperaturowy mocy [%/°C] (np. 0.004 = 0,4%/°C).
///                      W kodzie traktujemy to jako dodatnią wartość, ale w formułach
///                      zawsze odejmujemy wpływ temperatury (im wyższa, tym moc mniejsza).
class Panel {
  /// Moc modułu w warunkach STC (W).
  final double powerWatts;

  /// Maksymalne napięcie modułu (V). Nie jest obecnie bezpośrednio wykorzystywane
  /// w obliczeniach energetycznych, ale może być przydatne przy doborze stringów.
  final double maxVoltage;

  /// Kąt nachylenia modułu (°) względem poziomu.
  ///
  /// Uwaga: Zwykle kąt nachylenia definiuje się na poziomie instalacji (Installation),
  /// ale można też mieć modul z fabrycznie ustalonym kątem (np. do montażu na balkonie).
  final double tiltAngleDegrees;

  /// Sprawność modułu przy STC (np. 0.18 = 18%).
  final double efficiencySTC;

  /// Powierzchnia modułu (m²).
  final double areaM2;

  /// NOCT (Nominal Operating Cell Temperature), °C.
  final double noct;

  /// Współczynnik temperaturowy mocy [%/°C], np. 0.004 = 0,4%/°C.
  final double temperatureCoeff;

  Panel({
    required this.powerWatts,
    required this.maxVoltage,
    required this.tiltAngleDegrees,
    required this.efficiencySTC,
    required this.areaM2,
    required this.noct,
    required this.temperatureCoeff,
  });

  /// Moc modułu w kW (STC).
  double get powerKw => powerWatts / 1000.0;
}
