import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/material.dart";

/// Resolved palette for auth screens (welcome, sign-in, sign-up).
class AuthScreenColors {
  const AuthScreenColors._({
    required this.scaffoldBackground,
    required this.bodyBackground,
    required this.headline,
    required this.subtitle,
    required this.tagline,
    required this.label,
    required this.hint,
    required this.icon,
    required this.inputFill,
    required this.inputBorder,
    required this.inputText,
    required this.secondaryButtonFill,
    required this.secondaryButtonBorder,
    required this.secondaryButtonForeground,
    required this.signUpLogoPlate,
    required this.headerPattern,
  });

  final Color scaffoldBackground;
  final Color bodyBackground;
  final Color headline;
  final Color subtitle;
  final Color tagline;
  final Color label;
  final Color hint;
  final Color icon;
  final Color inputFill;
  final Color inputBorder;
  final Color inputText;
  final Color secondaryButtonFill;
  final Color secondaryButtonBorder;
  final Color secondaryButtonForeground;
  final Color signUpLogoPlate;
  final Color headerPattern;

  static const Color primary = kFlowAuthWelcomePrimary;
  static const Color primaryButtonShadow = kFlowAuthWelcomePrimaryButtonShadow;
  static const Color logoShadow = kFlowAuthWelcomeLogoShadow;

  factory AuthScreenColors.of(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    if (!dark) {
      return const AuthScreenColors._(
        scaffoldBackground: kFlowAuthWelcomeBackground,
        bodyBackground: kFlowAuthSignInBody,
        headline: kFlowAuthWelcomeHeadline,
        subtitle: kFlowAuthSignInSubtitle,
        tagline: kFlowAuthWelcomeTagline,
        label: kFlowAuthSignInLabel,
        hint: kFlowAuthSignInHint,
        icon: kFlowAuthSignInIcon,
        inputFill: kFlowAuthSignInInputFill,
        inputBorder: kFlowAuthSignUpInputBorder,
        inputText: Color(0xFF0F172A),
        secondaryButtonFill: Color(0xFFFFFFFF),
        secondaryButtonBorder: kFlowAuthWelcomeSignInBorder,
        secondaryButtonForeground: kFlowAuthWelcomePrimary,
        signUpLogoPlate: kFlowAuthSignUpLogoPlate,
        headerPattern: kFlowAuthSignInHeaderPattern,
      );
    }

    return const AuthScreenColors._(
      scaffoldBackground: Color(0xFF0B1220),
      bodyBackground: Color(0xFF151D2E),
      headline: Color(0xFFF8FAFC),
      subtitle: Color(0xFF94A3B8),
      tagline: Color(0xFFCBD5E1),
      label: Color(0xFFE2E8F0),
      hint: Color(0xFF64748B),
      icon: Color(0xFF94A3B8),
      inputFill: Color(0xFF1E293B),
      inputBorder: Color(0xFF334155),
      inputText: Color(0xFFF1F5F9),
      secondaryButtonFill: Color(0xFF1E293B),
      secondaryButtonBorder: Color(0xFF475569),
      secondaryButtonForeground: Color(0xFF93C5FD),
      signUpLogoPlate: Color(0xFF3B82C4),
      headerPattern: Color(0x1AFFFFFF),
    );
  }

  InputDecoration inputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool outlined = false,
  }) {
    final BorderSide borderSide = BorderSide(color: inputBorder);
    final BorderSide enabledBorderSide =
        outlined ? borderSide : BorderSide.none;
    final BorderSide focusedBorderSide = BorderSide(
      color: primary,
      width: 1.5,
    );
    const BorderSide errorBorderSide = BorderSide(
      color: Colors.redAccent,
      width: 1.0,
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: hint, fontWeight: FontWeight.w400),
      filled: true,
      fillColor: inputFill,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(kFlowAuthSignInFieldRadius),
        ),
        borderSide: enabledBorderSide,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(kFlowAuthSignInFieldRadius),
        ),
        borderSide: enabledBorderSide,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(kFlowAuthSignInFieldRadius),
        ),
        borderSide: focusedBorderSide,
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(kFlowAuthSignInFieldRadius),
        ),
        borderSide: errorBorderSide,
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(kFlowAuthSignInFieldRadius),
        ),
        borderSide: errorBorderSide,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
    );
  }

  TextStyle get fieldTextStyle => TextStyle(
    color: inputText,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
  );
}
