import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationService {
  final Logger logger;

  LocationService({required this.logger});

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.e("=== location service is not permitted!===\n");
      return Future.error("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      logger.w(
        "=== location service is denied. Asking for permission to access location=== \n",
      );
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      logger.e("=== Location permissions are denied pernamently! ===\n");
      return Future.error(
        "Location permissions are permanently denied, weather cannot be checked!",
      );
    }

    logger.d("=== receiving location... ===\n");
    return await Geolocator.getCurrentPosition();
  }
}
