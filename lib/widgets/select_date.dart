import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

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
      initialDate: DateTime.now(), // Domyślna data początkowa
      validator: _validateStartDate,
    );
    _endDateController = FDateFieldController(
      vsync: this,
      initialDate: DateTime.now(), // Domyślna data końcowa
      validator: _validateEndDate,
    );
  }

  // Walidacja daty początkowej
  String? _validateStartDate(DateTime? date) {
    if (date == null) {
      return 'Wybierz datę początkową';
    }
    if (date.isAfter(DateTime.now())) {
      return 'Data początkowa musi być dzisiaj lub wcześniej';
    }
    return null;
  }

  // Walidacja daty końcowej
  String? _validateEndDate(DateTime? date) {
    if (date == null) {
      return 'Wybierz datę końcową';
    }
    if (date.isAfter(DateTime.now())) {
      return 'Data końcowa musi być dzisiaj lub wcześniej';
    }
    if (_startDateController.value != null &&
        date.isBefore(_startDateController.value!)) {
      return 'Data końcowa musi być po dacie początkowej';
    }
    return null;
  }

  // Formatowanie daty do YYYY-MM-DD
  String _formatDate(DateTime? date) {
    if (date == null) return 'Wybierz datę';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pole dla daty początkowej
        FDateField(
          controller: _startDateController,
          label: const Text('Start Date'),
          description: const Text('Select a starting date'),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          prefixBuilder: (context, styles, child) =>
              const Icon(Icons.calendar_today),
          clearable: true,
          onChange: (DateTime? selected) {
            if (selected != null) {
              setState(() {});
              //context.read<MainState>().startDate = _formatDate(selected);
            }
          },
        ),
        const SizedBox(height: 10),
        // Pole dla daty końcowej
        FDateField(
          controller: _endDateController,
          label: const Text('End Date'),
          description: const Text('Select an ending date'),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          prefixBuilder: (context, styles, child) =>
              const Icon(Icons.calendar_today),
          clearable: true,
          onChange: (DateTime? selected) {
            if (selected != null) {
              setState(() {});
              //context.read<MainState>().endDate = _formatDate(selected);
            }
          },
        ),
        const SizedBox(height: 10),
        // Wyświetlanie wybranych dat
        Text('Początek: ${_formatDate(_startDateController.value)}'),
        Text('Koniec: ${_formatDate(_endDateController.value)}'),
      ],
    );
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
