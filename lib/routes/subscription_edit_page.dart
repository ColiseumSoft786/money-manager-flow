import "package:flow/entity/recurring_transaction.dart";
import "package:flow/entity/subscription.dart";
import "package:flow/entity/subscription_kind.dart";
import "package:flow/entity/subscription_status.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/services/recurring_transactions.dart";
import "package:flow/services/subscription.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/surface.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flow/widgets/sheets/select_currency_sheet.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.dart";
class SubscriptionEditPage extends StatefulWidget {
  final int subscriptionId;

  bool get isNew => subscriptionId == 0;

  const SubscriptionEditPage.create({super.key}) : subscriptionId = 0;
  const SubscriptionEditPage({super.key, required this.subscriptionId});

  @override
  State<SubscriptionEditPage> createState() => _SubscriptionEditPageState();
}

class _SubscriptionEditPageState extends State<SubscriptionEditPage> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _cancelUrlController = TextEditingController();
  final _unusedDaysController = TextEditingController(text: "60");
  final _notesController = TextEditingController();

  bool _linkRecurring = true;
  String? _recurringUuid;
  String _currency = UserPreferencesService().primaryCurrency;
  SubscriptionKind _kind = SubscriptionKind.cancellable;
  SubscriptionStatus _status = SubscriptionStatus.active;
  DateTime? _cancelByDate;
  DateTime? _lastUsedOverride;
  Subscription? _existing;
  List<RecurringTransaction> _expenseRecurrings = [];

  @override
  void initState() {
    super.initState();
    _loadRecurrings();
    if (!widget.isNew) {
      _existing = ObjectBox().box<Subscription>().get(widget.subscriptionId);
      if (_existing != null) {
        final Subscription sub = _existing!;
        _nameController.text = sub.name;
        _cancelUrlController.text = sub.cancelUrl ?? "";
        _unusedDaysController.text = sub.unusedAfterDays.toString();
        _notesController.text = sub.notes ?? "";
        _kind = sub.kind;
        _status = sub.status;
        _cancelByDate = sub.cancelByDate;
        _lastUsedOverride = sub.lastUsedOverride;
        if (sub.recurringTransactionUuid != null) {
          _linkRecurring = true;
          _recurringUuid = sub.recurringTransactionUuid;
        } else {
          _linkRecurring = false;
          if (sub.manualAmount != null) {
            _amountController.text = sub.manualAmount.toString();
          }
          _currency = sub.manualCurrency ??
              UserPreferencesService().primaryCurrency;
        }
      }
    } else {
      _linkRecurring = false;
    }
  }

  void _loadRecurrings() {
    _expenseRecurrings = RecurringTransactionsService()
        .getAllSync()
        .where((r) => !r.disabled && r.template.amount < 0)
        .toList()
      ..sort(
        (a, b) => (a.template.title ?? "")
            .compareTo(b.template.title ?? ""),
      );
    if (_recurringUuid != null &&
        !_expenseRecurrings.any((r) => r.uuid == _recurringUuid)) {
      RecurringTransactionsService()
          .getAllSync()
          .where((r) => r.uuid == _recurringUuid)
          .forEach(_expenseRecurrings.add);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _cancelUrlController.dispose();
    _unusedDaysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickCurrency() async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (context) =>
          SelectCurrencySheet(currentlySelected: _currency),
    );
    if (selected != null) {
      setState(() => _currency = selected);
    }
  }

  Future<void> _pickDate({
    required DateTime? current,
    required void Function(DateTime?) onPicked,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (!mounted || picked == null) return;
    setState(() => onPicked(picked));
  }

  void _save() {
    final String name = _nameController.text.trim();
    if (name.isEmpty) return;

    final int unusedDays =
        int.tryParse(_unusedDaysController.text.trim()) ?? 60;

    final Subscription sub = _existing ?? Subscription(name: name);

    sub
      ..name = name
      ..kind = _kind
      ..status = _status
      ..cancelUrl = _cancelUrlController.text.trim().isEmpty
          ? null
          : _cancelUrlController.text.trim()
      ..cancelByDate = _kind == SubscriptionKind.annualContract
          ? _cancelByDate
          : null
      ..lastUsedOverride = widget.isNew ? null : _lastUsedOverride
      ..unusedAfterDays = unusedDays
      ..notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

    if (_linkRecurring) {
      if (_recurringUuid == null) return;
      sub
        ..recurringTransactionUuid = _recurringUuid
        ..manualAmount = null
        ..manualCurrency = null;
    } else {
      final double? amount = double.tryParse(_amountController.text.trim());
      if (amount == null) return;
      sub
        ..recurringTransactionUuid = null
        ..manualAmount = amount
        ..manualCurrency = _currency;
    }

    SubscriptionService().upsertSync(sub);
    if (mounted) context.pop();
  }

  String _recurringLabel(RecurringTransaction r) {
    final String title = r.template.title ?? r.uuid;
    final String amount = r.template.amount.abs().toStringAsFixed(2);
    return "$title ($amount ${r.template.currency})";
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isNew
              ? "subscriptions.new".t(context)
              : "subscriptions.edit".t(context),
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
              _sectionField(
                context,
                label: "subscriptions.name".t(context),
                child: TextField(
                  controller: _nameController,
                  decoration: _inputDecoration(context),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                "subscriptions.billingSource".t(context).toUpperCase(),
                style: text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8.0),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text("subscriptions.linkRecurring".t(context)),
                    icon: const Icon(Symbols.sync_rounded, size: 18.0),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text("subscriptions.manualAmount".t(context)),
                    icon: const Icon(Symbols.edit_rounded, size: 18.0),
                  ),
                ],
                selected: {_linkRecurring},
                onSelectionChanged: (selected) {
                  setState(() => _linkRecurring = selected.first);
                },
              ),
              const SizedBox(height: 12.0),
              if (_linkRecurring)
                Surface(
                  color: Theme.of(context).cardColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                  builder: (context) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonFormField<String>(
                      value: _recurringUuid,
                      decoration: InputDecoration(
                        labelText:
                            "subscriptions.recurringExpense".t(context),
                        border: InputBorder.none,
                      ),
                      items: [
                        for (final RecurringTransaction r
                            in _expenseRecurrings)
                          DropdownMenuItem(
                            value: r.uuid,
                            child: Text(
                              _recurringLabel(r),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _recurringUuid = value;
                          if (value != null && _nameController.text.isEmpty) {
                            final RecurringTransaction? r =
                                _expenseRecurrings
                                    .where((e) => e.uuid == value)
                                    .firstOrNull;
                            if (r?.template.title != null) {
                              _nameController.text = r!.template.title!;
                            }
                          }
                        });
                      },
                    ),
                  ),
                )
              else
                Surface(
                  color: Theme.of(context).cardColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _amountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _inputDecoration(
                              context,
                              hint: "0.00",
                              label: "subscriptions.amount".t(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _pickCurrency,
                            child: Text(_currency),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20.0),
              const WavyDivider(),
              const SizedBox(height: 20.0),
              _sectionField(
                context,
                label: "subscriptions.kind".t(context),
                child: DropdownButtonFormField<SubscriptionKind>(
                  value: _kind,
                  decoration: _inputDecoration(context),
                  items: [
                    for (final SubscriptionKind k in SubscriptionKind.values)
                      DropdownMenuItem(
                        value: k,
                        child: Text(_kindLabel(context, k)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _kind = value;
                      if (value != SubscriptionKind.annualContract) {
                        _cancelByDate = null;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 6.0),
              _helperText(context, _kindHint(context, _kind)),
              const SizedBox(height: 16.0),
              _sectionField(
                context,
                label: "subscriptions.status".t(context),
                child: DropdownButtonFormField<SubscriptionStatus>(
                  value: _status,
                  decoration: _inputDecoration(context),
                  items: [
                    for (final SubscriptionStatus s
                        in SubscriptionStatus.values)
                      DropdownMenuItem(
                        value: s,
                        child: Text(_statusLabel(context, s)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              _sectionField(
                context,
                label: "subscriptions.cancelUrl".t(context),
                child: TextField(
                  controller: _cancelUrlController,
                  keyboardType: TextInputType.url,
                  decoration: _inputDecoration(
                    context,
                    hint: "https://…",
                  ),
                ),
              ),
              if (_kind == SubscriptionKind.annualContract) ...[
                const SizedBox(height: 16.0),
                _dateRow(
                  context,
                  label: "subscriptions.cancelBy".t(context),
                  date: _cancelByDate,
                  hint: "subscriptions.cancelBy.hint".t(context),
                  onTap: () => _pickDate(
                    current: _cancelByDate,
                    onPicked: (d) => _cancelByDate = d,
                  ),
                  onClear: _cancelByDate == null
                      ? null
                      : () => setState(() => _cancelByDate = null),
                ),
              ],
              if (!widget.isNew) ...[
                const SizedBox(height: 16.0),
                _dateRow(
                  context,
                  label: "subscriptions.lastUsedOverride".t(context),
                  date: _lastUsedOverride,
                  hint: "subscriptions.lastUsedOverride.hint".t(context),
                  placeholder: "subscriptions.lastUsedOptional".t(context),
                  onTap: () => _pickDate(
                    current: _lastUsedOverride,
                    onPicked: (d) => _lastUsedOverride = d,
                  ),
                  onClear: _lastUsedOverride == null
                      ? null
                      : () => setState(() => _lastUsedOverride = null),
                ),
              ],
              const SizedBox(height: 16.0),
              _sectionField(
                context,
                label: "subscriptions.unusedThreshold".t(context),
                child: TextField(
                  controller: _unusedDaysController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    context,
                    hint: "60",
                    suffix: "subscriptions.days".t(context),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              _sectionField(
                context,
                label: "subscriptions.notes".t(context),
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: _inputDecoration(context),
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionField(
    BuildContext context, {
    required String label,
    required Widget child,
  }) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: text.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8.0),
        child,
      ],
    );
  }

  Widget _helperText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.35,
      ),
    );
  }

  String _kindHint(BuildContext context, SubscriptionKind kind) =>
      switch (kind) {
        SubscriptionKind.cancellable =>
          "subscriptions.kind.hint.cancellable".t(context),
        SubscriptionKind.essential =>
          "subscriptions.kind.hint.essential".t(context),
        SubscriptionKind.annualContract =>
          "subscriptions.kind.hint.annualContract".t(context),
      };

  Widget _dateRow(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    VoidCallback? onClear,
    String? placeholder,
    String? hint,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final String display = date == null
        ? (placeholder ?? "subscriptions.pickDate".t(context))
        : DateFormat("MMM dd, yyyy").format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: text.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onTap,
                icon: const Icon(Symbols.edit_calendar_rounded, size: 18.0),
                label: Text(display),
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: 8.0),
              IconButton(
                onPressed: onClear,
                icon: const Icon(Symbols.close_rounded),
                tooltip: "general.cancel".t(context),
              ),
            ],
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 6.0),
          _helperText(context, hint),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    String? hint,
    String? label,
    String? suffix,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      labelText: label,
      suffixText: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 14.0,
      ),
    );
  }

  String _kindLabel(BuildContext context, SubscriptionKind kind) =>
      switch (kind) {
        SubscriptionKind.cancellable =>
          "subscriptions.kind.cancellable".t(context),
        SubscriptionKind.essential => "subscriptions.kind.essential".t(context),
        SubscriptionKind.annualContract =>
          "subscriptions.kind.annualContract".t(context),
      };

  String _statusLabel(BuildContext context, SubscriptionStatus status) =>
      switch (status) {
        SubscriptionStatus.active =>
          "subscriptions.status.active".t(context),
        SubscriptionStatus.cancelled =>
          "subscriptions.status.cancelled".t(context),
        SubscriptionStatus.paused =>
          "subscriptions.status.paused".t(context),
      };
}
