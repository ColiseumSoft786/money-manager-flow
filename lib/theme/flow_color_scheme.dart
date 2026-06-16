import "package:flow/theme/flow_custom_colors.dart";
import "package:flutter/material.dart";

export "package:flow/theme/flow_custom_colors.dart";


const Color kFlowFossGlobeRingLight = Color(0xFFE3EDF7);
const Color kFlowFossGlobeInnerLight = Color(0xFF0C2528);
const Color kFlowFossGlobeRingDark = Color(0xFF5A7080);
const Color kFlowFossGlobeInnerDark = Color(0xFF061F1F);

/// Cyan accent for the FOSS globe bottom glow (see `foss_slide.dart`).
const Color kFlowFossGlobeGlowCyan = Color(0xFF00D4FF);
const Color kFlowFossGlobeGlowCyanBright = Color(0xFF00E5FF);

/// Privacy setup hero: alphas applied to [ColorScheme.primary] / [ColorScheme.shadow].
const int kFlowPrivacyHeroRadialCenterAlpha = 0x44;
const int kFlowPrivacyHeroRadialEdgeAlpha = 0x11;
const int kFlowPrivacyHeroGlowAlpha = 0x22;
const int kFlowPrivacyBadgeShadowAlpha = 0x2a;
/// Shared alpha for setup slide elevated cards (see `privacy_slide`, etc.).
const int kFlowSetupCardShadowAlpha = 0x1a;

/// Muted section heading (e.g. “Popular currencies” on setup currency page).
const Color kFlowPopularCurrenciesSectionHeading = Color(0xFF64748B);

/// Popular currency row: subtle border (slate-200).
const Color kFlowPopularCurrencyCardBorder = Color(0xFFE2E8F0);

/// Popular currency row: leading symbol circle fill (`rgba(241,245,249,1)`).
///
/// Reused anywhere that same tint is needed: e.g. **AccountEditPage** exclude-from-balance
/// card **border** and **icon plate**, setup **AccountPresetCard** trailing edit circle.
const Color kFlowPopularCurrencySymbolPlate = Color(0xFFF1F5F9);

/// Setup accounts (`AccountPresetCard`, `AddAccountCard`): `rgba(226, 232, 240, 0.5)`, 1px.
const Color kFlowSetupAccountCardBorder = Color.fromRGBO(226, 232, 240, 0.5);

/// Setup accounts card: `box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.05)`.
const Color kFlowSetupAccountCardShadow = Color.fromRGBO(0, 0, 0, 0.05);

/// Setup currency info card: `rgba(37, 140, 244, 0.1)`.
const Color kFlowSetupPrimaryCurrencyInfoPanelFill = Color.fromRGBO(
  37,
  140,
  244,
  0.1,
);

/// Setup currency info card title: `rgba(37, 140, 244, 1)`.
const Color kFlowSetupPrimaryCurrencyInfoTitle = Color.fromRGBO(
  37,
  140,
  244,
  1.0,
);

/// Setup accounts bottom **Continue** CTA — same blue as [kFlowSetupPrimaryCurrencyInfoTitle].
const Color kFlowSetupAccountsContinueButtonFill =
    kFlowSetupPrimaryCurrencyInfoTitle;

/// Setup categories — “add custom category” dashed card (light mode): sky tint fill & dash outline.
const Color kFlowSetupAddCategoryCardFill = Color(0xFFF0F9FF);
const Color kFlowSetupAddCategoryCardDashBorder = Color(0xFF93C5FD);
const Color kFlowSetupAddCategoryIconPlateFill = Color(0xFFDBEAFE);

/// Warm off-white page canvas (**Category edit** light mode only).
const Color kFlowWarmOffWhiteSurfaceLight = Color(0xFFFBFAF7);

/// Auth welcome screen (CashPilot sign-up / sign-in entry).
const Color kFlowAuthWelcomeBackground = Color(0xFFF8F9FF);
const Color kFlowAuthWelcomePrimary = Color(0xFF0056A4);
const Color kFlowAuthWelcomeTagline = Color(0xFF5C6B7A);
const Color kFlowAuthWelcomeHeadline = Color(0xFF0F172A);
const Color kFlowAuthWelcomeSubheadline = Color(0xFF64748B);
const Color kFlowAuthWelcomeSignInBorder = Color(0xFFDCE3EE);
const Color kFlowAuthWelcomePrimaryButtonShadow = Color(0x400056A4);
const Color kFlowAuthWelcomeLogoShadow = Color(0x330056A4);

