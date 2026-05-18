import "dart:math" as math;

import "package:flow/data/setup/default_categories.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/add_category_card.dart";
import "package:flow/widgets/category_card.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/setup/categories/category_preset_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:local_hero/local_hero.dart";
import "package:material_symbols_icons/symbols.dart";

class SetupCategoriesPage extends StatefulWidget {
  /// When [true], the page will close itself upon completion.
  ///
  /// Defaults to [false]
  final bool standalone;

  /// When [true], all possible category presets will be selected after page loads
  ///
  /// Defaults to [true]
  final bool selectAll;

  const SetupCategoriesPage({
    super.key,
    this.standalone = false,
    this.selectAll = true,
  });

  @override
  State<SetupCategoriesPage> createState() => _SetupCategoriesPageState();
}

class _SetupCategoriesPageState extends State<SetupCategoriesPage> {
  QueryBuilder<Category> qb() =>
      ObjectBox().box<Category>().query().order(Category_.createdDate);

  late final List<Category> presetCategories;

  bool busy = false;

  @override
  void initState() {
    super.initState();

    final Query<Category> existingCategoriesQuery = qb().build();

    final List<Category> existingCategories = existingCategoriesQuery.find();

    existingCategoriesQuery.close();

    presetCategories = getCategoryPresets()
        .where(
          (category) => !existingCategories.any(
            (existingCategory) =>
                existingCategory.uuid == category.uuid ||
                existingCategory.name == category.name,
          ),
        )
        .toList();

    if (widget.selectAll) {
      // Select all in upon loading
      for (final preset in presetCategories) {
        preset.id = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Color screenBackground =
        light ? Colors.white : Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: screenBackground,
        surfaceTintColor: light ? Colors.transparent : null,
        title: Text("setup.categories.setup".t(context)),
      ),
      body: StreamBuilder(
        stream: qb().watch(triggerImmediately: true),
        builder: (context, snapshot) {
          final List<Category> currentCategories = snapshot.data?.find() ?? [];

          final Set<bool> presetSelections = presetCategories
              .map((preset) => preset.id == 0)
              .toSet();

          final bool? presetSelectedAll = presetSelections.length == 1
              ? presetSelections.first
              : null;

          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    if (presetCategories.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: selectAll,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("general.select.all".t(context)),
                              const SizedBox(width: 8.0),
                              IgnorePointer(
                                child: Checkbox(
                                  value: presetSelectedAll,
                                  onChanged: (value) => (),
                                  tristate: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16.0),
                    const AddCategoryCard(),
                    const SizedBox(height: 16.0),
                    LocalHeroScope(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: presetCategories
                            .map(
                              (preset) => LocalHero(
                                key: ValueKey(preset.uuid),
                                tag: preset.uuid,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: CategoryPresetCard(
                                    category: preset,
                                    onSelect: (selected) =>
                                        select(preset.uuid, selected),
                                    selected: preset.id == 0,
                                    preexisting: false,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    if (currentCategories.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      WavyDivider(),
                      const SizedBox(height: 16.0),
                      ListHeader(
                        "setup.categories.existing".t(context),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12.0),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          mainAxisExtent: 88.0,
                        ),
                        itemCount: currentCategories.length,
                        itemBuilder: (context, index) {
                          final Category e = currentCategories[index];
                          return CategoryCard(
                            category: e,
                            onTapOverride: const Optional(null),
                            showAmount: false,
                            surfaceColor: light ? Colors.white : null,
                            elevation: light ? 4.0 : 0.0,
                            shadowColor: light
                                ? Colors.black.withValues(alpha: 0.14)
                                : null,
                            categoryNameStyle:
                                context.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      height: 1.28,
                                    ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: ColoredBox(
        color: screenBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPrimaryBottomButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Same treatment as [SetupAccountsPage] continue CTA: 342×68 (clamped), 24px radius, blue + dual shadows.
  Widget _buildPrimaryBottomButton(BuildContext context) {
    final double maxWidth = MediaQuery.sizeOf(context).width - 32.0;
    final double width = math.min(342.0, maxWidth);
    final bool isDone = widget.standalone;

    return Opacity(
      opacity: busy ? 0.55 : 1.0,
      child: SizedBox(
        width: width,
        height: 68.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: kFlowSetupAccountsContinueButtonFill,
            borderRadius: const BorderRadius.all(Radius.circular(24.0)),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(24.0)),
              onTap: busy ? null : save,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isDone
                          ? "general.done".t(context)
                          : "setup.next".t(context),
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.0,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Icon(
                      isDone
                          ? Symbols.check_rounded
                          : Symbols.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22.0,
                      fill: 0.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void select(String uuid, bool selected) {
    final Category? preset = presetCategories.firstWhereOrNull(
      (element) => element.uuid == uuid,
    );

    if (preset != null) {
      preset.id = selected ? 0 : -1;
    }

    presetCategories.sort((a, b) => b.id.compareTo(a.id));
    setState(() {});
  }

  void selectAll() {
    final bool select = presetCategories.any((element) => element.id == -1);

    for (int i = 0; i < presetCategories.length; i++) {
      presetCategories[i].id = select ? 0 : -1;
    }

    setState(() => {});
  }

  void save() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      final List<Category> selectedCategories = presetCategories
          .where((element) => element.id == 0)
          .toList();

      await ObjectBox().box<Category>().putManyAsync(selectedCategories);

      presetCategories.removeWhere(
        (element) =>
            selectedCategories.indexWhere(
              (selected) => element.uuid == selected.uuid,
            ) !=
            -1,
      );

      if (mounted) {
        if (widget.standalone) {
          context.pop();
        } else {
          await context.push("/setup/profile");
        }
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
