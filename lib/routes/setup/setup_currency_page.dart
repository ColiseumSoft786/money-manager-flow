import "package:flow/data/currencies.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/currency_registry.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/sheets/select_currency_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.dart";

class SetupCurrencyPage extends StatefulWidget {
  const SetupCurrencyPage({super.key});

  @override
  State<SetupCurrencyPage> createState() => _SetupCurrencyPageState();
}

class _SetupCurrencyPageState extends State<SetupCurrencyPage> {
  static const double _infoCardRadius = 16.0;
  static const double _infoImageRadius = 12.0;
  static const double _infoImageHeight = 150.0;
  static const double _popularCardRadius = 12.0;
  static const double _symbolCircleDiameter = 44.0;

  /// Shown first for quick selection (matches common onboarding picks).
  static const List<String> _popularCurrencyCodes = [
    "USD",
    "VND",
    "EUR",
    "GBP",
  ];

  final TextEditingController _textController = TextEditingController(
    text: "~~~",
  );

  String? _currency;

  dynamic error;

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  void _applyCurrencySelection(String code) {
    setState(() {
      _currency = code;
      _textController.text = code;
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color pageBackground = context.popularCurrencyTileCardFill;
    final CurrencyRegistryService registry = CurrencyRegistryService();
    final List<CurrencyData> popular = <CurrencyData>[
      for (final String code in _popularCurrencyCodes)
        if (registry.groupedCurrencies[code] != null)
          registry.groupedCurrencies[code]!,
    ];

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        title: Text("setup.primaryCurrency.setup".t(context)),
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
      ),
      body: ColoredBox(
        color: pageBackground,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: context.setupPrimaryCurrencyInfoPanelFill,
                      borderRadius: BorderRadius.circular(_infoCardRadius),
                      border: Border.all(
                        color: context.setupPrimaryCurrencyInfoPanelBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(_infoImageRadius),
                          child: Image.asset(
                            "assets/images/currency.png",
                            height: _infoImageHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          "setup.primaryCurrency.cardTitle".t(context),
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.setupPrimaryCurrencyInfoTitleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "setup.primaryCurrency.description".t(
                            context,
                            {"appName": "appName".t(context)},
                          ),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.setupPrimaryCurrencyInfoPanelBody,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    "setup.primaryCurrency.popular".t(context),
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.popularCurrenciesSectionHeadingColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Theme(
                    data: Theme.of(context).copyWith(
                      radioTheme: RadioThemeData(
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return scheme.primary;
                          }
                          return scheme.outline;
                        }),
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < popular.length; i++) ...[
                          _PopularCurrencyTile(
                            data: popular[i],
                            symbol: NumberFormat.simpleCurrency(
                              name: popular[i].code,
                            ).currencySymbol,
                            groupValue: _currency,
                            onSelect: _applyCurrencySelection,
                          ),
                          if (i < popular.length - 1)
                            const SizedBox(height: 10.0),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    readOnly: true,
                    controller: _textController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => save(),
                    decoration: const InputDecoration(border: InputBorder.none),
                    textAlign: TextAlign.center,
                    style: _currency == null
                        ? context.textTheme.displaySmall?.semi(context)
                        : context.textTheme.displaySmall,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      error.toString(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.flowColors.expense,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16.0),
                  Center(
                    child: Button(
                      dashedBorder: true,
                      fullWidth: true,
                      backgroundColor: Colors.transparent,
                      foregroundColor:
                          context.popularCurrenciesSectionHeadingColor,
                      iconColor: context.popularCurrenciesSectionHeadingColor,
                      dashedBorderColor:
                          context.popularCurrenciesSectionHeadingColor
                              .withAlpha(0xCC),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(999.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 20.0,
                      ),
                      leading: const Icon(Symbols.globe_rounded),
                      onTap: () => selectCurrency(),
                      child: Text("setup.primaryCurrency.choose".t(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: ColoredBox(
        color: pageBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Spacer(),
                Button(
                  onTap: save,
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  iconColor: scheme.onPrimary,
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 14.0,
                  ),
                  trailing: const Icon(Symbols.chevron_right_rounded),
                  child: Text("setup.next".t(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void selectCurrency() async {
    final String? result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => SelectCurrencySheet(currentlySelected: _currency),
      isScrollControlled: true,
    );

    if (!mounted) return;

    _textController.text = result ?? _currency ?? "~~~";

    setState(() {
      _currency = result ?? _currency;
    });
  }

  void save() async {
    if (_currency == null) {
      error = "error.input.mustBeNotEmpty".t(context);

      setState(() {});

      return;
    }

    UserPreferencesService().primaryCurrency = _currency!;

    if (!mounted) return;

    await context.push("/setup/accounts");
  }
}

class _PopularCurrencyTile extends StatelessWidget {
  const _PopularCurrencyTile({
    required this.data,
    required this.symbol,
    required this.groupValue,
    required this.onSelect,
  });

  final CurrencyData data;
  final String symbol;
  final String? groupValue;
  final void Function(String code) onSelect;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final bool selected = groupValue == data.code;

    return Material(
      color: selected
          ? scheme.primary.withValues(alpha: 0.10)
          : context.popularCurrencyTileCardFill,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          _SetupCurrencyPageState._popularCardRadius,
        ),
        side: BorderSide(
          color: selected
              ? scheme.primary
              : context.popularCurrencyCardBorderColor,
          width: selected ? 2.0 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onSelect(data.code),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: _SetupCurrencyPageState._symbolCircleDiameter,
                height: _SetupCurrencyPageState._symbolCircleDiameter,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.popularCurrencySymbolPlateColor,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        symbol,
                        maxLines: 1,
                        style: context.textTheme.titleLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.name,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      data.code,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.popularCurrencyTileCodeColor,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: data.code,
                groupValue: groupValue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: (String? value) {
                  if (value != null) {
                    onSelect(value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
