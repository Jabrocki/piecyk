import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'package:geocode/geocode.dart'; // Added geocode package

class LocationService {
  final Logger logger;
  final GeoCode geoCode = GeoCode(); // Initialize GeoCode
  Position? _currentPosition;
  bool _isManuallySet = false; // Flag to track if location was manually set

  LocationService({required this.logger});

  Position? get currentPosition => _currentPosition;

  Future<Position> determinePosition() async {
    // If a location was manually set and is available, use it.
    if (_isManuallySet && _currentPosition != null) {
      logger.d("=== using manually set location: $_currentPosition ===\\\\n");
      return _currentPosition!;
    }

    // Proceed to determine location automatically. Any manual setting is now overridden.
    _isManuallySet = false;
    logger.d("=== determining automatic location (_isManuallySet reset to false) ===\\\\n");

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.e("=== location service is not permitted!===\\\\n");
      _currentPosition = null;
      return Future.error("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      logger.w(
        "=== location service is denied. Asking for permission to access location=== \\\\n",
      );
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _currentPosition = null;
        return Future.error("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      logger.e("=== Location permissions are denied pernamently! ===\\\\n");
      _currentPosition = null;
      return Future.error(
        "Location permissions are permanently denied, weather cannot be checked!",
      );
    }

    logger.d("=== receiving location... ===\\\\n");
    _currentPosition = await Geolocator.getCurrentPosition();
    return _currentPosition!;
  }

  Future<void> updateLocationFromAddress(String address) async {
    logger.d("=== attempting to process address: '$address' ===\\\\n");
    
    if (address.isEmpty) {
      logger.w("=== empty address provided ===\\\\n");
      // Optionally throw an error here if empty address is considered a failure
      // For now, just returning as it won't update the location.
      return;
    }
    
    // First, try to extract coordinates directly from the address string
    if (_tryExtractCoordinatesFromAddress(address)) {
      logger.d("=== successfully extracted coordinates directly from address string ===\\\\n");
      return; // Successfully updated from direct coordinates
    }
    
    // If direct extraction fails, use the geocode package
    logger.d("=== attempting geocoding with geocode package for address: '$address' ===\\\\n");
    try {
      Coordinates coordinates = await geoCode.forwardGeocoding(address: address);
      if (coordinates.latitude != null && coordinates.longitude != null) {
        _currentPosition = Position(
          latitude: coordinates.latitude!,
          longitude: coordinates.longitude!,
          timestamp: DateTime.now(),
          accuracy: 0.0, // Geocoded positions don't have GPS accuracy
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        _isManuallySet = true;
        logger.d("=== location geocoded and manually set: $_currentPosition ===\\\\n");
        return; // Successfully updated from geocoding
      } else {
        final String errorMessage = "Geocoding failed: No coordinates found for '$address'";
        logger.w("=== $errorMessage ===\\\\n");
        throw Exception(errorMessage);
      }
    } catch (e) {
      final String errorMessage = "Geocoding error for '$address': ${e.toString()}";
      logger.e("=== $errorMessage ===\\\\nStack trace: ${StackTrace.current}");
      throw Exception(errorMessage); // Re-throw or wrap to ensure it propagates
    }
  }

  // Method to directly update location with coordinates
  void updateLocationFromCoordinates(double latitude, double longitude) {
    // Create a fresh Position object
    _currentPosition = Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0.0, // Direct input doesn't provide accuracy information
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
    
    // Set the flag to ensure this manually set location is used
    _isManuallySet = true;
    
    logger.d("=== location manually set to: lat=$latitude, lon=$longitude ===\\\\n");
  }

  // Method to try to extract coordinates from an address string
  bool _tryExtractCoordinatesFromAddress(String address) {
    // Check for patterns like "50.26, 19.02" or "50.26 19.02" in the input
    logger.d("=== trying to extract coordinates from address string ===\\\\n");
    
    // Remove any parentheses or brackets
    String cleaned = address.replaceAll(RegExp(r'[\(\)\[\]]'), '');
    
    // Split by common separators
    List<String> parts = cleaned.split(RegExp(r'[,\s]+'));
    
    if (parts.length >= 2) {
      try {
        // Try to parse the first two parts as doubles
        double? lat = double.tryParse(parts[0]);
        double? lon = double.tryParse(parts[1]);
        
        if (lat != null && lon != null) {
          // If parsing succeeded, use these as coordinates
          logger.d("=== extracted coordinates from string: lat=$lat, lon=$lon ===\\\\n");
          updateLocationFromCoordinates(lat, lon);
          return true;
        }
      } catch (e) {
        logger.d("=== failed to extract coordinates: $e ===\\\\n");
      }
    }
    
    // Try to extract coordinates in other formats
    try {
      // Try to match patterns like "latitude: 50.26, longitude: 19.02"
      RegExp coordPattern = RegExp(r'(?:lat(?:itude)?[\s:=]+)?([-+]?\d+\.?\d*)[\s,]+(?:lon(?:gitude)?[\s:=]+)?([-+]?\d+\.?\d*)', caseSensitive: false);
      Match? match = coordPattern.firstMatch(address);
      
      if (match != null && match.groupCount >= 2) {
        double? lat = double.tryParse(match.group(1)!);
        double? lon = double.tryParse(match.group(2)!);
        
        if (lat != null && lon != null) {
          logger.d("=== extracted coordinates from pattern: lat=$lat, lon=$lon ===\\\\n");
          updateLocationFromCoordinates(lat, lon);
          return true;
        }
      }
    } catch (e) {
      logger.d("=== failed to extract coordinates with pattern: $e ===\\\\n");
    }
    
    return false;
  }
}
