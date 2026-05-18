import "dart:async";

import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/exchange_rates.dart";
import "package:flow/services/notifications.dart";
import "package:flow/services/sync/icloud_syncer.dart";
import "package:flow/services/transactions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/home/preferences/profile_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:simple_icons/simple_icons.dart";

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _debugDbBusy = false;
  bool _debugPrefsBusy = false;
  bool _debugICloudBusy = false;

  // Tracks which sections are currently expanded. Only `accountSettings` is
  // open by default — matches the mockup.
  final Set<String> _expandedSections = <String>{"accountSettings"};

  void _toggleSection(String id) {
    setState(() {
      if (_expandedSections.contains(id)) {
        _expandedSections.remove(id);
      } else {
        _expandedSections.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Theme-aware palette: keep the Figma light tokens in light mode, fall
    // back to material `colorScheme` roles in dark mode. Mirrors the pattern
    // used in the filter sheets.
    final bool light = theme.brightness == Brightness.light;
    final Color sectionLabelInk = light
        ? const Color(0xFF94A3B8) // slate-400
        : theme.colorScheme.onSurfaceVariant;
    final Color sectionDivider = light
        ? const Color(0xFFE2E8F0) // slate-200
        : theme.colorScheme.outlineVariant;
    final Color rowFill = light
        ? const Color(0xFFF8FAFC) // slate-50
        : theme.colorScheme.surfaceContainerHigh;
    final Color rowInk =
        light ? kFlowHomeTransactionHeadingInk : theme.colorScheme.onSurface;
    final Color chevronInk = light
        ? const Color(0xFF94A3B8) // slate-400
        : theme.colorScheme.onSurfaceVariant;
    final Color slateInk = light
        ? const Color(0xFF475569) // slate-600 (used for neutral debug icons)
        : theme.colorScheme.onSurfaceVariant;

    final _RowStyle rowStyle = _RowStyle(
      fill: rowFill,
      ink: rowInk,
      chevronInk: chevronInk,
      light: light,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24.0),
          const Center(
            child: ProfileCard(
              size: 96.0,
              borderRadius: BorderRadius.all(Radius.circular(48.0)),
            ),
          ),
          const SizedBox(height: 24.0),

          _ProfileSection(
            id: "accountSettings",
            title: "tabs.profile.section.accountSettings".t(context),
            expanded: _expandedSections.contains("accountSettings"),
            onToggle: () => _toggleSection("accountSettings"),
            labelInk: sectionLabelInk,
            chevronInk: chevronInk,
            dividerColor: sectionDivider,
            children: [
              _ProfileRow(
                label: "accounts".t(context),
                icon: Symbols.credit_card_rounded,
                plateInk: const Color(0xFF2563EB), // blue-600
                onTap: () => context.push("/accounts"),
                style: rowStyle,
              ),
              _ProfileRow(
                label: "categories".t(context),
                icon: Symbols.apps_rounded,
                plateInk: const Color(0xFF7C3AED), // violet-600
                onTap: () => context.push("/categories"),
                style: rowStyle,
              ),
              _ProfileRow(
                label: "transaction.tags".t(context),
                icon: Symbols.sell_rounded,
                plateInk: const Color(0xFFEA580C), // orange-600
                onTap: () => context.push("/transactionTags"),
                style: rowStyle,
              ),
              _ProfileRow(
                label: "preferences.transactions.pending".t(context),
                icon: Symbols.schedule_rounded,
                plateInk: const Color(0xFFDB2777), // pink-600
                onTap: () => context.push("/transactions/pending"),
                style: rowStyle,
              ),
            ],
          ),

          // _ProfileSection(
          //   id: "community",
          //   title: "tabs.profile.section.community".t(context),
          //   expanded: _expandedSections.contains("community"),
          //   onToggle: () => _toggleSection("community"),
          //   labelInk: sectionLabelInk,
          //   chevronInk: chevronInk,
          //   dividerColor: sectionDivider,
          //   children: [
          //     _ProfileRow(
          //       label: "tabs.profile.joinDiscord".t(context),
          //       icon: SimpleIcons.discord,
          //       plateInk: const Color(0xFF4F46E5), // indigo-600
          //       onTap: () => openUrl(discordInviteLink),
          //       style: rowStyle,
          //     ),
          //     _ProfileRow(
          //       label: "tabs.profile.support".t(context),
          //       icon: Symbols.favorite_rounded,
          //       plateInk: const Color(0xFFE11D48), // rose-600
          //       onTap: () => context.push("/support"),
          //       style: rowStyle,
          //     ),
          //     _ProfileRow(
          //       label: "contributors".t(context),
          //       icon: Symbols.groups_rounded,
          //       plateInk: const Color(0xFF0D9488), // teal-600
          //       onTap: () => context.push("/community/contributors"),
          //       style: rowStyle,
          //     ),
          //     _ProfileRow(
          //       label: "tabs.profile.recommend".t(context),
          //       icon: Symbols.share_rounded,
          //       plateInk: const Color(0xFF0891B2), // cyan-600
          //       onTap: () => context.showUriShareSheet(uri: website),
          //       style: rowStyle,
          //     ),
          //     _ProfileRow(
          //       label: "visitGitHubRepo".t(context),
          //       icon: SimpleIcons.github,
          //       plateInk: slateInk,
          //       onTap: () => openUrl(flowGitHubRepoLink),
          //       style: rowStyle,
          //     ),
          //   ],
          // ),

          _ProfileSection(
            id: "maintenanceData",
            title: "tabs.profile.section.maintenanceData".t(context),
            expanded: _expandedSections.contains("maintenanceData"),
            onToggle: () => _toggleSection("maintenanceData"),
            labelInk: sectionLabelInk,
            chevronInk: chevronInk,
            dividerColor: sectionDivider,
            children: [
              _ProfileRow(
                label: "transaction.deleted".t(context),
                icon: Symbols.delete_rounded,
                plateInk: const Color(0xFFDC2626), // red-600
                onTap: () => context.push("/transactions/deleted"),
                style: rowStyle,
              ),
              _ProfileRow(
                label: "tabs.profile.backup".t(context),
                icon: Symbols.hard_drive_rounded,
                plateInk: const Color(0xFF2563EB), // blue-600
                onTap: () => context.push("/exportOptions"),
                style: rowStyle,
              ),
              _ProfileRow(
                label: "tabs.profile.import".t(context),
                icon: Symbols.restore_page_rounded,
                plateInk: const Color(0xFF16A34A), // green-600
                onTap: () => context.push("/import"),
                style: rowStyle,
              ),
            ],
          ),

          _ProfileSection(
            id: "system",
            title: "tabs.profile.section.system".t(context),
            expanded: _expandedSections.contains("system"),
            onToggle: () => _toggleSection("system"),
            labelInk: sectionLabelInk,
            chevronInk: chevronInk,
            dividerColor: sectionDivider,
            children: [
              _ProfileRow(
                label: "tabs.profile.preferences".t(context),
                icon: Symbols.settings_rounded,
                plateInk: slateInk,
                onTap: () => context.push("/preferences"),
                style: rowStyle,
              ),
            ],
          ),

          if (flowDebugMode)
            _ProfileSection(
              id: "debugAdvanced",
              title: "tabs.profile.section.debugAdvanced".t(context),
              expanded: _expandedSections.contains("debugAdvanced"),
              onToggle: () => _toggleSection("debugAdvanced"),
              labelInk: sectionLabelInk,
              chevronInk: chevronInk,
              dividerColor: sectionDivider,
              children: _buildDebugRows(rowStyle, slateInk),
            ),

          const SizedBox(height: 48.0),
          // Center(
          //   child: Text("v$appVersion", style: context.textTheme.labelSmall),
          // ),
          // Center(
          //   child: InkWell(
          //     borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          //     onTap: () => openUrl(maintainerGitHubLink),
          //     child: Opacity(
          //       opacity: 0.5,
          //       child: Text(
          //         "tabs.profile.withLoveFromTheCreator".t(context),
          //         style: context.textTheme.labelSmall,
          //       ),
          //     ),
          //   ),
          // ),
          const SizedBox(height: 120.0),
        ],
      ),
    );
  }

  List<Widget> _buildDebugRows(_RowStyle rowStyle, Color slateInk) {
    final Widget dbLeading = _debugDbBusy
        ? const SizedBox(width: 20.0, height: 20.0, child: Spinner.center())
        : Icon(Symbols.adb_rounded, size: 20.0, color: slateInk);

    return <Widget>[
      _ProfileRow(
        label: "Theme test page",
        icon: Symbols.palette_rounded,
        plateInk: slateInk,
        onTap: () => context.push("/_debug/theme"),
        style: rowStyle,
      ),
      _ProfileRow(
        label: "View scheduled notifications",
        icon: Symbols.notifications_rounded,
        plateInk: slateInk,
        onTap: () => context.push("/_debug/scheduledNotifications"),
        style: rowStyle,
      ),
      _ProfileRow(
        label: "iCloud debug explorer",
        icon: Symbols.cloud_rounded,
        plateInk: slateInk,
        onTap: () => context.push("/_debug/iCloud"),
        style: rowStyle,
      ),
      _ProfileRow(
        label: "Schedule debug notification",
        icon: Symbols.notification_add_rounded,
        plateInk: slateInk,
        onTap: () {
          NotificationsService()
              .debugSchedule(Moment.now().startOfNextMinute())
              .then((_) {
            if (context.mounted) {
              context.showToast(
                text:
                    "Debug notification scheduled at the start of next minute",
              );
            }
          });
        },
        style: rowStyle,
      ),
      _ProfileRow(
        label: "Show debug notification",
        icon: Symbols.notifications_rounded,
        plateInk: slateInk,
        onTap: () => NotificationsService().debugShow(),
        onLongPress: () => Future.delayed(
          const Duration(seconds: 3),
          () => NotificationsService().debugShow(),
        ),
        style: rowStyle,
      ),
      _ProfileRow(
        label: "Clear exchange rates cache",
        icon: Symbols.adb_rounded,
        plateInk: slateInk,
        onTap: clearExchangeRatesCache,
        style: rowStyle,
      ),
      _ProfileRow(
        label: "Populate objectbox",
        icon: Symbols.adb_rounded,
        plateInk: slateInk,
        onTap: () => ObjectBox().createAndPutDebugData(),
        style: rowStyle,
      ),
      _ProfileRow(
        label: _debugDbBusy ? "Clearing database" : "Clear objectbox",
        icon: Symbols.adb_rounded,
        plateInk: slateInk,
        onTap: resetDatabase,
        leadingOverride: dbLeading,
        style: rowStyle,
      ),
      _ProfileRow(
        label: "Clear Shared Preferences",
        icon: Symbols.adb_rounded,
        plateInk: slateInk,
        onTap: resetPrefs,
        style: rowStyle,
      ),
      _ProfileRow(
        label: "Purge iCloud debug folder",
        icon: Symbols.adb_rounded,
        plateInk: slateInk,
        onTap: debugPurgeICloud,
        style: rowStyle,
      ),
      _ProfileRow(
        label: "Jump to setup page",
        icon: Symbols.settings_rounded,
        plateInk: slateInk,
        onTap: () => context.pushReplacement("/setup"),
        style: rowStyle,
      ),
    ];
  }

  void resetDatabase() async {
    if (_debugDbBusy) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("[dev] Reset database?"),
        actions: [
          Button(
            onTap: () => context.pop(true),
            child: const Text("Confirm delete"),
          ),
          Button(onTap: () => context.pop(false), child: const Text("Cancel")),
        ],
      ),
    );

    setState(() {
      _debugDbBusy = true;
    });

    TransactionsService().pauseListeners();

    try {
      if (confirm == true) {
        await ObjectBox().eraseMainData();
      }
    } finally {
      TransactionsService().resumeListeners();

      _debugDbBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void debugPurgeICloud() async {
    if (_debugICloudBusy) return;
    setState(() {
      _debugICloudBusy = true;
    });
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("[dev] Purge iCloud debug folder?"),
        actions: [
          Button(
            onTap: () => context.pop(true),
            child: const Text("Confirm delete"),
          ),
          Button(onTap: () => context.pop(false), child: const Text("Cancel")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final int deletedCount = await ICloudSyncer().debugPurge();

      if (mounted) {
        context.showToast(text: "Deleted $deletedCount debug items");
      }
    } finally {
      _debugICloudBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void resetPrefs() async {
    if (_debugPrefsBusy) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("[dev] Clear Shared Preferences?"),
        actions: [
          Button(
            onTap: () => context.pop(true),
            child: const Text("Confirm clear"),
          ),
          Button(onTap: () => context.pop(false), child: const Text("Cancel")),
        ],
      ),
    );

    setState(() {
      _debugPrefsBusy = true;
    });

    try {
      if (confirm == true) {
        final instanceAvecCache = await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );
        await instanceAvecCache.clear();
      }
    } finally {
      _debugPrefsBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void clearExchangeRatesCache() {
    ExchangeRatesService().debugClearCache();
  }
}

/// Shared styling for every row in a section. Bundled into one object so each
/// row site stays terse.
class _RowStyle {
  final Color fill;
  final Color ink;
  final Color chevronInk;
  final bool light;

  const _RowStyle({
    required this.fill,
    required this.ink,
    required this.chevronInk,
    required this.light,
  });
}

/// Collapsible section: small-caps header with a rotating chevron on the
/// right, animated content area below, and a faint divider underneath.
class _ProfileSection extends StatelessWidget {
  final String id;
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;
  final Color labelInk;
  final Color chevronInk;
  final Color dividerColor;

  const _ProfileSection({
    required this.id,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.children,
    required this.labelInk,
    required this.chevronInk,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: labelInk,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Icon(
                      Symbols.expand_more_rounded,
                      color: chevronInk,
                      size: 22.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      16.0,
                      0.0,
                      16.0,
                      12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < children.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8.0),
                          children[i],
                        ],
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0.0),
          ),
        ),
        Divider(height: 1.0, thickness: 1.0, color: dividerColor),
      ],
    );
  }
}

/// Single profile row inside a section. Colored 40x40 icon plate on the left,
/// label in the middle, chevron-right at the end.
class _ProfileRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color plateInk;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final _RowStyle style;

  /// Optional override that replaces the colored icon (e.g. a [Spinner] while
  /// a debug action is running).
  final Widget? leadingOverride;

  const _ProfileRow({
    required this.label,
    required this.icon,
    required this.plateInk,
    required this.onTap,
    required this.style,
    this.onLongPress,
    this.leadingOverride,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius radius = BorderRadius.circular(14.0);

    // Light mode: pastel halo around the icon. Dark mode: a slightly stronger
    // tint of the same ink so the colored identity reads against the dark
    // row surface.
    final Color plateFill = plateInk.withValues(alpha: style.light ? 0.12 : 0.20);

    return Material(
      color: style.fill,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 12.0, 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: plateFill,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: leadingOverride ??
                    Icon(icon, size: 20.0, color: plateInk),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: style.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                Symbols.chevron_right_rounded,
                size: 20.0,
                color: style.chevronInk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