/// Auth sign-in screen (CashPilot).
const Color kFlowAuthSignInBody = Color(0xFFFFFFFF);
const Color kFlowAuthSignInHeaderPattern = Color(0x1AFFFFFF);
const Color kFlowAuthSignInInputFill = Color(0xFFE8EEF6);
const Color kFlowAuthSignInLabel = Color(0xFF0F172A);
const Color kFlowAuthSignInHint = Color(0xFF94A3B8);
const Color kFlowAuthSignInSubtitle = Color(0xFF64748B);
const Color kFlowAuthSignInIcon = Color(0xFF64748B);
const double kFlowAuthSignInFieldRadius = 14.0;
const Color kFlowAuthSignUpLogoPlate = Color(0xFF7EB8E8);
const Color kFlowAuthSignUpInputBorder = Color(0xFFE2E8F0);

/// Home Income / Expense metric chips (pinned header row).
const Color kFlowHomeIncomeMetricFill = Color(0xFFE8F8F0);
const Color kFlowHomeIncomeMetricFillDark = Color(0xFF132A20);
const Color kFlowHomeIncomeMetricAccent = Color(0xFF16A34A);
const Color kFlowHomeExpenseMetricFill = Color(0xFFFFF0F2);
const Color kFlowHomeExpenseMetricFillDark = Color(0xFF2E1518);
const Color kFlowHomeExpenseMetricAccent = Color(0xFFDC2626);

/// Transaction filter row — stadium chips (homepage).
const Color kFlowFilterPillSelectedFillLight = Color(0xFFE8F2FE);
const Color kFlowFilterPillSelectedFgLight = Color(0xFF1E88FF);
const Color kFlowFilterPillUnselectedFillLight = Color(0xFFF3F4F6);
const Color kFlowFilterPillUnselectedFgLight = Color(0xFF475569);
const Color kFlowFilterPillSelectedFillDark = Color(0xFF1A3050);
const Color kFlowFilterPillSelectedFgDark = Color(0xFF93C5FD);
const Color kFlowFilterPillUnselectedFillDark = Color(0xFF2A2E36);
const Color kFlowFilterPillUnselectedFgDark = Color(0xFFCBD5E1);

/// Home transaction history canvas behind elevated white tiles (light mode).
const Color kFlowHomeHistoryCanvasLight = Color(0xFFF2F4F8);

/// Group header title / primary card title ink (home history list).
const Color kFlowHomeTransactionHeadingInk = Color(0xFF0F172A);

/// Muted captions (date header count, subtitles) on light home history.
const Color kFlowHomeTransactionCaptionMuted = Color(0xFF64748B);

/// Elevated transaction row (Home): `rgba(241,245,249,1)` border.
const Color kFlowHomeTransactionCardBorder = Color(0xFFF1F5F9);

/// `box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.05)`.
const Color kFlowHomeTransactionCardShadowColor = Color.fromRGBO(
  0,
  0,
  0,
  0.05,
);

/// Step progress inactive segment — light (`SetupProfileStepHeader`).
const Color kFlowSetupProfileProgressTrackLight = Color(0xFFE2E8F0);

/// `AccountEditPage` redesign — light mode tokens (match Figma).
const Color kFlowAccountEditFieldFill = Color(0xFFF8FAFC);
const Color kFlowAccountEditRowFill = Color(0xFFF8FAFC);
const Color kFlowAccountEditHeroFill = Color(0xFFEFF6FF);

/// Inner circle on [AccountEditPage] hero when no account theme color is set
/// (same blue as setup primary accents: `rgb(37, 140, 244)`).
const Color kFlowAccountEditHeroInnerBlue = Color.fromRGBO(37, 140, 244, 1);

/// Inner blue circle diameter ÷ outer rounded-square side (design ~65–70%).
const double kFlowAccountEditHeroInnerCircleScale = 0.68;

/// `AccountEditPage` account name field: `1px solid rgba(226, 232, 240, 1)`.
const Color kFlowAccountEditNameFieldBorder = Color(0xFFE2E8F0);

