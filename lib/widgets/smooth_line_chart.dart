import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SmoothLineChart extends StatelessWidget {
  // Przekazujemy listę wartości przez konstruktor
  final List<double> values;

  const SmoothLineChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    // 1. Zamiana wartości na FlSpot
    final List<FlSpot> spots = values.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    // 2. Tworzymy konfigurację wykresu
    final lineChartData = LineChartData(
      // zakres osi X od 0 do ostatniego indeksu
      minX: 0,
      maxX: (values.length - 1).toDouble(),

      // zakres Y dobierzemy dynamicznie (np. min i max z values, z niewielkim marginesem)
      minY: values.reduce((a, b) => a < b ? a : b) * 0.9,
      maxY: values.reduce((a, b) => a > b ? a : b) * 1.1,

      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              // Możemy pokazywać np. indeks lub zamienić na jakiś label
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(1),
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
        horizontalInterval:
            ((values.reduce((a, b) => a > b ? a : b) -
                values.reduce((a, b) => a < b ? a : b)) /
            5),
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
          isCurved: true, // <--- TU decydujemy o wygładzeniu linii
          curveSmoothness:
              0.5, // [0..1] – im wyżej, tym bardziejzakrzywiona linia
          color: Colors.blue, // kolor linii
          barWidth: 3, // grubość linii
          dotData: FlDotData(
            show: true, // czy pokazywać kropki w punktach
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 4,
                  color: const Color.fromARGB(255, 30, 233, 74), // kolor kropek
                  strokeWidth: 0,
                ),
          ),
          belowBarData: BarAreaData(
            show: false, // czy rysować wypełnienie pod linią
          ),
        ),
      ],
    );

    // 3. Zwracamy gotowy widget
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(aspectRatio: 1.7, child: LineChart(lineChartData)),
    );
  }
}
