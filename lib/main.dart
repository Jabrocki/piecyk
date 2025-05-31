import 'package:flutter/material.dart';
import 'package:piecyk/models/weather_model.dart';
import 'package:piecyk/repositories/weather_repository.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Services
import 'services/location_service.dart';
import 'services/weather_api_client.dart';

//Providers
import 'providers/main_state.dart';

//Layouts
import 'layouts/main_page.dart';

//Firebase options
import 'firebase_options.dart';

Future<void> main() async {
  final Logger logger = Logger();
  await dotenv.load(fileName: "../.env");
  // final apiKEY = dotenv.env["API_KEY"] ?? "";
  final baseURL = dotenv.env['BASE_URL'] ?? "";

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // serwisy
  final LocationService locationService = LocationService(logger: logger);
  final WeatherApiClient weatherApiClient = WeatherApiClient(
    // apiKey: apiKEY,
    logger: logger,
    baseUrl: baseURL,
  );
  // repo
  final WeatherRepository weatherRepository = WeatherRepository(
    weatherClient: weatherApiClient,
    locationClient: locationService,
  );

  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MainState())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piecyk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainPage(),
    );
  }
}
