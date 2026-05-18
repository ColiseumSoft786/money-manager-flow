import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/entity/transaction_filter_preset.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/named_enum.dart";
import "package:flow/objectbox.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/providers/categories_provider.dart";
import "package:flow/providers/transaction_tags_provider.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/custom_popups.dart";
import "package:flow/utils/extensions/transaction_filter.dart";
import "package:flow/utils/optional.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/transaction_filter_head/select_filter_preset_sheet/default_filter_preset_list_tile.dart";
import "package:flow/widgets/transaction_filter_head/select_filter_preset_sheet/filter_preset_hero_card.dart";
import "package:flow/widgets/transaction_filter_head/select_filter_preset_sheet/filter_preset_list_tile.dart";
import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:objectbox/objectbox.dart";

/// Pops with an [Optional<TransactionFilter>] when a preset is selected.
class SelectFilterPresetSheet extends StatefulWidget {
  final TransactionFilter? selected;

  final VoidCallback? onSaveAsNew;

  const SelectFilterPresetSheet({super.key, this.selected, this.onSaveAsNew});

  @override
  State<SelectFilterPresetSheet> createState() =>
      _SelectFilterPresetSheetState();
}

class _SelectFilterPresetSheetState extends State<SelectFilterPresetSheet> {
  QueryBuilder<TransactionFilterPreset> transactionFilterPresetsQb() =>
      ObjectBox().box<TransactionFilterPreset>().query();

  static const Color _cancelBarFillLight = Color(0xFFE8EEF3);
  static const Color _cancelBarFillDark = Color(0xFF2C3138);

  static const Color _infoBorderLight = Color(0xFFE2E8F0);

  void pop() => context.pop();

