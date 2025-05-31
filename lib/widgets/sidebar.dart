import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class MainSidebar extends StatefulWidget {
  const MainSidebar({super.key});

  @override
  State<MainSidebar> createState() => _MainSidebarState();
}

class _MainSidebarState extends State<MainSidebar> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    if (_expanded) {
      return FSidebar(
        width: 300,
        header: Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Hide sidebar',
            onPressed: () => setState(() => _expanded = false),
          ),
        ),
        children: [
          FSidebarGroup(
            children: [
              FSidebarItem(
                icon: const Icon(FIcons.layoutDashboard),
                label: const Text('Dashboard'),
                selected: true,
                onPress: () {},
              ),
              FSidebarItem(
                icon: const Icon(FIcons.settings),
                label: const Text('Settings'),
                onPress: () {},
              ),
              FSidebarItem(
                icon: const Icon(FIcons.chartBar),
                label: const Text('Reports'),
                initiallyExpanded: true,
                children: [
                  FSidebarItem(label: const Text('Daily'), onPress: () {}),
                  FSidebarItem(label: const Text('Weekly'), onPress: () {}),
                  FSidebarItem(label: const Text('Monthly'), onPress: () {}),
                ],
              ),
            ],
          ),
        ],
      );
    } else {
      // Only show the expand button in the left corner
      return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Show sidebar',
            onPressed: () => setState(() => _expanded = true),
          ),
        ),
      );
    }
  }
}