/// Account name `TextFormField` height (Figma).
const double kFlowAccountEditNameFieldHeight = 56.0;

/// Account name field max width (Figma); narrower screens use full width minus page padding.
const double kFlowAccountEditNameFieldMaxWidth = 358.0;

/// Exclude-from-balance card minimum height on [AccountEditPage] (Figma 74); the card may grow slightly so `Switch` + text never clip.
const double kFlowAccountEditExcludeCardHeight = 74.0;

const Color kFlowAccountEditTitleColor = Color(0xFF0F172A);

/// `MonthSelectorSheet` redesign — light mode tokens (match Figma).
///
/// Chip border: slate-200 (`#E2E8F0`).
const Color kFlowMonthSelectorChipBorderLight = Color(0xFFE2E8F0);

/// `MonthSelectorSheet` — idle chip label ink (slate-900).
const Color kFlowMonthSelectorChipInkLight = kFlowHomeTransactionHeadingInk;

/// `MonthSelectorSheet` — year pill fill (sky-50, `#EFF6FF`).
const Color kFlowMonthSelectorYearPillFillLight = Color(0xFFEFF6FF);

/// `MonthSelectorSheet` — chevron icon ink (slate-400, `#94A3B8`).
const Color kFlowMonthSelectorChevronInkLight = Color(0xFF94A3B8);

/// `MonthSelectorSheet` — "Now" button fill (slate-100, `#F1F5F9`).
const Color kFlowMonthSelectorNowFillLight = Color(0xFFF1F5F9);

/// `MonthSelectorSheet` — "Now" button ink (gray-900, `#111827`).
const Color kFlowMonthSelectorNowInkLight = Color(0xFF111827);

/// `YearSelectorSheet` — adjacent rows ("year - 1" / "year + 1") ink
/// (slate-300, `#CBD5E1`). The middle row (selected year) uses
/// [ColorScheme.primary] inside [kFlowMonthSelectorYearPillFillLight].
const Color kFlowYearSelectorPastInkLight = Color(0xFFCBD5E1);

/// `SelectCustomDateRangeSheet` — "SELECTED RANGE" hero card fill (light blue,
/// reuses the year-pill sky-50 tint `#EFF6FF`).
const Color kFlowDateRangeSelectedCardFillLight =
    kFlowMonthSelectorYearPillFillLight;

/// `SelectCustomDateRangeSheet` — in-range day pill background (blue-100,
/// `#DBEAFE`).
const Color kFlowDateRangePillFillLight = Color(0xFFDBEAFE);

/// `SelectCustomDateRangeSheet` — Sunday header letter ink (red-500, `#EF4444`).
const Color kFlowDateRangeSundayInkLight = Color(0xFFEF4444);

/// `SelectCustomDateRangeSheet` — Mon..Sat header letter ink (slate-300,
/// `#CBD5E1`).
const Color kFlowDateRangeWeekdayInkLight = Color(0xFFCBD5E1);

/// `SelectMultiAccountSheet` — selected row card fill (reuses sky-50 tint).
const Color kFlowAccountRowSelectedFillLight =
    kFlowDateRangeSelectedCardFillLight;

/// `SelectMultiAccountSheet` — selected row border (sky-200, `#BFDBFE`).
const Color kFlowAccountRowSelectedBorderLight = Color(0xFFBFDBFE);

/// `SelectMultiAccountSheet` — idle indicator circle stroke (slate-300,
/// `#CBD5E1`).
const Color kFlowAccountRowIndicatorBorderLight = Color(0xFFCBD5E1);

/// `SelectMultiAccountSheet` — divider between rows (slate-100, `#F1F5F9`).
const Color kFlowAccountRowDividerLight = Color(0xFFF1F5F9);

/// `SelectMultiAccountSheet` — balance subtitle ink (slate-500, `#64748B`).
const Color kFlowAccountRowBalanceInkLight =
    kFlowPopularCurrenciesSectionHeading;

/// Delete-account control on [AccountEditPage] (rose danger card).
const Color kFlowAccountDeleteCardFill = Color(0xFFFFF1F2);
/// `rgba(255, 228, 230, 1)` — 2px border in light mode.
const Color kFlowAccountDeleteCardBorder = Color(0xFFFFE4E6);
const double kFlowAccountDeleteCardBorderWidth = 2.0;
/// `rgba(244, 63, 94, 1)` — icon + label in light mode.
const Color kFlowAccountDeleteCardForeground = Color(0xFFF43F5E);

