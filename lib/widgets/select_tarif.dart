import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

const tariffs = ['C22', 'C21', 'C12A', 'C11'];

class SelectTarif extends StatelessWidget {
  final String selectedTariff;
  final ValueChanged<String?> onChanged;
  const SelectTarif({
    super.key,
    required this.selectedTariff,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = FTheme.of(context).colors; // Get theme colors

    return FSelect<String>(
      label: Text(
        'Select a tariff for your installation',
        style: TextStyle(color: themeColors.foreground), // Apply theme color to label
      ),
      initialValue: selectedTariff,
      onChange: onChanged,
      hint: 'Select a tariff', // FSelect should handle hint text color via theme
      format: (s) => s,
      children: [
        for (final tariff in tariffs)
          FSelectItem(tariff, tariff) // FSelectItem should handle its text color via theme
      ],
    );
  }
}
