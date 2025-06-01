import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:piecyk/widgets/vertical_device_list.dart';

class DeviceInfoCollumn extends StatelessWidget {
  const DeviceInfoCollumn({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Take full width
      height: double.infinity, // Take full height
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: context.theme.colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: VerticalDeviceList(), // Only VerticalDeviceList remains
      ),
    );
  }
}

