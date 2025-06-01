import 'package:flutter/material.dart';
import 'package:forui/forui.dart'; // Assuming FColors is defined here

// Defines FColors for the light theme, to be used with forui's FTheme.
final FColors lightFColors = FColors(
  brightness: Brightness.light,
  barrier: Colors.black.withOpacity(0.4),
  background: Colors.white,
  foreground: Colors.black,
  primary: Colors.green,
  primaryForeground: Colors.white,
  secondary: Colors.greenAccent.shade100,
  secondaryForeground: Colors.black,
  muted: Colors.grey.shade200,
  mutedForeground: Colors.grey.shade500,
  destructive: Colors.red.shade700,
  destructiveForeground: Colors.white,
  error: Colors.red.shade700,
  errorForeground: Colors.white,
  border: Colors.grey.shade300,
  
  // enabledHoveredOpacity and disabledOpacity will use default values from FColors constructor
);

// Defines FColors for the dark theme, to be used with forui's FTheme.
final FColors darkFColors = FColors(
  brightness: Brightness.dark,
  barrier: Colors.black.withOpacity(0.6),
  background: Colors.black,
  foreground: Colors.white,
  primary: Colors.green,
  primaryForeground: Colors.white, // Text on green buttons
  secondary: Colors.greenAccent.shade700, // Darker green accent for dark theme
  secondaryForeground: Colors.white,
  muted: Colors.grey.shade800,
  mutedForeground: Colors.grey.shade400,
  destructive: Colors.red.shade400,
  destructiveForeground: Colors.white,
  error: Colors.red.shade400,
  errorForeground: Colors.white,
  border: Colors.grey.shade700,
  // enabledHoveredOpacity and disabledOpacity will use default values from FColors constructor
);

// Note: If FStyle also needs to change (e.g., text colors within styles),
// you might need to define lightFStyle and darkFStyle as well.
// For now, we assume FStyle primarily deals with layout and a single version is sufficient.
