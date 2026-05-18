import "package:flow/constants.dart";
import "package:flow/data/prefs/change_visuals.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/routes/preferences/change_visuals/change_visuals_preferences_theme.dart";
import "package:flow/routes/preferences/change_visuals/change_visuals_trend_data.dart";
import "package:flow/routes/preferences/change_visuals/widgets/change_visuals_debug_panel.dart";
import "package:flow/routes/preferences/change_visuals/widgets/change_visuals_growth_card.dart";
import "package:flow/routes/preferences/change_visuals/widgets/change_visuals_section_header.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class ChangeVisualsPreferencesPage extends StatefulWidget {
  const ChangeVisualsPreferencesPage({super.key});

  @override
  State<ChangeVisualsPreferencesPage> createState() =>
      _ChangeVisualsPreferencesPageState();
}

class _ChangeVisualsPreferencesPageState
    extends State<ChangeVisualsPreferencesPage> {
  ChangeVisualsTrendData _trendData = ChangeVisualsTrendData.empty;
  bool _loadingTrends = true;

  @override
  void initState() {
    super.initState();
    _loadTrendData();
  }

  Future<void> _loadTrendData() async {
    final ChangeVisualsTrendData data = await ChangeVisualsTrendLoader.load();
    if (!mounted) return;
    setState(() {
      _trendData = data;
      _loadingTrends = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChangeVisuals changeVisuals = UserPreferencesService().changeVisuals;

    return Scaffold(
      backgroundColor: ChangeVisualsPreferencesTheme.canvas,
      appBar: AppBar(
        backgroundColor: ChangeVisualsPreferencesTheme.cardFill,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          "preferences.changeVisuals.settingsTitle".t(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: ChangeVisualsPreferencesTheme.titleInk,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: kFlowAccountRowDividerLight,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ChangeVisualsSectionHeader(
                first: true,
                label: "preferences.changeVisuals.section.growthTrends".t(
                  context,
                ),
              ),
              if (_loadingTrends)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                ChangeVisualsGrowthCard(
                  kind: ChangeVisualsGrowthKind.income,
                  changeVisuals: changeVisuals,
                  trendData: _trendData,
                  onToggleArrow: () {
                    update(
                      changeVisuals.copyWith(
                        incomeIncreaseUpArrow:
                            !changeVisuals.incomeIncreaseUpArrow,
                      ),
                    );
                  },
                  onToggleColor: () {
                    update(
                      changeVisuals.copyWith(
                        incomeIncreaseGreen: !changeVisuals.incomeIncreaseGreen,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12.0),
                ChangeVisualsGrowthCard(
                  kind: ChangeVisualsGrowthKind.expense,
                  changeVisuals: changeVisuals,
                  trendData: _trendData,
                  onToggleArrow: () {
                    update(
                      changeVisuals.copyWith(
                        expenseIncreaseUpArrow:
                            !changeVisuals.expenseIncreaseUpArrow,
                      ),
                    );
                  },
                  onToggleColor: () {
                    update(
                      changeVisuals.copyWith(
                        expenseIncreaseRed: !changeVisuals.expenseIncreaseRed,
                      ),
                    );
                  },
                ),
              ],
              if (flowDebugMode || kDebugMode) ...[
                ChangeVisualsSectionHeader(
                  label: "preferences.changeVisuals.section.debugStatistics".t(
                    context,
                  ),
                ),
                ChangeVisualsDebugPanel(
                  serializedVisuals: changeVisuals.serialize(),
                  trendData: _trendData,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void update(ChangeVisuals newVisuals) {
    UserPreferencesService().changeVisuals = newVisuals;
    if (LocalPreferences().enableHapticFeedback.value == true) {
      HapticFeedback.lightImpact();
    }
    setState(() {});
  }
}
