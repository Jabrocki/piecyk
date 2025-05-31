import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:piecyk/theme/general_style.dart';
import 'package:piecyk/widgets/sidebar.dart';
import 'package:piecyk/widgets/main_page_resizable.dart';
import 'package:piecyk/widgets/title_widget.dart';
import 'package:provider/provider.dart';
import 'package:piecyk/providers/theme_provider.dart';
import 'package:piecyk/theme/forui_theme_adapter.dart'; // Import the adapter

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Determine which FColors to use based on the current theme.
    final FColors currentFColors = themeProvider.isDarkMode ? darkFColors : lightFColors;
    final style = FTheme.of(context).style; // Assuming FStyle doesn't need to change or is handled elsewhere.

    return Material(
      type: MaterialType.transparency,
      // Wrap with FTheme to apply the selected FColors
      child: FTheme(
        data: FThemeData(
          colors: currentFColors,
          style: style, // You might need to adjust FStyle as well if it contains color-dependent properties
        ),
        child: Container(
          child: FScaffold(
            scaffoldStyle: generalStyle(colors: currentFColors, style: style),
            header: const FHeader(
              title: TitleWidget(),
            ),
            childPad: true,
            footer: FBottomNavigationBar(children: const []),
            sidebar: const MainSidebar(), // Use MainSidebar directly
            child: Center(
              child: Center(
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 50),
                    Expanded(
                      child: MainPageResizableVertical(),
                    ),
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
// helo