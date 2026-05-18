import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";

/// Theme-aware accent colors for redesigned preference sub-pages.
abstract final class PreferencesUiTheme {
  static Color primary(BuildContext context) => context.flowAccent.primary;

  static Color iconPlateFill(BuildContext context) =>
      context.flowAccent.iconPlateFill;

  static Color iconPlateInk(BuildContext context) => context.flowAccent.iconPlateInk;
}
