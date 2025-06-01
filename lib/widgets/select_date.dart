import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:piecyk/services/weather_api_client.dart';

class SelectDate extends StatefulWidget {
  const SelectDate({super.key});

  @override
  State<SelectDate> createState() => _SelectDateState();
}

class _SelectDateState extends State<SelectDate> with TickerProviderStateMixin {
  late final FDateFieldController _startDateController;
  late final FDateFieldController _endDateController;

  @override
  void initState() {
    super.initState();
    _startDateController = FDateFieldController(
      vsync: this,
      initialDate: DateTime.now().subtract(
        const Duration(days: 36),
      ), // Domyślna data początkowa
      validator: _validateStartDate,
    );
    _endDateController = FDateFieldController(
      vsync: this,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6),
      ), // Domyślna data końcowa
      validator: _validateEndDate,
    );
  }

  // Walidacja daty początkowej
  String? _validateStartDate(DateTime? date) {
    if (date == null) {
      return 'Select a starting date';
    }
    if (date.isAfter(DateTime.now().subtract(const Duration(days: 6)))) {
      return 'The start date must be at least 6 days earlier.';
    }
    return null;
  }

  // Walidacja daty końcowej
  String? _validateEndDate(DateTime? date) {
    if (date == null) {
      return 'Select the end date';
    }
    if (date.isAfter(DateTime.now().subtract(const Duration(days: 5)))) {
      return 'The end date must be at least 5 days earlier than today';
    }
    if (_startDateController.value != null &&
        date.isBefore(_startDateController.value!)) {
      return 'Data końcowa musi być po dacie początkowej';
    }
    return null;
  }

  // Formatowanie daty do YYYY-MM-DD
  String _formatDate(DateTime? date) {
    if (date == null) return 'Pick a date';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context); // Get FTheme instance

    return Padding( padding:EdgeInsets.fromLTRB(10,0,10,0), child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pole dla daty początkowej
        FDateField(
          controller: _startDateController,
          label: Text('Select a starting date', style: TextStyle(color: theme.colors.foreground)), // Apply theme to label
          autovalidateMode: AutovalidateMode.onUserInteraction,
          prefixBuilder: (context, styles, child) => Padding(
            padding: const EdgeInsets.only(left: 8.0), // Add left padding to the icon
            child: Icon(Icons.calendar_today, color: theme.colors.foreground),
          ), // Apply theme to icon
          clearable: true,
          onChange: (DateTime? selected) {
            if (selected != null) {
              setState(() {
                WeatherApiClient.startDate = _formatDate(selected);
              });
              //context.read<MainState>().startDate = _formatDate(selected);
            }
          },
        ),
        // Pole dla daty końcowej
        const SizedBox(height: 10),
        FDateField(
          
          controller: _endDateController,
          label: Text('Select an ending date', style: TextStyle(color: theme.colors.foreground)), // Apply theme to label
          autovalidateMode: AutovalidateMode.onUserInteraction,
          prefixBuilder: (context, styles, child) => Padding(
            padding: const EdgeInsets.only(left: 8.0), // Add left padding to the icon
            child: Icon(Icons.calendar_today, color: theme.colors.foreground),
          ), // Apply theme to icon
          clearable: true,
          onChange: (DateTime? selected) {
            if (selected != null) {
              setState(() {
                WeatherApiClient.endDate = _formatDate(selected);
              });
              //context.read<MainState>().endDate = _formatDate(selected);
            }
          },
        ),
        const SizedBox(height: 10),
      ],
    ));
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
