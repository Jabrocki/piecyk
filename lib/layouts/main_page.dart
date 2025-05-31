import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:piecyk/providers/main_state.dart';
import 'package:piecyk/theme/general_style.dart';
import 'package:piecyk/widgets/sidebar.dart';
import 'package:piecyk/widgets/main_page_resizable.dart';
import 'package:piecyk/widgets/title_widget.dart';
import 'package:provider/provider.dart';
import '../providers/main_state.dart';

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
    final colors = FTheme.of(context).colors;
    final style = FTheme.of(context).style;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        child: FScaffold(
          scaffoldStyle: generalStyle(colors: colors, style: style),
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
    );
  }
}
