import "package:flow/data/transactions_filter/search_data.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

final List<TransactionSearchMode> kSearchSheetModes =
    TransactionSearchMode.values
        .where((m) => m != TransactionSearchMode.none)
        .toList();

/// Pops with [TransactionSearchData].
class TransactionSearchSheet extends StatefulWidget {
  final TransactionSearchData? searchData;

  const TransactionSearchSheet({super.key, this.searchData});

  @override
  State<TransactionSearchSheet> createState() => _TransactionSearchSheetState();
}

class _TransactionSearchSheetState extends State<TransactionSearchSheet> {
  late TransactionSearchData _searchData;
  late final TextEditingController _controller;

  static const Color _surfaceFillLight = Color(0xFFF1F5F9);
  static const Color _chipIdleLight = Color(0xFFEBEFF3);
  static const Color _chipIdleInk = Color(0xFF475569);
  static const Color _mutedSectionLabelLight = Color(0xFF94A3B8);
  static const Color _dividerLight = Color(0xFFE2E8F0);

  static const Color _clearBarFillLight = Color(0xFFE8EEF3);
  static const Color _clearBarInkLight = Color(0xFF111827);

  @override
  void initState() {
    super.initState();
    _searchData = widget.searchData ?? const TransactionSearchData();
    if (_searchData.mode == TransactionSearchMode.none) {
      _searchData = _searchData.copyWithOptional(
        mode: TransactionSearchMode.smart,
      );
    }
    _controller = TextEditingController(text: _searchData.keyword ?? "");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool light = theme.brightness == Brightness.light;
    final double maxSheetHeight =
        MediaQuery.sizeOf(context).height * 0.85;

    final Color fieldBg = light
        ? _surfaceFillLight
        : theme.colorScheme.surfaceContainerHighest;
    final Color chipIdleBg =
        light ? _chipIdleLight : theme.colorScheme.surfaceContainerHigh;
    final Color chipIdleFg =
        light ? _chipIdleInk : theme.colorScheme.onSurface;
    final Color sectionLabelFg = light
        ? _mutedSectionLabelLight
        : theme.colorScheme.onSurfaceVariant;
    final Color dividerColor =
        light ? _dividerLight : theme.colorScheme.outlineVariant;

    final Color primaryAccent = light
        ? kFlowSetupPrimaryCurrencyInfoTitle
        : theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Material(
            color: light ? Colors.white : theme.colorScheme.surface,
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(26.0)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10.0),
                  Center(
                    child: Container(
                      width: 36.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8.0,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).cancelButtonLabel,
                            onPressed: () => context.pop(),
                            icon: Icon(Symbols.close_rounded, fill: light ? 0.0 : 1.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48.0,
                          ),
                          child: Text(
                            "transactions.query.filter.keyword".t(context),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: light
                                  ? kFlowHomeTransactionHeadingInk
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        24.0,
                        8.0,
                        24.0,
                        16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SearchTitleField(
                            controller: _controller,
                            fillColor: fieldBg,
                            hintText:
                                "transactions.query.filter.keyword.hint"
                                    .t(context),
                            onChanged: () => setState(() {}),
                            onSubmitted: popWithResult,
                          ),
                          const SizedBox(height: 26.0),
                          Text(
                            "transactions.query.filter.keyword.searchModeHeading"
                                .t(context),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: sectionLabelFg,
                              fontSize: 13.0,
                              letterSpacing: 1.15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (
                                  int i = 0;
                                  i < kSearchSheetModes.length;
                                  i++
                                ) ...[
                                  if (i != 0) const SizedBox(width: 10.0),
                                  _SearchModeChip(
                                    label: kSearchSheetModes[i]
                                        .localizedTextKey
                                        .t(context),
                                    selected:
                                        kSearchSheetModes[i] == _searchData.mode,
                                    sparkle: kSearchSheetModes[i] ==
                                        TransactionSearchMode.smart,
                                    selectedBg: primaryAccent,
                                    idleBg: chipIdleBg,
                                    idleInk: chipIdleFg,
                                    onTap: () {
                                      _searchData =
                                          _searchData.copyWithOptional(
                                        mode: kSearchSheetModes[i],
                                      );
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 18.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 26.0,
                                height: 26.0,
                                child: Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.5),
                                  ),
                                  value: _searchData.includeDescription,
                                  onChanged: _updateIncludeDescription,
                                  visualDensity: VisualDensity.compact.copyWith(
                                    horizontal: -4.0,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 14.0),
                              Expanded(
                                child: Text(
                                  "transactions.query.filter.keyword.includeDescriptionInResults"
                                      .t(context),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: dividerColor,
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      24.0,
                      16.0,
                      24.0,
                      20.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 36,
                          child: Button(
                            onTap: clear,
                            fullWidth: true,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14.5,
                              horizontal: 14.0,
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                            backgroundColor: light
                                ? _clearBarFillLight
                                : theme.colorScheme.surfaceContainerHigh,
                            foregroundColor: light
                                ? _clearBarInkLight
                                : theme.colorScheme.onSurface,
                            child: Text(
                              "transactions.query.filter.keyword.clear".t(
                                context,
                              ),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          flex: 62,
                          child: Button(
                            onTap: popWithResult,
                            fullWidth: true,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14.5,
                              horizontal: 16.0,
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                            backgroundColor: primaryAccent,
                            foregroundColor: Colors.white,
                            iconColor: Colors.white,
                            elevation: light ? 2.2 : 0.0,
                            shadowColor:
                                Colors.black.withValues(alpha: light ? 0.18 : 0),
                            leading: const Icon(
                              Symbols.task_alt_rounded,
                              fill: 1,
                              size: 18.0,
                            ),
                            child: Text(
                              "general.done".t(context),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  void _updateIncludeDescription(bool? includeDescription) {
    if (includeDescription == null) return;

    _searchData = _searchData.copyWithOptional(
      includeDescription: includeDescription,
    );

    setState(() {});
  }

  void clear() {
    context.pop(const TransactionSearchData());
  }

  void popWithResult() {
    final String trimmed = _controller.text.trim();
    context.pop(
      _searchData.copyWithOptional(
        keyword:
            trimmed.isEmpty ? const Optional<String>(null) : Optional(trimmed),
      ),
    );
  }
}

class _SearchModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool sparkle;
  final VoidCallback onTap;

  final Color selectedBg;
  final Color idleBg;
  final Color idleInk;

  const _SearchModeChip({
    required this.label,
    required this.selected,
    required this.sparkle,
    required this.onTap,
    required this.selectedBg,
    required this.idleBg,
    required this.idleInk,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 14.0,
            vertical: 8.0,
          ),
          decoration: BoxDecoration(
            color: selected ? selectedBg : idleBg,
            borderRadius: BorderRadius.circular(999.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: sparkle ? 6.0 : 0.0,
            children: [
              if (sparkle)
                Icon(
                  Symbols.auto_awesome_rounded,
                  size: 14.0,
                  color:
                      selected ? Colors.white : idleInk.withValues(alpha: 0.55),
                  fill: selected ? 1 : 0,
                ),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? Colors.white : idleInk,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Search input matching the mockup spec.
///
/// - **width**: 342 (max; clamped to parent so smaller screens shrink gracefully)
/// - **height**: 55
/// - **padding**: top 18, right 16, bottom 18, **left 48** (icon centred in the gutter)
/// - **border-radius**: 16
/// - **fill**: `rgba(241, 245, 249, 1)`
class _SearchTitleField extends StatelessWidget {
  final TextEditingController controller;
  final Color fillColor;
  final String hintText;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _SearchTitleField({
    required this.controller,
    required this.fillColor,
    required this.hintText,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? hintStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
      fontWeight: FontWeight.w400,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 342.0),
        child: SizedBox(
          height: 55.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48.0,
                  child: Center(
                    child: Icon(
                      Symbols.search_rounded,
                      size: 20.0,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: 18.0,
                      end: 16.0,
                      bottom: 18.0,
                    ),
                    child: TextField(
                      autofocus: true,
                      controller: controller,
                      onChanged: (_) => onChanged(),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => onSubmitted(),
                      style: theme.textTheme.bodyLarge,
                      cursorHeight: 20.0,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: hintText,
                        hintStyle: hintStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
