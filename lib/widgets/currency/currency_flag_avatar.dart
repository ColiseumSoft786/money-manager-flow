import "package:country_flags/country_flags.dart";
import "package:flow/data/currencies.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Flag or fallback plate for a currency row.
class CurrencyFlagAvatar extends StatelessWidget {
  final CurrencyData currency;
  final double size;

  const CurrencyFlagAvatar({
    super.key,
    required this.currency,
    this.size = 40.0,
  });

  static final RegExp _isoCountryCode = RegExp(r"^[A-Za-z]{2}$");

  @override
  Widget build(BuildContext context) {
    if (currency.isCrypto) {
      return _FallbackPlate(
        size: size,
        child: Icon(
          Symbols.currency_bitcoin_rounded,
          size: size * 0.5,
          color: context.flowAccent.iconPlateInk,
          fill: 0.0,
        ),
      );
    }

    final String country = currency.country.trim();
    if (_isoCountryCode.hasMatch(country)) {
      return _FlagImage(
        size: size,
        builder: () => CountryFlag.fromCountryCode(
          country.toUpperCase(),
          theme: _imageTheme(size),
        ),
      );
    }

    return _FlagImage(
      size: size,
      builder: () => CountryFlag.fromCurrencyCode(
        currency.code,
        theme: _imageTheme(size),
      ),
      fallbackCode: currency.code,
    );
  }

  static ImageTheme _imageTheme(double size) => ImageTheme(
    width: size,
    height: size * 0.72,
    shape: RoundedRectangle(10.0),
  );
}

class _FlagImage extends StatelessWidget {
  final double size;
  final Widget Function() builder;
  final String? fallbackCode;

  const _FlagImage({
    required this.size,
    required this.builder,
    this.fallbackCode,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: SizedBox(
        width: size,
        height: size * 0.72,
        child: Builder(
          builder: (context) {
            try {
              return builder();
            } catch (_) {
              return _FallbackPlate(
                size: size,
                child: Text(
                  fallbackCode?.substring(0, 2) ?? "?",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: size * 0.28,
                    color: context.flowAccent.iconPlateInk,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _FallbackPlate extends StatelessWidget {
  final double size;
  final Widget child;

  const _FallbackPlate({required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.72,
      decoration: BoxDecoration(
        color: kFlowSetupAddCategoryIconPlateFill,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
