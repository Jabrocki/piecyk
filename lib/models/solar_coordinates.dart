import 'dart:math';

/// Struktura przechowująca wyniki obliczeń pozycji Słońca:
///
/// [zenithDegrees]  – kąt zenitalny (°) (0° = Słońce dokładnie pionowo nad nami,
///                    90° = przy horyzoncie),
/// [azimuthDegrees] – azymut Słońca (° od północy, w prawo; 0° = północ,
///                    90° = wschód, 180° = południe, 270° = zachód).
class SolarCoordinates {
  final double zenithDegrees;
  final double azimuthDegrees;

  SolarCoordinates({required this.zenithDegrees, required this.azimuthDegrees});
}

/// Klasa pomocnicza do obliczeń astronomicznych.
///
/// Zawiera funkcję `calculateSolarPosition(...)`, która dla danego
/// [dateTime] (zawierającego offset strefy w `timeZoneOffset`),
/// szerokości [latitude] i długości [longitude] geograficznej zwraca
/// przybliżone wartości kąta zenitalnego i azymutu Słońca.
///
/// Implementacja oparta na uproszczonym algorytmie NOAA/Solar Position Algorithm.
/// Dla większości zastosowań do szacowania energii paneli w rozdzielczości godzinowej
/// jest wystarczająco dokładna (błąd rzędu 0.5–1°).
class SolarCalculator {
  /// Zwraca pozycję Słońca (zenith, azimuth) w danym [dateTime], [latitude], [longitude].
  ///
  /// [dateTime] powinien być utworzony przez `DateTime.parse(...)` z ISO-8601,
  /// zawierający offset strefy (np. "2025-05-30T14:00:00+02:00").
  static SolarCoordinates calculateSolarPosition({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
  }) {
    // 1. Obliczamy Julian Day (JD) i Julian Century (T)
    //    Źródło formuł: NOAA Solar Calculator (upraszczone podejście)
    final double jd = _julianDay(dateTime.toUtc());
    final double t = (jd - 2451545.0) / 36525.0;

    // 2. Mean solar coordinates
    double L0 = _normalizeAngleDegrees(
      280.46646 + t * (36000.76983 + t * 0.0003032),
    );
    double M = 357.52911 + t * (35999.05029 - 0.0001537 * t);
    double e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t);

    // 3. Sun's equation of the center
    double Mrad = _degToRad(M);
    double C =
        (1.914602 - t * (0.004817 + 0.000014 * t)) * sin(Mrad) +
        (0.019993 - 0.000101 * t) * sin(2 * Mrad) +
        0.000289 * sin(3 * Mrad);

    // 4. Sun's true longitude
    double trueLong = L0 + C;
    double trueLongRad = _degToRad(trueLong);

    // 5. Obliquity of the ecliptic
    double U = t / 100.0;
    double eps0 =
        23 +
        (26.0 / 60.0) +
        (21.448 / 3600.0) -
        (46.8150 / 3600.0) * U -
        (0.00059 / 3600.0) * U * U +
        (0.001813 / 3600.0) * U * U * U;
    double eps0Rad = _degToRad(eps0);

    // 6. Sun's declination δ
    double sinDelta = sin(eps0Rad) * sin(trueLongRad);
    double deltaRad = asin(sinDelta);

    // 7. Equation of Time (EOT) [min]
    double y = pow(tan(eps0Rad / 2), 2).toDouble();
    double L0rad = _degToRad(L0);
    double eqTime =
        4 *
        _radToDeg(
          y * sin(2 * L0rad) -
              2 * e * sin(Mrad) +
              4 * e * y * sin(Mrad) * cos(2 * L0rad) -
              0.5 * y * y * sin(4 * L0rad) -
              1.25 * e * e * sin(2 * Mrad),
        );

    // 8. True Solar Time (TST) [min]
    //    TST = (godzina w min) + EOT + 4*(longitude - L_strefy) - 60*offset
    //    dateTime.timeZoneOffset to offset od UTC
    final double offsetMinutes = dateTime.timeZoneOffset.inMinutes
        .toDouble(); // np. +120 w CEST
    final int hour = dateTime.hour;
    final int minute = dateTime.minute;
    final int second = dateTime.second;
    final double trueSolarTimeMinutes =
        (hour * 60 + minute + second / 60.0) +
        eqTime +
        4.0 * longitude -
        offsetMinutes;

    // 9. Hour angle (HRA) [°]
    double hourAngleDeg = trueSolarTimeMinutes / 4.0 - 180.0;
    if (hourAngleDeg < -180.0) {
      hourAngleDeg += 360.0;
    }
    final double hourAngleRad = _degToRad(hourAngleDeg);

    // 10. Kąt zenitalny (θ_z) [°]
    final double latRad = _degToRad(latitude);
    final double sinLat = sin(latRad);
    final double cosLat = cos(latRad);
    final double cosZenith =
        sinLat * sinDelta + cosLat * cos(deltaRad) * cos(hourAngleRad);
    final double cosZenithClamped = cosZenith.clamp(-1.0, 1.0);
    final double zenithRad = acos(cosZenithClamped);
    final double zenithDeg = _radToDeg(zenithRad);

    // 11. Azymut Słońca (γ_sun) [° od północy, w prawo]
    //     γ_sun = (atan2(sin(HRA),
    //                    cos(HRA)*sin(lat) - tan(delta)*cos(lat)) + 180) % 360
    double azimuthRad = atan2(
      sin(hourAngleRad),
      cos(hourAngleRad) * sinLat - tan(deltaRad) * cosLat,
    );
    double azimuthDeg = (_radToDeg(azimuthRad) + 180.0) % 360.0;

    return SolarCoordinates(
      zenithDegrees: zenithDeg,
      azimuthDegrees: azimuthDeg,
    );
  }

  /// Oblicza Julian Day (JD) z [dateTime], który jest w UTC.
  ///
  /// Źródło: algorytm z "Astronomical Algorithms" J. Meeus (skrótowa wersja).
  static double _julianDay(DateTime dtUtc) {
    final int year = dtUtc.year;
    final int month = dtUtc.month;
    final int day = dtUtc.day;
    final int hour = dtUtc.hour;
    final int minute = dtUtc.minute;
    final int second = dtUtc.second;

    int Y = year;
    int M = month;
    if (M <= 2) {
      Y -= 1;
      M += 12;
    }
    final int A = (Y / 100).floor();
    final int B = 2 - A + (A / 4).floor();

    // Część dziesiętna dnia:
    final double dayFraction = (hour + minute / 60.0 + second / 3600.0) / 24.0;

    final double jd =
        (365.25 * (Y + 4716)).floor() +
        (30.6001 * (M + 1)).floor() +
        day +
        dayFraction +
        B -
        1524.5;
    return jd;
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
  static double _radToDeg(double rad) => rad * 180.0 / pi;

  /// Normalizuje kąt [0,360).
  static double _normalizeAngleDegrees(double angle) {
    double a = angle % 360.0;
    if (a < 0) a += 360.0;
    return a;
  }
}
