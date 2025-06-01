import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:piecyk/providers/theme_provider.dart';

class MainSidebar extends StatefulWidget {
  final Function(bool)? onDownloadDataPressed; // Optional callback to trigger menu visibility

  const MainSidebar({
    super.key,
    this.onDownloadDataPressed, // Add the parameter
  });

  @override
  State<MainSidebar> createState() => _MainSidebarState();
}

class _MainSidebarState extends State<MainSidebar>
    with SingleTickerProviderStateMixin { // Added SingleTickerProviderStateMixin
  bool _expanded = false;
  late AnimationController _stripeAnimationController;
  late Animation<Color?> _stripeGradientColor1;
  late Animation<Color?> _stripeGradientColor2;

  @override
  void initState() {
    super.initState();
    _stripeAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  void _initializeStripeAnimations(ThemeProvider themeProvider) {
    final finalGradientColor = themeProvider.isDarkMode ? Colors.blueGrey[700]! : Colors.lightBlue[100]!;

    _stripeGradientColor1 = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.green, end: finalGradientColor),
          weight: 100.0,
        ),
      ],
    ).animate(_stripeAnimationController);

    _stripeGradientColor2 = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.yellow, end: Colors.green),
          weight: 100.0,
        ),
      ],
    ).animate(_stripeAnimationController);

    if (_expanded && !_stripeAnimationController.isAnimating) {
      _stripeAnimationController.repeat();
    }
  }
  
  bool _animationsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_animationsInitialized) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      _initializeStripeAnimations(themeProvider);
      _animationsInitialized = true;
    }
  }

  @override
  void dispose() {
    _stripeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    double sidebarWidth = _expanded
        ? (screenWidth * 0.2).clamp(150, 600)
        : 48.0;
    final showLabels = sidebarWidth >= 169;

    if (!showLabels && _expanded) { // Ensure sidebarWidth is not too small when expanded but labels not shown
      sidebarWidth = 80.0;
    } else if (!_expanded) {
      sidebarWidth = 48.0; // Collapsed width
    }


    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: sidebarWidth.toDouble(),
          child: _expanded
              ? FSidebar(
                  width: sidebarWidth, // Use dynamic width
                  header: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20), // Space for menu icon
                        Container(
                          height: 1,
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ],
                    ),
                  ),
                  children: [
                    FSidebarGroup(
                      children: [
                        FSidebarItem(
                          icon: const Icon(FIcons.layoutDashboard),
                          label: showLabels ? const Text('Dashboard') : null,
                          onPress: () {},
                        ),
                        FSidebarItem(
                          icon: const Icon(FIcons.download),
                          label: showLabels ? const Text('Download Data') : null,
                          onPress: () {
                            if (widget.onDownloadDataPressed != null) {
                              widget.onDownloadDataPressed!(!_expanded);
                            }
                          },
                        ),
                        FSidebarItem(
                          icon: const Icon(FIcons.info),
                          label: showLabels ? const Text('Information') : null,
                          initiallyExpanded: true,
                          children: [
                            FSidebarItem(
                              icon: const Icon(FIcons.flame),
                              label: showLabels ? const Text('Piec Koksowniczy') : null,
                              initiallyExpanded: true,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  child: Text('Bartłomiej Pietrzak', style: TextStyle(fontSize: 15)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  child: Text('Bartosz Pajor', style: TextStyle(fontSize: 15)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  child: Text('Franciszek Razny', style: TextStyle(fontSize: 15)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  child: Text('Jan Jabrocki', style: TextStyle(fontSize: 15)),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: Text('Kosciuszkon 2025', style: TextStyle(fontSize: 15)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              : Container( // Collapsed state content
                  alignment: Alignment.center, // Center the icon
                  width: sidebarWidth, // Use fixed collapsed width
                ),
        ),
        if (_expanded && _animationsInitialized) // Animated stripe
          Positioned(
            top: 0,
            bottom: 0,
            left: 0.0,
            width: 3.0,
            child: AnimatedBuilder(
              animation: _stripeAnimationController,
              builder: (context, child) {
                final color1 = _stripeGradientColor1.value ?? Colors.transparent;
                final color2 = _stripeGradientColor2.value ?? Colors.transparent;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color1, color2],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                );
              },
            ),
          ),
        Positioned( // Menu Icon
          top: 8,
          left: _expanded ? (sidebarWidth - 48) / 2 : (48.0 - 48) / 2, // Center icon when collapsed, or adjust as needed
          child: SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(_expanded ? Icons.menu_open : Icons.menu),
              tooltip: _expanded ? 'Hide sidebar' : 'Show sidebar',
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                  if (_expanded) {
                    // Ensure animations are initialized if not already
                    if (!_animationsInitialized) {
                       final tp = Provider.of<ThemeProvider>(context, listen: false);
                      _initializeStripeAnimations(tp);
                      _animationsInitialized = true;
                    }
                    if (!_stripeAnimationController.isAnimating) {
                      _stripeAnimationController.repeat();
                    }
                  } else {
                    if (_stripeAnimationController.isAnimating) {
                      _stripeAnimationController.stop(canceled: false);
                    }
                  }
                });
              },
            ),
          ),
        ),
        if (_expanded) // Theme toggle button when expanded
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              tooltip: 'Toggle theme',
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                 // Re-initialize animations if theme changes and they depend on it
                _initializeStripeAnimations(Provider.of<ThemeProvider>(context, listen: false));
                if (_expanded && !_stripeAnimationController.isAnimating) {
                   _stripeAnimationController.repeat();
                }
              },
            ),
          )
        else // Theme toggle button when collapsed (bottom of the 48px area)
          Positioned(
            bottom: 8,
            left: (48.0 - 48) / 2, // Centered in 48px width
            width: 48,
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              tooltip: 'Toggle theme',
              onPressed: () {
                 Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                 _initializeStripeAnimations(Provider.of<ThemeProvider>(context, listen: false));
              },
            ),
          ),
      ],
    );
  }
}
