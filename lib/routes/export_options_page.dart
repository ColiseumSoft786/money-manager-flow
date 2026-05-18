import "package:flow/entity/account.dart";
import "package:flow/entity/category.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/routes/export/export_options_theme.dart";
import "package:flow/routes/export/widgets/export_accounts_card.dart";
import "package:flow/routes/export/widgets/export_format_selector.dart";
import "package:flow/routes/export/widgets/export_hero_header.dart";
import "package:flow/routes/export/widgets/export_quick_links.dart";
import "package:flow/routes/export/widgets/export_range_card.dart";
import "package:flow/routes/export/widgets/export_section_header.dart";
import "package:flow/services/accounts.dart";
import "package:flow/sync/export/export_pdf.dart";
import "package:flow/sync/export/mode.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/foundation.dart" hide Category;
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class ExportOptionsPage extends StatefulWidget {
  const ExportOptionsPage({super.key});

  @override
  State<ExportOptionsPage> createState() => _ExportOptionsPageState();
}

class _ExportOptionsPageState extends State<ExportOptionsPage> {
  ExportMode _mode = ExportMode.csv;
  ExportRangeTab _rangeTab = ExportRangeTab.thisMonth;

  DateTime _displayMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  TimeRange _timeRange = TimeRange.thisMonth();

  final List<Account> _accounts = [];
  final Set<String> _selectedAccounts = {};
  final List<Category> _categories = [];
  final Set<String> _selectedCategories = {};

  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _applyRangeTab(_rangeTab);
    _categories.addAll(ObjectBox().getCategories());
    _selectedCategories.addAll(_categories.map((category) => category.uuid));

