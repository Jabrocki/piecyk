import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Enter location',
                    hintText: 'City name or coordinates (e.g., 50.26 19.02)',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submitAddress(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _submitAddress,
                child: const Text('Update Location'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tip: Enter a city name like "Katowice" or coordinates like "50.26 19.02"',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
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
