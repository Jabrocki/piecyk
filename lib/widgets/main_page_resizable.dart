import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:piecyk/models/weather_model.dart';
import 'package:piecyk/providers/main_state.dart';
import 'package:piecyk/providers/weather_state.dart';
import 'package:provider/provider.dart';
import 'smooth_line_chart.dart';
import 'package:piecyk/widgets/circular_chart.dart'; // Import the circular chart
import 'package:piecyk/widgets/select_date.dart';
import 'package:piecyk/widgets/vertical_button_list.dart'; // Import the vertical button list

class chartAndInfoVertical extends StatelessWidget {
  Widget build(BuildContext context) {
    final mainState = Provider.of<MainState>(context);
    if (mainState.state is WeatherSuccess) {
      final weather = (mainState.state as WeatherSuccess).weather;
      final calculatedHourlyProduction = mainState.calculateProduction(weather);
      final cumulativeHourlyProduction = mainState.calculateCumulativeSum(
        calculatedHourlyProduction,
      );

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
      return SizedBox.shrink();
    } else {
      return SizedBox.shrink();
    }
  }
}
