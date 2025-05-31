import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Added import

class CircularChart extends StatefulWidget {
  final List<ChartData> data;
  final double holeRadius; // This will now represent the radius of the center space

  const CircularChart({
    super.key,
    required this.data,
    this.holeRadius = 20.0, // Default to a pixel value for center space
  });

  @override
  State<CircularChart> createState() => _CircularChartState();
}

class _CircularChartState extends State<CircularChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final totalValue = widget.data.fold<double>(0, (sum, item) => sum + item.value);

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _hoveredIndex = -1;
                return;
              }
              _hoveredIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: widget.holeRadius,
        sections: widget.data.asMap().entries.map((entry) {
          final int index = entry.key;
          final ChartData dataItem = entry.value;
          final bool isTouched = index == _hoveredIndex;
          final double fontSize = isTouched ? 18.0 : 14.0;
          final double radius = isTouched ? 60.0 : 50.0;
          final double percentage = totalValue == 0 ? 0 : (dataItem.value / totalValue) * 100;

          // If all values are zero, draw a default gray section
          if (totalValue == 0 && widget.data.length == 1) {
             return PieChartSectionData(
              color: Colors.grey[300],
              value: 1, // Full circle
              title: '0%',
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff),
              ),
            );
          }
          // If this specific item is 0, don't display it or give it minimal space if it's the only item
          if (dataItem.value == 0 && totalValue != 0) {
            return PieChartSectionData(
              color: dataItem.color.withOpacity(0.1), // Make it very faint or transparent
              value: 0.00001, // Give it a tiny value so it doesn't break the chart
              title: '',
              radius: radius,
              showTitle: false,
            );
          }


          return PieChartSectionData(
            color: dataItem.color,
            value: dataItem.value,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff), // White text for better contrast on colored sections
            ),
          );
        }).toList(),
        // Handle case where all data values are 0
        startDegreeOffset: (totalValue == 0 && widget.data.isNotEmpty && widget.data.every((d) => d.value == 0)) ? 0 : null,
      ),
    );
  }
}

class ChartData {
  final double value;
  final Color color;
  final String label;

  ChartData({required this.value, required this.color, required this.label});
}

// _CircularChartPainter class is removed as it's no longer needed.