/// Currency row plate (green).
const Color kFlowAccountEditCurrencyPlateBg = Color(0xFFD1FADF);
const Color kFlowAccountEditCurrencyPlateFg = Color(0xFF16A34A);

/// Account type row plate (blue).
const Color kFlowAccountEditTypePlateBg = Color(0xFFDBEAFE);
const Color kFlowAccountEditTypePlateFg = Color(0xFF2563EB);

/// Theme color row plate (orange).
const Color kFlowAccountEditColorPlateBg = Color(0xFFFFEDD5);
const Color kFlowAccountEditColorPlateFg = Color(0xFFEA580C);

/// Exclude row icon glyph color (slate).
const Color kFlowAccountEditExcludePlateFg = Color(0xFF64748B);

/// Design: `0px 8px 10px -6px` and `0px 20px 25px -5px`, `rgba(37, 140, 244, 0.25)`.
const List<BoxShadow> kFlowSetupAccountsContinueButtonShadows = [
  BoxShadow(
    offset: Offset(0, 8),
    blurRadius: 10,
    spreadRadius: -6,
    color: Color.fromRGBO(37, 140, 244, 0.25),
  ),
  BoxShadow(
    offset: Offset(0, 20),
    blurRadius: 25,
    spreadRadius: -5,
    color: Color.fromRGBO(37, 140, 244, 0.25),
  ),
];

const _defaultLightBase = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF1E88FF),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFFDBEBFF),
  onSecondary: Color(0xFF0A000D),
  error: Color(0xFFff4040),
  onError: Color(0xFFf5f6fa),
  surface: Color(0xFFF5F6FA),
  onSurface: Color(0xFF0A000D),
  tertiaryFixed: kFlowFossGlobeRingLight,
  onTertiaryFixed: Color(0xFF0A000D),
  tertiaryFixedDim: kFlowFossGlobeInnerLight,
  onTertiaryFixedVariant: Color(0xFFE3EDF7),
);

const _defaultDarkBase = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFF2C0FF),
  onPrimary: Color(0xFF222222),
  secondary: Color(0xFF111111),
  onSecondary: Color(0xFFf5f6fa),
  error: Color(0xFFff4040),
  onError: Color(0xFFf5f6fa),
  surface: Color(0xFF222222),
  onSurface: Color(0xFFF5F6FA),
  tertiaryFixed: kFlowFossGlobeRingDark,
  onTertiaryFixed: Color(0xFFF5F6FA),
  tertiaryFixedDim: kFlowFossGlobeInnerDark,
  onTertiaryFixedVariant: Color(0xFFB8D4D8),
);

class FlowColorScheme {
  final String name;
  final String? iconName;
  final bool isDark;
  final Color surface;
  final Color onSurface;
  final Color primary;
  final Color? onPrimary;
  final Color secondary;
  final Color? onSecondary;
  final Color? error;
  final Color? onError;
  final FlowCustomColors customColors;

  late final ColorScheme colorScheme;

  ThemeMode get mode => isDark ? ThemeMode.dark : ThemeMode.light;

  FlowColorScheme({
    required this.isDark,
    required this.surface,
    required this.onSurface,
    required this.primary,
    required this.secondary,
    required this.onSecondary,
    required this.customColors,
    required this.name,
    this.error,
    this.onError,
    this.onPrimary,
    this.iconName,
  }) {
    final defaultBase = (isDark ? _defaultDarkBase : _defaultLightBase);

    colorScheme = defaultBase.copyWith(
      surface: surface,
      onSurface: onSurface,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: error ?? defaultBase.error,
      onError: onError ?? defaultBase.onError,
      outlineVariant: customColors.semi,
    );
  }

  FlowColorScheme copyWith({
    Color? surface,
    Color? onSurface,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? error,
    Color? onError,
    FlowCustomColors? customColors,
    String? name,
    String? iconName,
  }) {
    return FlowColorScheme(
      isDark: isDark,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      customColors: customColors ?? this.customColors,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
    );
  }
}

enum FlowThemeMode { light, dark, oled }
