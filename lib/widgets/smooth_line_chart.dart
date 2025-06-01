import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:piecyk/theme/light_theme.dart';
import 'package:piecyk/theme/dark_theme.dart';
import 'package:piecyk/services/weather_api_client.dart';

class SmoothLineChart extends StatelessWidget {
  final List<double> values;

  const SmoothLineChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    // Limit to max 15 points
    int maxPoints = 15;
    int step = (values.length / maxPoints).ceil();
    if (step < 1) step = 1;

    // Downsample data for chart
    final List<FlSpot> spots = [
      for (int i = 0; i < values.length; i += step)
        FlSpot(i.toDouble(), values[i]),
    ];

    // For axis scaling, use only the displayed points
    final yValues = spots.map((e) => e.y).toList();
    final minY = yValues.isEmpty
        ? 0.0
        : yValues.reduce((a, b) => a < b ? a : b) * 0.9;
    final maxY = yValues.isEmpty
        ? 1.0
        : yValues.reduce((a, b) => a > b ? a : b) * 1.1;

    // Prepare X axis labels as date range
    String xAxisLabel = 'index';
    if (values.length > 1) {
      //final now = DateTime.now();
      final start = WeatherApiClient.startDate;
      final end = WeatherApiClient.endDate;
      final df = DateFormat('yyyy-MM-dd');
      xAxisLabel = '$start — $end';
    }

    final lineChartData = LineChartData(
      minX: spots.isEmpty ? 0 : spots.first.x,
      maxX: spots.isEmpty ? 1 : spots.last.x,
      minY: minY,
      maxY: maxY,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          axisNameWidget: Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Text(
              xAxisLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 1,
            getTitlesWidget: (value, meta) {
              // Show label for first, last, and every 2nd point if few points
              if (value == spots.first.x ||
                  value == spots.last.x ||
                  (spots.length <= 8 && value % 2 == 0)) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(top: 0.0),
            child: Text(
              'power [kW]',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(2),
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        horizontalInterval: yValues.isEmpty || minY == maxY
            ? 1
            : (maxY - minY) / 5,
        drawVerticalLine: false,
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(width: 1),
          bottom: BorderSide(width: 1),
          top: BorderSide(width: 0),
          right: BorderSide(width: 0),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.5,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 3,
          dotData: FlDotData(
            show: spots.length <= 15,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).colorScheme.onBackground,
                  strokeWidth: 0,
                ),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(aspectRatio: 1.7, child: LineChart(lineChartData)),
    );
  }
}
