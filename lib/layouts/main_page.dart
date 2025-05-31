import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:piecyk/theme/general_style.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = FTheme.of(context).colors;
    final style = FTheme.of(context).style;

    return FScaffold(
      scaffoldStyle: generalStyle(colors: colors, style: style),
      header: FHeader(
        title: const Text('Main Page'),
      ),
      childPad: true,
      child: const Center(
        child: Text('Hi'),
      ),
      sidebar: FSidebar(children: const []),
      footer: FBottomNavigationBar(children: const []),
    );
  }
}
