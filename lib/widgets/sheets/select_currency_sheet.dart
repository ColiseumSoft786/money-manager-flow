import "package:flow/data/currencies.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/currency_registry.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/currency/currency_flag_avatar.dart";
import "package:flow/widgets/sheets/select_currency_sheet_theme.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:fuzzywuzzy/fuzzywuzzy.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Pops with a valid [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217) currency code [String]
class SelectCurrencySheet extends StatefulWidget {
  final String? currentlySelected;

  const SelectCurrencySheet({super.key, this.currentlySelected});

  @override
  State<SelectCurrencySheet> createState() => _SelectCurrencySheetState();
}

class _SelectCurrencySheetState extends State<SelectCurrencySheet> {
  final ScrollController _scrollController = ScrollController();

  static const List<String> _popularCodes = ["USD", "EUR", "GBP", "VND"];

  String _query = "";

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<CurrencyData> _buildResults() {
    final String normalizedQuery = _query.trim().toLowerCase();

    final List<CurrencyData> queryResults =
        (normalizedQuery.isNotEmpty
                ? extractTop<CurrencyData>(
                    query: normalizedQuery,
                    choices: CurrencyRegistryService().allCurrencies,
                    limit: CurrencyRegistryService().allCurrencies.length,
                    getter: (currencyData) =>
                        "${currencyData.code} ${currencyData.name} ${currencyData.country}",
                  ).map((result) => result.choice)
                : CurrencyRegistryService().allCurrencies)
            .groupBy((resultItem) => resultItem.code)
            .values
            .map((e) => e.firstOrNull)
            .nonNulls
            .toList();

    final int selectedItemIndex = queryResults.indexWhere(
      (element) => element.code == widget.currentlySelected,
    );

    if (selectedItemIndex > -1) {
      final CurrencyData selectedItem = queryResults.removeAt(
        selectedItemIndex,
      );
      queryResults.insert(0, selectedItem);
    }

    return queryResults;
  }

  List<CurrencyData> get _popularCurrencies {
    final Map<String, CurrencyData> grouped =
        CurrencyRegistryService().groupedCurrencies;
    return [
      for (final String code in _popularCodes)
        if (grouped[code] != null) grouped[code]!,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.92;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);
    final List<CurrencyData> results = _buildResults();
    final bool showPopular = _query.trim().isEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Material(
            color: SelectCurrencySheetTheme.canvas,
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SheetHeader(
                    title: "account.edit.selectCurrency".t(context),
                    onBack: () => context.pop(),
                  ),
                  const Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: SelectCurrencySheetTheme.divider,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 10.0),
                    child: TextField(
                      onChanged: _updateQuery,
                      onSubmitted: _updateQuery,
                      autocorrect: false,
                      enableSuggestions: false,
                      spellCheckConfiguration: SpellCheckConfiguration.disabled(),
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: SelectCurrencySheetTheme.sheetFill,
                        hintText: "currency.searchHint".t(context),
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: SelectCurrencySheetTheme.subtitleInk,
                          fontSize: 15.0,
                        ),
                        prefixIcon: Icon(
                          Symbols.search_rounded,
                          size: 22.0,
                          color: SelectCurrencySheetTheme.subtitleInk,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 12.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: SelectCurrencySheetTheme.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:  BorderSide(
                            color: SelectCurrencySheetTheme.primary(context),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showPopular && _popularCurrencies.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 10.0),
                      child: Text(
                        "setup.primaryCurrency.popular".t(context),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: SelectCurrencySheetTheme.subtitleInk,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 44.0,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _popularCurrencies.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8.0),
                        itemBuilder: (context, index) {
                          final CurrencyData currency =
                              _popularCurrencies[index];
                          final bool selected =
                              widget.currentlySelected == currency.code;

                          return _PopularCurrencyChip(
                            currency: currency,
                            selected: selected,
                            onTap: () => select(currency.code),
                          );
                        },
                      ),
                    ),
                  ],
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: SelectCurrencySheetTheme.sheetFill,
                          borderRadius: BorderRadius.circular(
                            SelectCurrencySheetTheme.cardRadius,
                          ),
                          border: Border.all(
                            color: SelectCurrencySheetTheme.border,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            SelectCurrencySheetTheme.cardRadius,
                          ),
                          child: results.isEmpty
                              ? Center(
                                  child: Text(
                                    "currency.searchNoResults".t(context),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: SelectCurrencySheetTheme.subtitleInk,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  controller: _scrollController,
                                  padding: EdgeInsets.zero,
                                  itemCount: results.length,
                                  separatorBuilder: (_, __) => const Divider(
                                    height: 1.0,
                                    thickness: 1.0,
                                    indent: 16.0,
                                    endIndent: 16.0,
                                    color: SelectCurrencySheetTheme.divider,
                                  ),
                                  itemBuilder: (context, index) {
                                    final CurrencyData data =
                                        CurrencyRegistryService()
                                            .groupedCurrencies[results[index]
                                                .code]!;

                                    return _CurrencyRow(
                                      currency: data,
                                      selected:
                                          widget.currentlySelected == data.code,
                                      onTap: () => select(data.code),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateQuery(String value) {
    _query = value;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    setState(() {});
  }

  void select(String code) {
    context.pop(code);
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _SheetHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Symbols.arrow_back_rounded,
                color: SelectCurrencySheetTheme.titleInk,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17.0,
                color: SelectCurrencySheetTheme.titleInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularCurrencyChip extends StatelessWidget {
  final CurrencyData currency;
  final bool selected;
  final VoidCallback onTap;

  const _PopularCurrencyChip({
    required this.currency,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: selected
          ? SelectCurrencySheetTheme.popularChipFill
          : SelectCurrencySheetTheme.sheetFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: selected
              ? SelectCurrencySheetTheme.popularChipBorder
              : SelectCurrencySheetTheme.border,
          width: selected ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CurrencyFlagAvatar(currency: currency, size: 32.0),
              const SizedBox(width: 8.0),
              Text(
                currency.code,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? SelectCurrencySheetTheme.primary(context)
                      : SelectCurrencySheetTheme.titleInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  final CurrencyData currency;
  final bool selected;
  final VoidCallback onTap;

  const _CurrencyRow({
    required this.currency,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: selected
          ? SelectCurrencySheetTheme.popularChipFill.withValues(alpha: 0.45)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              CurrencyFlagAvatar(currency: currency),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                        color: SelectCurrencySheetTheme.titleInk,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      currency.country.titleCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SelectCurrencySheetTheme.subtitleInk,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                currency.code,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.0,
                  color: SelectCurrencySheetTheme.codeInk(context),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 10.0),
              _CurrencyRadio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyRadio extends StatelessWidget {
  final bool selected;

  const _CurrencyRadio({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22.0,
      height: 22.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? SelectCurrencySheetTheme.primary(context) : Colors.transparent,
        border: Border.all(
          color: selected
              ? SelectCurrencySheetTheme.primary(context)
              : SelectCurrencySheetTheme.radioIdleBorder,
          width: 2.0,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8.0,
                height: 8.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
