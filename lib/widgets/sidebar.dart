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
          duration: const Duration(milliseconds: 200),
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
              : null,
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
      ],
    );
  }
}