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
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = _expanded
        ? (screenWidth * 0.2).clamp(150, 600) // 20% of screen, min 200, max 400
        : 48.0;
    final showLabels = sidebarWidth >= 169;

    if (!showLabels) {
      sidebarWidth = 80.0;
    }
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut, // Changed from Curves.easeInOut
          width: sidebarWidth.toDouble(), // <-- minimum width for button
          child: _expanded
              ? FSidebar(
                  width: 300,
                  header: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // if (showLabels) ...[
                        //   Text(
                        //     'Menu', // <-- your title (napis)
                        //     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        //           fontWeight: FontWeight.bold,
                        //           letterSpacing: 1.2,
                        //         ),
                        //   ),
                        // ],
                        const SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: Colors.black.withOpacity(0.08), // subtle line
                        ),
                      ],
                    ),
                  ),
                  //padding: EdgeInsets.zero,
                  children: [
                    FSidebarGroup(
                      children: [
                        FSidebarItem(
                          icon: const Icon(FIcons.layoutDashboard),
                          label: showLabels ? const Text('Dashboard') : null,
                          selected: true,
                          onPress: () {},
                        ),
                        FSidebarItem(
                          icon: const Icon(FIcons.network),
                          label: showLabels ? const Text('Devices') : null,
                          onPress: () {},
                        ),
                        FSidebarItem(
                          icon: const Icon(FIcons.settings),
                          label: showLabels ? const Text('Settings') : null,
                          onPress: () {},
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
          left: 12,
          child: SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.menu),
              tooltip: _expanded ? 'Hide sidebar' : 'Show sidebar',
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
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