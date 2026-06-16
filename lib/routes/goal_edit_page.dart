import "package:flow/entity/account.dart";
import "package:flow/entity/goal.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/providers/accounts_provider.dart";
import "package:flow/services/goal.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class GoalEditPage extends StatefulWidget {
  final int goalId;

  bool get isNew => goalId == 0;

  const GoalEditPage.create({super.key}) : goalId = 0;
  const GoalEditPage({super.key, required this.goalId});

  @override
  State<GoalEditPage> createState() => _GoalEditPageState();
}

class _GoalEditPageState extends State<GoalEditPage> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _baselineController = TextEditingController();
  String? _accountUuid;
  TimeRange? _deadline = TimeRange.thisYear();
  Goal? _existing;

  @override
  void initState() {
    super.initState();
    if (!widget.isNew) {
      _existing = ObjectBox().box<Goal>().get(widget.goalId);
      if (_existing != null) {
        _nameController.text = _existing!.name;
        _targetController.text = _existing!.targetBalance.toString();
        _baselineController.text =
            _existing!.baseLineBalance?.toString() ?? "";
        _accountUuid = _existing!.accountUuid;
        _deadline = _existing!.timeRange;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _baselineController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final double? target = double.tryParse(_targetController.text);
    if (target == null || _nameController.text.trim().isEmpty) return;
    if (_accountUuid == null) return;

    final Account? account = AccountsProvider.of(context).get(_accountUuid);

    final Goal goal = _existing ??
        Goal(
          name: _nameController.text.trim(),
          targetBalance: target,
          currency: account?.currency ??
              UserPreferencesService().primaryCurrency,
          range: _deadline?.toString(),
        );

    goal
      ..name = _nameController.text.trim()
      ..targetBalance = target
      ..range = _deadline?.toString()
      ..baseLineBalance = double.tryParse(_baselineController.text)
      ..accountUuid = _accountUuid;

    await GoalService().upsert(goal, account: account);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final List<Account> accounts =
        AccountsProvider.of(context).activeAccounts;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isNew ? "goals.new".t(context) : "goals.edit".t(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text("general.save".t(context)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8.0),
              Center(
                child: Container(
                  width: 64.0,
                  height: 64.0,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Symbols.flag_rounded,
                    size: 32.0,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                "goals.edit.tagline".t(context),
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24.0),
              Surface(
                color: Theme.of(context).cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "goals.label.name".t(context),
                        style: text.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "goals.nameHint".t(context),
                          prefixIcon: Icon(
                            Symbols.emoji_events_rounded,
                            size: 20.0,
                            color: colors.onSurfaceVariant,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: colors.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: colors.outlineVariant,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        "goals.label.target".t(context),
                        style: text.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _targetController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: "0.00",
                          prefixIcon: Icon(
                            Symbols.savings_rounded,
                            size: 20.0,
                            color: colors.onSurfaceVariant,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: colors.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: colors.outlineVariant,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        "goals.baselineLabel".t(context),
                        style: text.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _baselineController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: "0.00",
                          prefixIcon: Icon(
                            Symbols.account_balance_rounded,
                            size: 20.0,
                            color: colors.onSurfaceVariant,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: colors.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: colors.outlineVariant,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              const WavyDivider(),
              const SizedBox(height: 20.0),
              Text(
                "goals.fundingSource".t(context),
                style: text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10.0),
              Surface(
                color: Theme.of(context).cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                builder: (context) => Column(
                  children: [
                    for (int i = 0; i < accounts.length; i++) ...[
                      _buildAccountTile(accounts[i], colors, text),
                      if (i < accounts.length - 1) const Divider(height: 1.0),
                    ],
                    if (accounts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "goals.noAccounts".t(context),
                          style: text.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                "goals.timeline".t(context),
                style: text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10.0),
              _buildDeadlineSelector(context, colors, text),
              const SizedBox(height: 12.0),
              _buildDatePickerRow(context, colors, text),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTile(
    Account account,
    ColorScheme colors,
    TextTheme text,
  ) {
    final bool selected = _accountUuid == account.uuid;
    final String balanceStr =
        "${account.balance.currency} ${account.balance.amount.toStringAsFixed(2)}";

    return InkWell(
      onTap: () => setState(() => _accountUuid = account.uuid),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            FlowIcon(account.icon, size: 36.0, plated: true),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: text.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    "goals.accountAvailable".t(context, {"amount": balanceStr}),
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22.0,
              height: 22.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? colors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? colors.primary : colors.outlineVariant,
                  width: 2.0,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  bool get _isSpecificDate {
    if (_deadline == null) return false;
    return _deadline.toString() != TimeRange.thisYear().toString();
  }

  Widget _buildDeadlineSelector(
    BuildContext context,
    ColorScheme colors,
    TextTheme text,
  ) {
    final bool isThisYear =
        _deadline != null && _deadline.toString() == TimeRange.thisYear().toString();
    final bool isNoDeadline = _deadline == null;

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: GestureDetector(
              onTap: () => setState(() => _deadline = TimeRange.thisYear()),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: isThisYear ? const Color(0xFF005DAA) : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: isThisYear
                        ? const Color(0xFF005DAA)
                        : colors.outlineVariant,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.calendar_today_rounded,
                      size: 16.0,
                      color: isThisYear ? Colors.white : colors.onSurface,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      "goals.deadline.thisYear".t(context),
                      style: text.bodyMedium?.copyWith(
                        color: isThisYear ? Colors.white : colors.onSurface,
                        fontWeight:
                            isThisYear ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: GestureDetector(
              onTap: () => setState(() => _deadline = null),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color:
                      isNoDeadline ? const Color(0xFF005DAA) : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: isNoDeadline
                        ? const Color(0xFF005DAA)
                        : colors.outlineVariant,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.all_inclusive_rounded,
                      size: 16.0,
                      color: isNoDeadline ? Colors.white : colors.onSurface,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      "goals.deadline.none".t(context),
                      style: text.bodyMedium?.copyWith(
                        color: isNoDeadline ? Colors.white : colors.onSurface,
                        fontWeight:
                            isNoDeadline ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerRow(
    BuildContext context,
    ColorScheme colors,
    TextTheme text,
  ) {
    final bool hasSpecificDate = _isSpecificDate;
    final String displayText = hasSpecificDate
        ? DateFormat('MMM dd, yyyy').format(_deadline!.to)
        : "goals.deadline.pickDate".t(context);

    return GestureDetector(
      onTap: () async {
        final DateTime now = DateTime.now();
        final DateTime initialDate = hasSpecificDate
            ? _deadline!.to
            : now.add(const Duration(days: 365));
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: now,
          lastDate: now.add(const Duration(days: 3650)),
        );
        if (picked != null) {
          setState(() {
            _deadline = CustomTimeRange(now, picked);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: hasSpecificDate
              ? const Color(0xFF005DAA).withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: hasSpecificDate
                ? const Color(0xFF005DAA)
                : colors.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Symbols.edit_calendar_rounded,
              size: 18.0,
              color: hasSpecificDate
                  ? const Color(0xFF005DAA)
                  : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                displayText,
                style: text.bodyMedium?.copyWith(
                  color: hasSpecificDate
                      ? const Color(0xFF005DAA)
                      : colors.onSurfaceVariant,
                  fontWeight:
                      hasSpecificDate ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Symbols.chevron_right_rounded,
              size: 20.0,
              color: hasSpecificDate
                  ? const Color(0xFF005DAA)
                  : colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
