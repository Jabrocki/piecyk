import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:piecyk/providers/main_state.dart';
import 'package:piecyk/providers/weather_state.dart';
import 'package:provider/provider.dart';
import 'smooth_line_chart.dart';

class chartAndInfoVertical extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mainState = Provider.of<MainState>(context);
    if (mainState.state is WeatherSuccess) {
      final weather = (mainState.state as WeatherSuccess).weather;
      final calculatedHourlyProduction = mainState.calculateProduction(weather);
      final cumulativeHourlyProduction = mainState.calculateCumulativeSum(
        calculatedHourlyProduction,
      );

      // Check if there is any data to display
      if (cumulativeHourlyProduction.isEmpty) {
        return Center(child: Text('No installation data available.'));
      }

      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: context.theme.colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [SmoothLineChart(values: cumulativeHourlyProduction)],
        ),
      );
    } else if (mainState.state is WeatherLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return const SizedBox.shrink();
    }
  }
}
