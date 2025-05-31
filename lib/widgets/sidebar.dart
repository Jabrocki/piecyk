import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:piecyk/providers/theme_provider.dart';

class MainSidebar extends StatefulWidget {
  const MainSidebar({super.key});

  @override
  State<MainSidebar> createState() => _MainSidebarState();
}

class _MainSidebarState extends State<MainSidebar> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut, // Changed from Curves.easeInOut
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
              : Container( // Container to hold the IconButton when collapsed
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 8), // Add some padding
                  child: IconButton(
                    icon: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                    tooltip: 'Toggle theme',
                    onPressed: () {
                      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                    },
                  ),
                ),
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
        // Positioned theme toggle button at the bottom of the Stack, visible in both states
        // This ensures it's always at the bottom, regardless of FSidebar's internal structure.
        if (_expanded) // Only show if expanded, otherwise it's inside the collapsed container
          Positioned(
            bottom: 8,
            left: 0,
            right: 0, // Center it horizontally if sidebar is wider
            child: IconButton(
              icon: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              tooltip: 'Toggle theme',
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ),
      ],
    );
  }
}