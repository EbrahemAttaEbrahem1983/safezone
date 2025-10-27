import 'package:flutter/material.dart';

class AppTokens {
  final ColorScheme scheme;
  final TextTheme text;
  AppTokens(BuildContext context)
    : scheme = Theme.of(context).colorScheme,
      text = Theme.of(context).textTheme;
  Color get bg => scheme.surface;
  Color get bgAlt => scheme.surfaceContainerHighest;
  Color get card => scheme.surfaceContainerHigh;
  Color get border => scheme.outlineVariant;
  Color get primaryBtnBg => scheme.primary;
  Color get primaryBtnFg => scheme.onPrimary;
  Color get secondaryBtnBg => scheme.secondaryContainer;
  Color get secondaryBtnFg => scheme.onSecondaryContainer;
  Color get fieldBg => scheme.surfaceContainerHigh;
  Color get fieldHint => scheme.onSurfaceVariant;
  Color get chipBg => scheme.surfaceContainer;
  Color get chipFg => scheme.onSurfaceVariant;
}
