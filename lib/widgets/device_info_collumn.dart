import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:piecyk/widgets/circular_chart.dart'; // Import the circular chart


class DeviceInfoCollumn extends StatelessWidget {
  const DeviceInfoCollumn({super.key});

  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: context.theme.colors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: FResizable(
      axis: Axis.vertical,
      controller: FResizableController(),
      crossAxisExtent: (MediaQuery.sizeOf(context).width) / 3,
      children: [
        FResizableRegion(
          initialExtent: (MediaQuery.sizeOf(context).height) * (1 / 3),
          minExtent: 100,
          builder: (_, data, __) =>
              VerticalDeviceList(), // Replaced Text with VerticalButtonList
        ),
        FResizableRegion(
          initialExtent: 180,
          minExtent: 180,
          builder: (_, layoutData, __) => Padding(
            // Added Padding
            padding: const EdgeInsets.all(8.0), // Added padding value
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CircularChart(
                    data: [
                      ChartData(
                        value: 30,
                        color: const Color.fromARGB(255, 0, 255, 55),
                        label: 'Data A',
                      ),
                      ChartData(
                        value: 50,
                        color: const Color.fromARGB(255, 0, 203, 7),
                        label: 'Data B',
                      ),
                      ChartData(
                        value: 10,
                        color: const Color.fromARGB(255, 0, 129, 6),
                        label: 'Data C',
                      ),
                      ChartData(
                        value: 10,
                        color: const Color.fromARGB(255, 4, 74, 0),
                        label: "elo",
                      ),
                    ],
                    holeRadius: layoutData.extent.current * 0.10,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Lmao power goes brr',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class VerticalDeviceList extends StatefulWidget {
  const VerticalDeviceList({super.key});

  @override
  State<VerticalDeviceList> createState() => _VerticalDeviceListState();
}

class _VerticalDeviceListState extends State<VerticalDeviceList> {
  final controllerPortal = OverlayPortalController();
  final double _textSpacing = 4;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Added SingleChildScrollView
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            // Added Padding
            padding: const EdgeInsets.all(8.0), // Added padding value
            child: LayoutBuilder(
              builder: (context, constraints) {
                return FPortal(
                  controller: controllerPortal,
                  spacing: const FPortalSpacing(8),
                  viewInsets: const EdgeInsets.all(5),
                  portalBuilder: (context) => SizedBox(
                    width: constraints.maxWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.theme.colors.background,
                        border: Border.all(color: context.theme.colors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(FIcons.plug),
                                Text(
                                  "Instalation",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: _textSpacing),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FTextField(
                              label: const Text('Panel Power [kW]'),
                            ),
                          ),
                          SizedBox(height: _textSpacing),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FTextField(
                              label: const Text('Number of Panels'),
                            ),
                          ),
                          SizedBox(height: _textSpacing),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FTextField(
                              label: const Text('Maximum Voltage [V]'),
                            ),
                          ),
                          SizedBox(height: _textSpacing),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FTextField(
                              label: const Text('Tilt [degrees]'),
                            ),
                          ),
                          SizedBox(height: _textSpacing),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FTextField(
                              label: const Text('Azimuth [degrees]'),
                            ),
                          ),
                          SizedBox(height: _textSpacing),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FButton(
                              onPress: () {},
                              child: Text(
                                "Add",
                                style: TextStyle(fontFamily: 'RobotoCondensed', fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: FButton(
                    onPress: () {
                      controllerPortal.toggle();
                    },
                    child: Row(
                      children: [
                        const Icon(FIcons.zap),
                        const SizedBox(width: 10),
                        const Text(
                          'Add Instalation',
                          style: TextStyle(fontFamily: 'RobotoCondensed', fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ), // Spacing between buttons
        ],
      ),
    );
  }
}