    AccountsService()
        .getAll()
        .then((accounts) {
          _accounts.addAll(accounts);
          _selectedAccounts.addAll(accounts.map((account) => account.uuid));
        })
        .catchError((_) {})
        .whenComplete(() {
          _ready = true;
          if (mounted) setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    const Color screenBackground = ExportOptionsTheme.canvas;

    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: ExportOptionsTheme.cardFill,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "sync.export.data".t(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: ExportOptionsTheme.titleInk,
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
        child: !_ready
            ? const Spinner.center()
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const ExportHeroHeader(),
                          const SizedBox(height: 8.0),
                          ExportSectionHeader(
                            label: "sync.export.selectRange".t(context),
                          ),
                          ExportRangeCard(
                            tab: _rangeTab,
                            onTabChanged: _onRangeTabChanged,
                            displayMonth: _displayMonth,
                            onPreviousMonth: _previousMonth,
                            onNextMonth: _nextMonth,
                            rangeStart: _rangeStart,
                            rangeEnd: _rangeEnd,
                            onDayTap: _onDayTap,
                          ),
                          ExportSectionHeader(
                            label: "sync.export.selectFormat".t(context),
                          ),
                          ExportFormatSelector(
                            selected: _mode,
                            onSelected: (ExportMode mode) {
                              setState(() => _mode = mode);
                            },
                          ),
                          if (_mode == ExportMode.pdf &&
                              _accounts.isNotEmpty) ...[
                            ExportSectionHeader(
                              label: "sync.export.selectAccounts".t(context),
                            ),
                            ExportAccountsCard(
                              accounts: _accounts,
                              selectedUuids: _selectedAccounts,
                              onToggleAccount: _toggleAccount,
                              onSelectAll: _toggleSelectAllAccounts,
                            ),
                          ],
                          const SizedBox(height: 4.0),
                          const ExportQuickLinks(),
                          const SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ),
                  _BottomExportBar(
                    mode: _mode,
                    rangeLabel: _formatRangeLabel(context),
                    enabled:
                        _mode != ExportMode.pdf ||
                        _selectedAccounts.isNotEmpty,
                    onExport: _startExport,
                  ),
                ],
              ),
      ),
    );
  }

  void _onRangeTabChanged(ExportRangeTab tab) {
    setState(() {
      _rangeTab = tab;
      _applyRangeTab(tab);
    });
  }

  void _applyRangeTab(ExportRangeTab tab) {
    final DateTime now = DateTime.now();
    switch (tab) {
      case ExportRangeTab.thisMonth:
        _timeRange = TimeRange.thisMonth();
        _displayMonth = DateTime(now.year, now.month, 1);
        _rangeStart = _timeRange.from;
        _rangeEnd = _timeRange.to;
      case ExportRangeTab.lastMonth:
        final DateTime first = DateTime(now.year, now.month - 1, 1);
        final DateTime last = DateTime(now.year, now.month, 0);
        _displayMonth = first;
        _rangeStart = DateTime(first.year, first.month, first.day);
        _rangeEnd = DateTime(last.year, last.month, last.day);
        _timeRange = CustomTimeRange(
          _rangeStart!.startOfDay(),
          _rangeEnd!.endOfDay(),
        );
      case ExportRangeTab.custom:
        if (_rangeStart == null) {
          _rangeStart = DateTime(now.year, now.month, now.day);
          _rangeEnd = _rangeStart;
        }
        _timeRange = CustomTimeRange(
          _rangeStart!.startOfDay(),
          (_rangeEnd ?? _rangeStart)!.endOfDay(),
        );
    }
  }

  void _onDayTap(DateTime date) {
    setState(() {
      _rangeTab = ExportRangeTab.custom;
      if (_rangeStart == null) {
        _rangeStart = date;
        _rangeEnd = null;
      } else if (_rangeEnd == null) {
        if (date.isBefore(_rangeStart!)) {
          _rangeStart = date;
        } else {
          _rangeEnd = date;
        }
      } else {
        _rangeStart = date;
        _rangeEnd = null;
      }
      _displayMonth = DateTime(date.year, date.month, 1);
      if (_rangeStart != null) {
        _timeRange = CustomTimeRange(
          _rangeStart!.startOfDay(),
          (_rangeEnd ?? _rangeStart)!.endOfDay(),
        );
      }
    });
  }

  void _previousMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    });
  }

  void _toggleAccount(Account account) {
    setState(() {
      if (_selectedAccounts.contains(account.uuid)) {
        _selectedAccounts.remove(account.uuid);
      } else {
        _selectedAccounts.add(account.uuid);
      }
    });
  }

  void _toggleSelectAllAccounts() {
    setState(() {
      if (_selectedAccounts.length == _accounts.length) {
        _selectedAccounts.clear();
      } else {
        _selectedAccounts
          ..clear()
          ..addAll(_accounts.map((account) => account.uuid));
      }
    });
  }

  String _formatRangeLabel(BuildContext context) {
    final DateTime? start = _rangeStart;
    if (start == null) {
      return "sync.export.range.notSelected".t(context);
    }
    final DateTime end = _rangeEnd ?? start;
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return start.toMoment().format("MMM D, YYYY");
    }
    return "${start.toMoment().format("MMM D")} – ${end.toMoment().format("MMM D, YYYY")}";
  }

  void _startExport() {
    switch (_mode) {
      case ExportMode.csv:
        context.push("/export/csv");
      case ExportMode.zip:
        context.push("/export/zip");
      case ExportMode.json:
        context.push("/export/json");
      case ExportMode.pdf:
        if (_selectedAccounts.isEmpty) return;
        context.push(
          "/export/pdf",
          extra: ExportPdfOptions(
            timeRange: _timeRange,
            whitelistedAccounts: _accounts
                .where((account) => _selectedAccounts.contains(account.uuid))
                .toList(),
            whitelistedCategories: _categories
                .where((category) => _selectedCategories.contains(category.uuid))
                .toList(),
          ),
        );
    }
  }
}

class _BottomExportBar extends StatelessWidget {
  final ExportMode mode;
  final String rangeLabel;
  final bool enabled;
  final VoidCallback onExport;

  const _BottomExportBar({
    required this.mode,
    required this.rangeLabel,
    required this.enabled,
    required this.onExport,
  });

  String _buttonLabel(BuildContext context) {
    final String format = switch (mode) {
      ExportMode.csv => "CSV",
      ExportMode.zip => "sync.export.format.zipShort".t(context),
      ExportMode.pdf => "PDF",
      ExportMode.json => "JSON",
    };
    return "sync.export.exportTo".t(context, format);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ExportOptionsTheme.cardBorder)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mode == ExportMode.pdf) ...[
              Row(
                children: [
                  Icon(
                    Symbols.calendar_today_rounded,
                    size: 16.0,
                    color: ExportOptionsTheme.mutedInk,
                    fill: 0.0,
                  ),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                      rangeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ExportOptionsTheme.mutedInk,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
            ],
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: enabled
                    ? ExportOptionsTheme.primary(context)
                    : const Color(0xFFCBD5E1),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54.0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: enabled ? onExport : null,
                    borderRadius: BorderRadius.circular(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Symbols.ios_share_rounded,
                          size: 22.0,
                          color: Colors.white,
                          fill: 0.0,
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          _buttonLabel(context),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16.0,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              "sync.export.disclaimer".t(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ExportOptionsTheme.mutedInk,
                fontSize: 11.0,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
