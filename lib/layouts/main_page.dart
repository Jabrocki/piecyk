import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:piecyk/theme/general_style.dart';
//import 'package:piecyk/widgets/sidebar.dart';
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
          sidebar: FSidebar(
            width: 500,
            children: [
            FSidebarGroup(
              children: [
                FSidebarItem(
                  icon: const Icon(FIcons.layoutDashboard),
                  label: const Text('Dashboard'),
                  selected: true,
                  onPress: () {},
                ),
                FSidebarItem(icon: const Icon(FIcons.chartLine), label: const Text('Analytics'), onPress: () {}),
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
        ),
          footer: FBottomNavigationBar(children: const []),
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
    );
  }
}
