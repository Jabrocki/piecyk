import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:piecyk/providers/main_state.dart';
import 'package:piecyk/services/csv/forecasting.dart';
import 'package:piecyk/services/csv/instalation.dart';
import 'package:piecyk/theme/general_style.dart';
import 'package:piecyk/widgets/device_info_collumn.dart';
import 'package:piecyk/widgets/location_changer.dart';
import 'package:piecyk/widgets/sidebar.dart';
import 'package:piecyk/widgets/main_page_resizable.dart';
import 'package:piecyk/widgets/title_widget.dart';
import 'package:provider/provider.dart';
import 'package:piecyk/providers/theme_provider.dart';
import 'package:piecyk/providers/toggle_menu_state.dart';
import 'package:piecyk/theme/forui_theme_adapter.dart'; // Import the adapter
import '../services/firestore/location.dart';
import 'package:piecyk/providers/weather_state.dart'; // Import WeatherState for WeatherSuccess

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    // Ensure the location is determined and then load weather
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationData = await downloadLocationData();
      if (locationData != null) {
        // Update location in LocationService using Firestore data
        final latitude = locationData['latitude'] as double?;
        final longitude = locationData['longitude'] as double?;
        if (latitude != null && longitude != null) {
          context
              .read<MainState>()
              .locationService
              .updateLocationFromCoordinates(latitude, longitude);
        }
      } else {
        // If no document exists, call loadWeatherForCurrentLocation
        await context.read<MainState>().loadWeatherForCurrentLocation();
      }
    });
    context.read<MainState>().listenToInstallations();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final toggleMenuState = Provider.of<ToggleMenuState>(context);
    // Determine which FColors to use based on the current theme.
    final FColors currentFColors = themeProvider.isDarkMode
        ? darkFColors
        : lightFColors;
    final FStyle style = FTheme.of(
      context,
    ).style; // Assuming FStyle doesn't need to change or is handled elsewhere.
    final tarrifs = ["C22", "C21", "C12A", "C11"];

    return FTheme(
      data: FThemeData(colors: currentFColors, style: style),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          child: FScaffold(
            scaffoldStyle: generalStyle(colors: currentFColors, style: style),
            header: const FHeader(title: TitleWidget()),
            childPad: true,
            sidebar: MainSidebar(
              onDownloadDataPressed: (_) => toggleMenuState.toggleMenu(),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    children: <Widget>[
                      LocationChanger(),
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            const SizedBox(width: 10),
                            Expanded(child: DeviceInfoCollumn()),
                            const SizedBox(width: 15),
                            Expanded(child: chartAndInfoVertical()),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 500,
                  ), // Increased duration for smoother animation
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation, // Add fading effect
                          child: child,
                        );
                      },
                  child: toggleMenuState.isMenuVisible
                      ? Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: 300,
                          child: SizedBox(
                            width: 400,
                            height: 200,
                            child: FCard(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 30),
                                    FButton(
                                      onPress: downloadInstallationCSV, 
                                      child: Row(
                                        children: [
                                          Icon(FIcons.cable),
                                          SizedBox(width: 10),
                                          Text("Download Instalation Data"),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    FButton(
                                      onPress: () {
                                        final mainState = context.read<MainState>();
                                        if (mainState.state is WeatherSuccess) {
                                          final weather = (mainState.state as WeatherSuccess).weather;
                                          downloadForecastingCSV(mainState, weather); // Pass MainState and WeatherModel
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Weather data not available")),
                                          );
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(FIcons.chartLine),
                                          SizedBox(width: 10),
                                          Text("Download Forecasting"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
