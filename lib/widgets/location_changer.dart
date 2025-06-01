import 'package:flutter/material.dart';
import 'package:forui/forui.dart'; // Import FTextField and FButton
import 'package:provider/provider.dart';
import 'package:piecyk/providers/main_state.dart';

class LocationChanger extends StatefulWidget {
  const LocationChanger({super.key});

  @override
  State<LocationChanger> createState() => _LocationChangerState();
}

class _LocationChangerState extends State<LocationChanger> {
  final TextEditingController _addressController = TextEditingController();

  void _submitAddress() {
    final String address = _addressController.text.trim();
    if (address.isNotEmpty) {
      context.read<MainState>().updateAddressAndFetchWeather(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context); // Get FTheme instance

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 00, 10, 10),
      child: Row( // Changed Column to Row
        crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
        children: <Widget>[
          Expanded(
            child: FTextField(
              controller: _addressController,
              hint: 'Location // Leave empty for auto-detect' // Set hintText
              // label: const Text('Enter location'), // Removed label
            ),
          ),
          const SizedBox(width: 8),
          // Padding( // Removed Padding
          //   padding: const EdgeInsets.only(top: 8.0), 
          //   child: 
          FButton(
            onPress: _submitAddress,
            child: const Text('Update Location'),
          ),
          // ), // Removed Padding
          // const SizedBox(width: 8), // Removed SizedBox
          // Expanded( // Removed Expanded Text for tip
          //   child: Text(
          //     'Tip: Enter a city name like "Katowice" or coordinates like "50.26 19.02"',
          //     style: TextStyle(fontStyle: FontStyle.italic, color: theme.colors.mutedForeground),
          //     softWrap: true, 
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
