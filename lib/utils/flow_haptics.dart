import "package:flow/prefs/local_preferences.dart";
import "package:flutter/services.dart";

/// Light tap feedback (swipe peek, icon tap).
void flowHapticLight() {
  if (LocalPreferences().enableHapticFeedback.get()) {
    HapticFeedback.lightImpact();
  }
}

/// Stronger feedback (delete, confirm).
void flowHapticMedium() {
  if (LocalPreferences().enableHapticFeedback.get()) {
    HapticFeedback.mediumImpact();
  }
}
