import 'dart:html' as html;
import 'dart:typed_data';
import 'package:piecyk/models/weather_model.dart';
import 'package:piecyk/providers/main_state.dart';

Future<void> downloadForecastingCSV(MainState mainState, WeatherModel weather) async {
  // Prepare CSV header
  final List<String> header = [
    'Hour',
    'Power [kW]',
  ];

  // Calculate production data
  final List<double> hourlyProduction = mainState.calculateProduction(weather);

  // Prepare CSV rows
  final List<List<String>> rows = [
    for (int i = 0; i < hourlyProduction.length; i++)
      [i.toString(), hourlyProduction[i].toStringAsFixed(2)],
  ];

  // Generate CSV content
  final StringBuffer csvContent = StringBuffer();
  csvContent.writeln(header.join(',')); // Add header
  for (final row in rows) {
    csvContent.writeln(row.join(',')); // Add rows
  }

  // Convert CSV content to Uint8List
  final csvBytes = Uint8List.fromList(csvContent.toString().codeUnits);

  // Create a Blob and download the file using dart:html
  final blob = html.Blob([csvBytes]); // Ensure the correct Blob class is used
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..target = '_self' // Ensure the download happens in the same tab
    ..download = 'forecasting_data.csv';
  anchor.click();
  html.Url.revokeObjectUrl(url);
}
