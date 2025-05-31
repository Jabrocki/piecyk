import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:piecyk/providers/main_state.dart';
import 'package:piecyk/theme/general_style.dart';
import 'package:piecyk/widgets/sidebar.dart';
import 'package:piecyk/widgets/main_page_resizable.dart';
import 'package:piecyk/widgets/title_widget.dart';
import 'package:provider/provider.dart';
import 'package:piecyk/providers/theme_provider.dart';
import 'package:piecyk/theme/forui_theme_adapter.dart'; // Import the adapter

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    context.read<MainState>().loadWeatherForCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Determine which FColors to use based on the current theme.
    final FColors currentFColors = themeProvider.isDarkMode ? darkFColors : lightFColors;
    final FStyle style = FTheme.of(context).style; // Assuming FStyle doesn't need to change or is handled elsewhere.

    return FTheme(
      data: FThemeData(colors: currentFColors, style: style),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          child: FScaffold(
            scaffoldStyle: generalStyle(colors: currentFColors, style: style),
            header: const FHeader(title: TitleWidget()),
            childPad: true,
            footer: FBottomNavigationBar(children: const []),
            sidebar: const MainSidebar(),
            child: Center(
              child: Center(
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 50),
                    Expanded(child: MainPageResizableVertical()),
                    SizedBox(width: 50),
                    Expanded(child: MainPageResizableVertical()),
                    SizedBox(width: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
