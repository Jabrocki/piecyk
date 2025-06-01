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
  Widget build(BuildContext context) => FSelect<String>(
    initialValue: selectedTariff,
    onChange: onChanged,
    hint: 'Select a tariff',
    format: (s) => s,
    children: [for (final tariff in tariffs) FSelectItem(tariff, tariff)],
  );
}
