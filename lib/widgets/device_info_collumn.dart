import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:piecyk/providers/main_state.dart';
import 'package:piecyk/providers/weather_state.dart';
import 'package:piecyk/widgets/vertical_device_list.dart';
import 'select_tarif.dart';
import 'package:piecyk/models/weather_model.dart';

class DeviceInfoCollumn extends StatefulWidget {
  const DeviceInfoCollumn({super.key});

  @override
  State<DeviceInfoCollumn> createState() => _DeviceInfoCollumnState();
}

class _DeviceInfoCollumnState extends State<DeviceInfoCollumn> {
  String selectedTariff = 'C22';

  @override
  Widget build(BuildContext context) {
    final mainState = Provider.of<MainState>(context);
    final hasInstallations = mainState.installations.isNotEmpty;
    final weatherData = mainState.state is WeatherSuccess
        ? (mainState.state as WeatherSuccess).weather
        : null;

    double totalEnergyProduces = 0;
    double maxEnergyProducesInDay = 0;

    // Prepare weatherModels list for all installations (for demo: use the same weather for all)
    final List<WeatherModel> weatherModels =
        hasInstallations && weatherData != null
        ? List.generate(mainState.installations.length, (_) => weatherData)
        : [];

    double totalSave = 0.0;
    if (hasInstallations && weatherModels.isNotEmpty) {
      try {
        totalSave = mainState.calculateSavingsByTariff(
          weatherModels: weatherModels,
          tariff: selectedTariff,
        );
      } catch (e) {
        totalSave = 0.0;
      }
    }

    if (mainState.state is WeatherSuccess) {
      final weather = (mainState.state as WeatherSuccess).weather;
      final calculatedHourlyProduction = mainState.calculateProduction(weather);
      final cumulativeHourlyProduction = mainState.calculateCumulativeSum(
        calculatedHourlyProduction,
      );
      if (cumulativeHourlyProduction.isNotEmpty) {
        totalEnergyProduces = cumulativeHourlyProduction.last;
      } else {
        totalEnergyProduces = 0.0; // Default value if no data is available
      }
      double tmp = double.minPositive;
      for (int i = 0; i < calculatedHourlyProduction.length; i++) {
        if (i % 24 != 0) {
          tmp += calculatedHourlyProduction[i];
        } else {
          if (tmp > maxEnergyProducesInDay) {
            maxEnergyProducesInDay = tmp;
          }
          tmp = 0.0;
        }
      }
    }

    return SizedBox(
      width: double.infinity, // Take full width
      height: double.infinity, // Take full height
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: context.theme.colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: <Widget>[
            VerticalDeviceList(),
            SelectTarif(
              selectedTariff: selectedTariff,
              onChanged: (String? newTariff) {
                if (newTariff != null) {
                  setState(() {
                    selectedTariff = newTariff;
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Total savings: ${totalSave.toStringAsFixed(2)} zł',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Total Energy Produced: ${totalEnergyProduces.toStringAsFixed(2)} [kWh]',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Maximum energy produces in day: ${maxEnergyProducesInDay.toStringAsFixed(2)} [kWh]',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
