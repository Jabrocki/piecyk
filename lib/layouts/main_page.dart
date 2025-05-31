import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:piecyk/theme/general_style.dart';
import 'package:piecyk/widgets/sidebar.dart';
import 'package:piecyk/widgets/main_page_resizable.dart';
import 'package:piecyk/widgets/title_widget.dart';

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
            title: TitleWidget(),
          ),
          childPad: true,
          footer: FBottomNavigationBar(children: const []),
          sidebar: const MainSidebar(),
          child: Center(
            child: Center(
            child: Row(
              children: <Widget>[
                SizedBox(width: 50), 
                Expanded(
                  child: MainPageResizableVertical(),
                ),
                SizedBox(width: 50), 
                Expanded(
                  child: MainPageResizableVertical()
                ),
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
