import 'package:flutter/material.dart';
import 'package:forui/forui.dart'; // Assuming context.theme.colors.border comes from here or a similar extension
import 'package:piecyk/providers/main_state.dart';
import 'package:piecyk/providers/weather_state.dart';
import 'package:provider/provider.dart';
import 'smooth_line_chart.dart';
import 'select_date.dart';
// ... other imports

class chartAndInfoVertical extends StatelessWidget {
  const chartAndInfoVertical({super.key});

  @override
  Widget build(BuildContext context) {
    final mainState = Provider.of<MainState>(context);
    if (mainState.state is WeatherSuccess) {
      final weather = (mainState.state as WeatherSuccess).weather;
      final calculatedHourlyProduction = mainState.calculateProduction(weather);
      final cumulativeHourlyProduction = mainState.calculateCumulativeSum(
        calculatedHourlyProduction,
      );

      if (cumulativeHourlyProduction.isEmpty) {
        return Center(child: Text('No installation data available.'));
      }

      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: context.theme.colors.border,
          ), // Ensure context.theme is available
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20.0,
                left: 10.0,
                right: 10.0,
              ),
              child: SmoothLineChart(values: cumulativeHourlyProduction),
            ),
            Row(
              children: [
                Expanded(
                  flex: 8,
                  child: SelectDate()
                  ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FButton(
                    onPress: () async {
                      await context.read<MainState>().loadWeatherForCurrentLocation();
                    },
                    child: Icon(FIcons.rotateCcw),
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          ],
        ),
      );
    } else if (mainState.state is WeatherLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return const SizedBox.shrink();
    }
  }
}
