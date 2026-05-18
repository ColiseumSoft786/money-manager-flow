import "package:flow/data/exchange_rates.dart";
import "package:flow/data/setup/default_categories.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/add_category_card.dart";
import "package:flow/widgets/categories/no_categories.dart";
import "package:flow/widgets/category_card.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/list_header.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  QueryBuilder<Category> qb() =>
      ObjectBox().box<Category>().query().order(Category_.createdDate);

  @override
  void initState() {
    super.initState();

    if (TransitiveLocalPreferences().usesNonPrimaryCurrency.get()) {
      ExchangeRatesService().getPrimaryCurrencyRates();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme-aware shell, identical to SetupCategoriesPage so the two screens
    // share the same look.
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Color screenBackground =
        light ? Colors.white : Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: screenBackground,
        surfaceTintColor: light ? Colors.transparent : null,
        title: Text("categories".t(context)),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Category>>(
          stream: qb()
              .watch(triggerImmediately: true)
              .map((event) => event.find()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Spinner.center();
            }

            final List<Category> categories = snapshot.requireData;

            final bool showPresetsButton = !getCategoryPresets().every(
              (preset) =>
                  categories.any((category) => category.uuid == preset.uuid),
            );

            // True empty state keeps the existing onboarding-style placeholder
            // so the data-zero branch of the page is preserved 1:1.
            if (categories.isEmpty) {
              return const NoCategories();
            }

            return ValueListenableBuilder(
              valueListenable: ExchangeRatesService().exchangeRatesCache,
              builder: (context, exchangeRatesCache, _) {
                return ValueListenableBuilder(
                  valueListenable: UserPreferencesService().valueNotifier,
                  builder: (context, userPreferences, child) {
                    final bool excludeTransfersInTotal =
                        userPreferences.excludeTransfersFromFlow;
                    final String primaryCurrency =
                        UserPreferencesService().primaryCurrency;

                    return _buildSetupStyleBody(
                      context: context,
                      light: light,
                      categories: categories,
                      showPresetsButton: showPresetsButton,
                      rates: exchangeRatesCache?.get(primaryCurrency),
                      excludeTransfersInTotal: excludeTransfersInTotal,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Mirrors the visual layout of [SetupCategoriesPage]:
  ///   `AddCategoryCard` -> optional `Add from presets` -> `WavyDivider` ->
  ///   `ListHeader` -> 2-column elevated grid of `CategoryCard`s.
  ///
  /// Only stylistic difference from setup: `showAmount: true` (since this
  /// page's purpose is to surface per-category totals — that's data, not
  /// design) and a slightly taller `mainAxisExtent` to fit the amount line.
  Widget _buildSetupStyleBody({
    required BuildContext context,
    required bool light,
    required List<Category> categories,
    required bool showPresetsButton,
    required ExchangeRates? rates,
    required bool excludeTransfersInTotal,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8.0),
            const AddCategoryCard(),
            if (showPresetsButton) ...[
              const SizedBox(height: 12.0),
              Button(
                onTap: () => context.push(
                  "/setup/categories?standalone=true&selectAll=false",
                ),
                leading: const Icon(Symbols.category_rounded),
                child: Text("categories.addFromPresets".t(context)),
              ),
            ],
            const SizedBox(height: 16.0),
            const WavyDivider(),
            const SizedBox(height: 16.0),
            ListHeader("categories".t(context), padding: EdgeInsets.zero),
            const SizedBox(height: 12.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                mainAxisExtent: 116.0,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final Category category = categories[index];
                return CategoryCard(
                  category: category,
                  rates: rates,
                  excludeTransfersInTotal: excludeTransfersInTotal,
                  surfaceColor: light ? Colors.white : null,
                  elevation: light ? 4.0 : 0.0,
                  shadowColor: light
                      ? Colors.black.withValues(alpha: 0.14)
                      : null,
                  categoryNameStyle: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0,
                    height: 1.28,
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
