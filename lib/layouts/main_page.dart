import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:piecyk/theme/general_style.dart';

import 'package:piecyk/widgets/main_page_resizable.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = FTheme.of(context).colors;
    final style = FTheme.of(context).style;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        child: FScaffold(
          scaffoldStyle: generalStyle(colors: colors, style: style),
          header: const FHeader(
            title: Text('SUNSEER'),
          ),
          childPad: true,
          child: Center(
            child: MainPageResizableVertical(),
          ),
          sidebar: FSidebar(children: const []),
          footer: FBottomNavigationBar(children: const []),
        ),
      ),
    );
  }
}
