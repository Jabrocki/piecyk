import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:forui/forui.dart';

FScaffoldStyle generalStyle({
  required FColors colors,
  required FStyle style,
}) => FScaffoldStyle(
  backgroundColor: colors.background,
  sidebarBackgroundColor: colors.background,
  childPadding: style.pagePadding,
  footerDecoration: BoxDecoration(
    border: Border(
      top: BorderSide(color: colors.border, width: style.borderWidth),
    ),
  ),
  headerDecoration: const BoxDecoration(),
);
