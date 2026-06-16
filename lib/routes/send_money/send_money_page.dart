import "package:flow/data/firebase_friend.dart";
import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/accounts.dart";
import "package:flow/services/firebase_send_money_service.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.dart";

/// Enter amount — matches CashPilot send-amount mock.
class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key, required this.recipient});

  final FirebaseUserProfile recipient;

  static const Color _balanceGreen = Color(0xFF16A34A);

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final TextEditingController _noteController = TextEditingController();

  String _amountString = "";
  String? _accountUuid;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _accountUuid = UserPreferencesService().primaryAccountUuid;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double? get _parsedAmount {
    if (_amountString.isEmpty) return null;
    return double.tryParse(_amountString);
  }

  String get _displayAmount {
    if (_amountString.isEmpty) return "0.00";
    if (_amountString.contains(".")) {
      final List<String> parts = _amountString.split(".");
      final String decimals = parts.length > 1 ? parts[1] : "";
      final String whole = parts.first.isEmpty ? "0" : parts.first;
      if (decimals.length < 2) {
        return "$whole.${decimals.padRight(2, "0")}";
      }
      return _amountString;
    }
    final double? value = double.tryParse(_amountString);
    if (value == null) return "0.00";
    return NumberFormat("#,##0.00").format(value);
  }

  bool get _amountIsEmpty => _amountString.isEmpty;

  void _appendDigit(String digit) {
    if (_sending) return;
    setState(() {
      if (digit == ".") {
        if (_amountString.contains(".")) return;
        _amountString = _amountString.isEmpty ? "0." : "$_amountString.";
        return;
      }
      if (_amountString.contains(".")) {
        final int decimals = _amountString.split(".").last.length;
        if (decimals >= 2) return;
      }
      if (_amountString == "0") {
        _amountString = digit;
      } else {
        _amountString += digit;
      }
    });
  }

  void _backspace() {
    if (_sending || _amountString.isEmpty) return;
    setState(() {
      _amountString = _amountString.substring(0, _amountString.length - 1);
    });
  }

  Future<void> _submit() async {
    final double? amount = _parsedAmount;
    final String? accountUuid = _accountUuid;
    if (amount == null || amount <= 0) {
      _snack("sendMoney.error.invalidAmount".t(context));
      return;
    }
    if (accountUuid == null) {
      _snack("sendMoney.error.noAccount".t(context));
      return;
    }
    final Account? fromAccount = AccountsService().findOneActiveSync(
      accountUuid,
    );
    if (fromAccount != null &&
        !FirebaseSendMoneyService.canSendFromAccount(fromAccount, amount)) {
      _snack("sendMoney.error.insufficientFunds".t(context));
      return;
    }

    setState(() => _sending = true);
    try {
      final String recipientLabel = widget.recipient.displayName.isNotEmpty
          ? widget.recipient.displayName
          : widget.recipient.handleLabel;
      final String transactionTitle = "sendMoney.transactionTitle".t(context, {
        "name": recipientLabel,
      });
      await FirebaseSendMoneyService().sendMoney(
        recipient: widget.recipient,
        amount: amount,
        fromAccountUuid: accountUuid,
        transactionTitle: transactionTitle,
        note: _noteController.text,
      );
      if (!mounted) return;
      _snack("sendMoney.success".t(context));
      context.pop();
    } on SendMoneyException catch (e) {
      _snack(FirebaseSendMoneyService().messageFor(e));
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _pickAccount(List<Account> accounts) {
    if (_sending || accounts.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                child: Text(
                  "sendMoney.fromAccount".t(context).toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              for (final Account account in accounts)
                ListTile(
                  leading: Icon(
                    Symbols.account_balance_wallet_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(account.name),
                  subtitle: Text(
                    "sendMoney.available".t(context, {
                      "amount": account.balance.formatMoney(),
                    }),
                    style: const TextStyle(color: SendMoneyPage._balanceGreen),
                  ),
                  trailing: _accountUuid == account.uuid
                      ? Icon(
                          Symbols.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() => _accountUuid = account.uuid);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String _recipientInitials(FirebaseUserProfile recipient) {
    if (recipient.displayName.isNotEmpty) {
      final parts = recipient.displayName.trim().split(RegExp(r"\s+"));
      if (parts.length >= 2) {
        return "${parts.first[0]}${parts[1][0]}".toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    final h = recipient.handle.replaceAll("@", "");
    return h.length >= 2
        ? h.substring(0, 2).toUpperCase()
        : (h.isNotEmpty ? h[0].toUpperCase() : "?");
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseUserProfile recipient = widget.recipient;
    final String name = recipient.displayName.isNotEmpty
        ? recipient.displayName
        : recipient.handleLabel;
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color pageBg = dark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFF8FAFC);
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color cardBorder = dark
        ? Theme.of(context).colorScheme.outlineVariant
        : const Color(0xFFE2E8F0);
    final Color labelInk = Theme.of(context).colorScheme.onSurfaceVariant;
    final Color headingInk = Theme.of(context).colorScheme.onSurface;
    final Color keypadBg = dark
        ? Theme.of(context).colorScheme.surfaceContainerLow
        : Colors.white;
    final Color accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Text("sendMoney.title".t(context)),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Account>>(
          stream: ObjectBox()
              .box<Account>()
              .query(Account_.archived.equals(false))
              .watch(triggerImmediately: true)
              .map((q) => q.find()),
          builder: (context, accountsSnap) {
            final List<Account> accounts = accountsSnap.data ?? [];
            if (_accountUuid == null && accounts.isNotEmpty) {
              _accountUuid = accounts.first.uuid;
            }
            Account? activeAccount;
            for (final Account a in accounts) {
              if (a.uuid == _accountUuid) {
                activeAccount = a;
                break;
              }
            }
            activeAccount ??= accounts.isNotEmpty ? accounts.first : null;
            if (activeAccount == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text("sendMoney.error.noAccount".t(context)),
                ),
              );
            }
            final Account account = activeAccount;
            final String currencySymbol = NumberFormat.simpleCurrency(
              name: account.currency,
            ).currencySymbol;

            return StreamBuilder(
              stream: FirebaseSendMoneyService().watchOutgoing(),
              builder: (context, outgoingSnap) {
                final bool isRecent = (outgoingSnap.data ?? []).any(
                  (t) => t.toUserId == recipient.userId,
                );
                final String subtitle = isRecent
                    ? "${recipient.handleLabel} • ${"sendMoney.recentContact".t(context)}"
                    : recipient.handleLabel;
                final double? amount = _parsedAmount;
                final bool canSubmit =
                    amount != null &&
                    amount > 0 &&
                    FirebaseSendMoneyService.canSendFromAccount(account, amount);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                        children: [
                          _RecipientCard(
                            name: name,
                            subtitle: subtitle,
                            initials: _recipientInitials(recipient),
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                            headingInk: headingInk,
                            subtitleInk: labelInk,
                          ),
                          const SizedBox(height: 20.0),
                          _SectionLabel(
                            text: "sendMoney.amountToSend".t(context),
                            color: labelInk,
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                currencySymbol,
                                style: TextStyle(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Expanded(
                                child: Text(
                                  _displayAmount,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.w700,
                                    color: _amountIsEmpty
                                        ? labelInk.withValues(alpha: 0.55)
                                        : headingInk,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          _SectionLabel(
                            text: "sendMoney.fromAccount".t(context),
                            color: labelInk,
                          ),
                          const SizedBox(height: 8.0),
                          _FromAccountCard(
                            account: account,
                            cardBg: cardBg,
                            cardBorder: cardBorder,
                            headingInk: headingInk,
                            onTap: () => _pickAccount(accounts),
                          ),
                          const SizedBox(height: 20.0),
                          _SectionLabel(
                            text: "sendMoney.addNote".t(context),
                            color: labelInk,
                          ),
                          const SizedBox(height: 8.0),
                          Stack(
                            children: [
                              TextField(
                                controller: _noteController,
                                enabled: !_sending,
                                maxLines: 3,
                                minLines: 3,
                                decoration: InputDecoration(
                                  hintText: "sendMoney.notePlaceholder".t(
                                    context,
                                  ),
                                  filled: true,
                                  fillColor: cardBg,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                    borderSide: BorderSide(color: cardBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                    borderSide: BorderSide(color: cardBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                    borderSide: BorderSide(
                                      color: accent,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    14.0,
                                    12.0,
                                    40.0,
                                    12.0,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 10.0,
                                bottom: 10.0,
                                child: Icon(
                                  Symbols.edit_note_rounded,
                                  size: 20.0,
                                  color: labelInk.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _AmountKeypad(
                        backgroundColor: keypadBg,
                        borderColor: cardBorder,
                        onDigit: _appendDigit,
                        onBackspace: _backspace,
                        enabled: !_sending,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                      child: FilledButton(
                        onPressed: _sending || !canSubmit ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          disabledBackgroundColor: accent.withValues(
                            alpha: 0.35,
                          ),
                          minimumSize: const Size.fromHeight(52.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                        child: _sending
                            ? const Spinner.inline(
                                color: Colors.white,
                              )
                            : Text(
                                "sendMoney.submit".t(context),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 12.0),
                      child: Text(
                        "sendMoney.hint".t(context),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: labelInk,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.9,
      ),
    );
  }
}

class _RecipientCard extends StatelessWidget {
  const _RecipientCard({
    required this.name,
    required this.subtitle,
    required this.initials,
    required this.cardBg,
    required this.cardBorder,
    required this.headingInk,
    required this.subtitleInk,
  });

  final String name;
  final String subtitle;
  final String initials;
  final Color cardBg;
  final Color cardBorder;
  final Color headingInk;
  final Color subtitleInk;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.0,
            backgroundColor: accent.withValues(alpha: 0.12),
            child: Text(
              initials,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
                fontSize: 16.0,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: headingInk,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: subtitleInk,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Symbols.verified_rounded,
            color: accent,
            size: 26.0,
          ),
        ],
      ),
    );
  }
}

class _FromAccountCard extends StatelessWidget {
  const _FromAccountCard({
    required this.account,
    required this.cardBg,
    required this.cardBorder,
    required this.headingInk,
    required this.onTap,
  });

  final Account account;
  final Color cardBg;
  final Color cardBorder;
  final Color headingInk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(14.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Symbols.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: headingInk,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      "sendMoney.available".t(context, {
                        "amount": account.balance.formatMoney(),
                      }),
                      style: const TextStyle(
                        color: SendMoneyPage._balanceGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Symbols.keyboard_arrow_down_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountKeypad extends StatelessWidget {
  const _AmountKeypad({
    required this.backgroundColor,
    required this.borderColor,
    required this.onDigit,
    required this.onBackspace,
    required this.enabled,
  });

  final Color backgroundColor;
  final Color borderColor;
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color digitColor = Theme.of(context).colorScheme.onSurface;

    Widget keyCell({
      required Widget child,
      required VoidCallback? onTap,
    }) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.0),
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                height: 48.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    Widget row(List<Widget> keys) => Row(children: keys);

    return Column(
      children: [
        row([
          keyCell(
            child: Text("1", style: _digitStyle(digitColor)),
            onTap: () => onDigit("1"),
          ),
          keyCell(
            child: Text("2", style: _digitStyle(digitColor)),
            onTap: () => onDigit("2"),
          ),
          keyCell(
            child: Text("3", style: _digitStyle(digitColor)),
            onTap: () => onDigit("3"),
          ),
        ]),
        row([
          keyCell(
            child: Text("4", style: _digitStyle(digitColor)),
            onTap: () => onDigit("4"),
          ),
          keyCell(
            child: Text("5", style: _digitStyle(digitColor)),
            onTap: () => onDigit("5"),
          ),
          keyCell(
            child: Text("6", style: _digitStyle(digitColor)),
            onTap: () => onDigit("6"),
          ),
        ]),
        row([
          keyCell(
            child: Text("7", style: _digitStyle(digitColor)),
            onTap: () => onDigit("7"),
          ),
          keyCell(
            child: Text("8", style: _digitStyle(digitColor)),
            onTap: () => onDigit("8"),
          ),
          keyCell(
            child: Text("9", style: _digitStyle(digitColor)),
            onTap: () => onDigit("9"),
          ),
        ]),
        row([
          keyCell(
            child: Text(".", style: _digitStyle(digitColor)),
            onTap: () => onDigit("."),
          ),
          keyCell(
            child: Text("0", style: _digitStyle(digitColor)),
            onTap: () => onDigit("0"),
          ),
          keyCell(
            child: Icon(
              Symbols.backspace_rounded,
              color: digitColor,
              size: 22.0,
            ),
            onTap: onBackspace,
          ),
        ]),
      ],
    );
  }

  TextStyle _digitStyle(Color color) {
    return TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.0,
    );
  }
}