  @override
  Widget build(BuildContext context) {
    final double maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;
    final EdgeInsets inset = EdgeInsets.only(
      bottom: MediaQuery.viewInsetsOf(context).bottom,
    );

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: inset,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(26.0)),
              ),
              child: ValueListenableBuilder(
                valueListenable: UserPreferencesService().valueNotifier,
                builder: (context, userPreferencesSnapshot, _) {
                  final String? defaultPresetUuid =
                      userPreferencesSnapshot.defaultFilterPreset;

                  return StreamBuilder<List<TransactionFilterPreset>>(
                    stream: transactionFilterPresetsQb()
                        .watch(triggerImmediately: true)
                        .map((event) => event.find()),
                    builder: (context, presetsSnapshot) {
                      if (!presetsSnapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Spinner.center(),
                        );
                      }

                      final List<TransactionFilterPreset> presets =
                          presetsSnapshot.requireData;

                      final List<Account> accounts =
                          AccountsProvider.of(context).activeAccounts;
                      final List<Category> categories =
                          CategoriesProvider.of(context).categories;
                      final List<TransactionTag> tags =
                          TransactionTagsProvider.of(context).tags;

                      final bool flowDefaultSelected =
                          widget.selected?.calculateDifferentFieldCount(
                                TransactionFilterPreset.defaultFilter,
                              ) ==
                              0;

                      bool hasPresetMatch = flowDefaultSelected;
                      TransactionFilterPreset? matchedCustom;
                      if (!flowDefaultSelected) {
                        for (final TransactionFilterPreset p in presets) {
                          if (widget.selected?.calculateDifferentFieldCount(
                                    p.filter,
                                  ) ==
                                  0) {
                            hasPresetMatch = true;
                            matchedCustom = p;
                            break;
                          }
                        }
                      }

                      late final ({String title, String subtitle}) heroCopy;
                      late final bool heroStarFilled;

                      if (flowDefaultSelected) {
                        final String title =
                            TransactionFilterPreset
                                .defaultFilter
                                .range
                                ?.preset
                                ?.localizedNameContext(context) ??
                            "transactionFilterPreset.default".t(context);
                        heroCopy = (
                          title: title,
                          subtitle:
                              TransactionFilterPreset.defaultFilter.summary(
                                context,
                              ),
                        );
                        heroStarFilled = defaultPresetUuid == null;
                      } else if (matchedCustom != null) {
                        final TransactionFilterPreset preset =
                            matchedCustom;
                        final bool presetValid =
                            preset.filter.validate(
                          accounts:
                              accounts.map((Account x) => x.uuid).toSet(),
                          categories:
                              categories.map((Category x) => x.uuid).toSet(),
                          tags: tags.map((TransactionTag x) => x.uuid).toSet(),
                        );
                        if (presetValid) {
                          heroCopy = (
                            title: preset.name,
                            subtitle: preset.filter.summary(context),
                          );
                          heroStarFilled =
                              preset.uuid == defaultPresetUuid;
                        } else {
                          heroCopy = (
                            title: preset.name,
                            subtitle: "transactionFilterPreset.invalid".t(
                              context,
                            ),
                          );
                          heroStarFilled = false;
                        }
                      } else {
                        heroCopy = (
                          title: "transactionFilterPreset.sheet.currentFiltersTitle"
                              .t(context),
                          subtitle: widget.selected?.summary(context) ?? "",
                        );
                        heroStarFilled = false;
                      }

                      final bool light =
                          Theme.of(context).brightness == Brightness.light;
                      final Color infoBorder =
                          light ? _infoBorderLight : context.colorScheme.outline;

                      return SafeArea(
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.26),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18.0),
                            Padding(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Text(
                                "transactionFilterPreset".t(context),
                                textAlign: TextAlign.start,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      color: light
                                          ? kFlowHomeTransactionHeadingInk
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 14.0),
                            Padding(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 24.0,
                              ),
                              child: FilterPresetHeroCard(
                                title: heroCopy.title,
                                subtitle: heroCopy.subtitle,
                                showFavoriteStar: heroStarFilled,
                              ),
                            ),
                            Flexible(
                              child: SlidableAutoCloseBehavior(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsetsDirectional.only(
                                    top: 8.0,
                                    start: 8.0,
                                    end: 8.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!flowDefaultSelected)
                                        DefaultFilterPresetListTile(
                                          selected: flowDefaultSelected,
                                          makeDefault: () =>
                                              makeDefault(null),
                                          isDefault: defaultPresetUuid == null,
                                          onTap: () => context.pop(
                                            Optional(
                                              TransactionFilterPreset
                                                  .defaultFilter,
                                            ),
                                          ),
                                        ),
                                      ...presets
                                          .where(
                                            (preset) =>
                                                widget.selected?.calculateDifferentFieldCount(preset.filter) != 0,
                                          )
                                          .map((preset) {
                                        final bool valid =
                                            preset.filter.validate(
                                          accounts: accounts
                                              .map((x) => x.uuid)
                                              .toSet(),
                                          categories: categories
                                              .map((x) => x.uuid)
                                              .toSet(),
                                          tags: tags
                                              .map((x) => x.uuid)
                                              .toSet(),
                                        );

                                        return FilterPresetListTile(
                                          onTap: () => context.pop(
                                            Optional(preset.filter),
                                          ),
                                          delete: () => delete(preset),
                                          makeDefault: () =>
                                              makeDefault(preset),
                                          valid: valid,
                                          preset: preset,
                                          isDefault:
                                              preset.uuid == defaultPresetUuid,
                                          selected: false,
                                        );
                                      }),
                                      if (widget.onSaveAsNew != null &&
                                          !hasPresetMatch)
                                        ListTile(
                                          onTap: () => widget.onSaveAsNew!(),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          title: Text(
                                            "transactionFilterPreset.saveAsNew".t(
                                              context,
                                            ),
                                          ),
                                          trailing: Icon(
                                            Symbols.add_rounded,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                24.0,
                                12.0,
                                24.0,
                                12.0,
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surface,
                                  borderRadius: BorderRadius.circular(14.0),
                                  border: Border.all(
                                    color: infoBorder.withValues(alpha: 0.9),
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.all(
                                    14.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Symbols.info_rounded,
                                            size: 20.0,
                                            color:
                                                kFlowSetupPrimaryCurrencyInfoTitle,
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            "transactionFilterPreset.sheet.info"
                                                .t(context),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      kFlowSetupPrimaryCurrencyInfoTitle,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        "transactionFilterPreset.saveAsNew.guide".t(
                                          context,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                              height: 1.38,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                24.0,
                                0.0,
                                24.0,
                                16.0,
                              ),
                              child: Button(
                                fullWidth: true,
                                onTap: pop,
                                backgroundColor: light
                                    ? _cancelBarFillLight
                                    : _cancelBarFillDark,
                                foregroundColor: light
                                    ? const Color(0xFF111827)
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                borderRadius: BorderRadius.circular(999.0),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14.5,
                                  horizontal: 20.0,
                                ),
                                child: Text(
                                  "general.cancel".t(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> delete(TransactionFilterPreset preset) async {
    final bool? confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "transactionFilterPreset.delete".t(context),
      child: Text("general.delete.permanentWarning".t(context)),
    );

    if (confirmation != true || !mounted) return false;

    return ObjectBox().box<TransactionFilterPreset>().remove(preset.id);
  }

  void makeDefault(TransactionFilterPreset? preset) {
    UserPreferencesService().defaultFilterPresetUuid = preset?.uuid;
  }
}
