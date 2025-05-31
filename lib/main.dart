import 'package:flutter/material.dart';
// import 'package:piecyk/models/weather_model.dart';
import 'package:piecyk/providers/login_state.dart';
import 'package:piecyk/repositories/weather_repository.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Services
import 'services/location_service.dart';
import 'services/weather_api_client.dart';

//Providers
import 'providers/main_state.dart';
import 'package:piecyk/providers/theme_provider.dart'; // Added import

//Layouts
import 'layouts/main_page.dart';
import 'layouts/login_page.dart';

//Firebase options
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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

  // WeatherModel weatherData = await weatherRepository
  //     .getWeatherForCurrentLocation();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              MainState(weatherRepo: weatherRepository, logger: logger),
        ),
        ChangeNotifierProvider(create: (_) => LoginState()),
        ChangeNotifierProvider( // Added ThemeProvider
          create: (_) => ThemeProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access ThemeProvider
    return MaterialApp(
      title: 'Piecyk',
      theme: themeProvider.themeData, // Use theme from ThemeProvider
      // theme: ThemeData(  // Removed old theme
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      // ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          late Widget page;
          if (snapshot.hasData) {
            page = MainPage();
          } else {
            page = LoginPage();
          }
          return page;
        },
      ),
    );
  }
}
