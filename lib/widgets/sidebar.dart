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
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _expanded ? 300 : 48, // <-- minimum width for button
          child: _expanded
              ? FSidebar(
                  width: 300,
                  header: const SizedBox(height: 48), // reserve space for button
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
                )
              : null,
        ),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            icon: Icon(Icons.menu),
            tooltip: _expanded ? 'Hide sidebar' : 'Show sidebar',
            onPressed: () => setState(() => _expanded = !_expanded),
          ),
        ),
      ],
    );
  }
}