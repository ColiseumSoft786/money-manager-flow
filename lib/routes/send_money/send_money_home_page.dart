import "package:flow/data/firebase_friend.dart";
import "package:flow/data/firebase_transfer.dart";
import "package:flow/routes/send_money/send_money_contact.dart";
import "package:flow/data/money.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/firebase_friends_service.dart";
import "package:flow/services/firebase_send_money_service.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:share_plus/share_plus.dart";

/// Send money hub — matches CashPilot send-money mock (tag, top contacts, recent).
class SendMoneyHomePage extends StatelessWidget {
  const SendMoneyHomePage({super.key});

  static const Color _expenseRed = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final FirebaseSendMoneyService service = FirebaseSendMoneyService();
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color pageBg = dark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFF8FAFC);
    final Color cardBorder = dark
        ? Theme.of(context).colorScheme.outlineVariant
        : const Color(0xFFE2E8F0);
    final Color headingInk = Theme.of(context).colorScheme.onSurface;
    final Color actionInk = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Text("sendMoney.title".t(context)),
      ),
      body: SafeArea(
        child: FutureBuilder<FirebaseUserProfile?>(
          future: FirebaseFriendsService().getMyProfile(),
          builder: (context, profileSnap) {
            return StreamBuilder<List<PeerTransfer>>(
              stream: service.watchOutgoing(),
              builder: (context, transferSnap) {
                if (!transferSnap.hasData) {
                  return const Spinner.center();
                }

                final List<PeerTransfer> transfers = transferSnap.data!;
                final List<SendMoneyContact> topContacts =
                    SendMoneyContact.fromTransfers(transfers);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          0,
                          16.0,
                          88.0,
                        ),
                        children: [
                          if (profileSnap.data != null)
                            _MyTagCard(
                              handle: profileSnap.data!.handleLabel,
                              onShare: () => _shareHandle(
                                context,
                                profileSnap.data!.handleLabel,
                              ),
                              onCopy: () => _copyHandle(
                                context,
                                profileSnap.data!.handleLabel,
                              ),
                            ),
                          const SizedBox(height: 16.0),
                          _FindSomeoneButton(
                            onTap: () => context.push("/send-money/find"),
                          ),
                          if (topContacts.isNotEmpty) ...[
                            const SizedBox(height: 24.0),
                            _SectionHeader(
                              title: "sendMoney.topContacts".t(context),
                              titleColor: headingInk,
                              actionColor: actionInk,
                              actionLabel: "sendMoney.viewAll".t(context),
                              onAction: () => _showAllContacts(
                                context,
                                topContacts,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            SizedBox(
                              height: 96.0,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: topContacts.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 16.0),
                                itemBuilder: (context, index) {
                                  final SendMoneyContact c =
                                      topContacts[index];
                                  return _TopContactChip(
                                    contact: c,
                                    highlighted: index == 0,
                                    onTap: () => _payContact(context, c),
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 24.0),
                          _SectionHeader(
                            title: "sendMoney.recent".t(context),
                            titleColor: headingInk,
                          ),
                          const SizedBox(height: 12.0),
                          if (transfers.isEmpty)
                            _RecentEmptyCard(borderColor: cardBorder)
                          else
                            _RecentSendsCard(
                              transfers: transfers,
                              borderColor: cardBorder,
                              onTapTransfer: (t) => _payTransfer(context, t),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push("/send-money/find"),
        child: const Icon(Symbols.add_rounded),
      ),
    );
  }

  static void _payContact(BuildContext context, SendMoneyContact contact) {
    context.push(
      "/send-money/pay",
      extra: contact.toProfile(),
    );
  }

  static void _payTransfer(BuildContext context, PeerTransfer transfer) {
    context.push(
      "/send-money/pay",
      extra: FirebaseUserProfile(
        userId: transfer.toUserId,
        displayName: transfer.toDisplayName,
        handle: transfer.toHandle,
      ),
    );
  }

  static void _shareHandle(BuildContext context, String handle) {
    Share.share("sendMoney.shareHandleMessage".t(context, handle));
  }

  static void _copyHandle(BuildContext context, String handle) {
    Clipboard.setData(ClipboardData(text: handle));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("sendMoney.handleCopied".t(context))),
    );
  }

  static void _showAllContacts(
    BuildContext context,
    List<SendMoneyContact> contacts,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "sendMoney.topContacts".t(context),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...contacts.map(
              (c) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.12),
                  child: Text(
                    c.initials,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(c.displayLabel),
                subtitle: Text(c.handleLabel),
                onTap: () {
                  Navigator.pop(ctx);
                  _payContact(context, c);
                },
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}

class _MyTagCard extends StatelessWidget {
  const _MyTagCard({
    required this.handle,
    required this.onShare,
    required this.onCopy,
  });

  final String handle;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.28),
            blurRadius: 12.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "sendMoney.myTag".t(context),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  handle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _TagIconButton(icon: Symbols.share_rounded, onTap: onShare),
          const SizedBox(width: 8.0),
          _TagIconButton(icon: Symbols.content_copy_rounded, onTap: onCopy),
        ],
      ),
    );
  }
}

class _TagIconButton extends StatelessWidget {
  const _TagIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40.0,
          height: 40.0,
          child: Icon(icon, color: Colors.white, size: 20.0),
        ),
      ),
    );
  }
}

class _FindSomeoneButton extends StatelessWidget {
  const _FindSomeoneButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: accent,
      borderRadius: BorderRadius.circular(14.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Symbols.search_rounded,
                color: Colors.white,
                size: 22.0,
              ),
              const SizedBox(width: 10.0),
              Text(
                "sendMoney.findSomeone".t(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.titleColor,
    this.actionColor,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Color titleColor;
  final Color? actionColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: actionColor ?? titleColor,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _TopContactChip extends StatelessWidget {
  const _TopContactChip({
    required this.contact,
    required this.highlighted,
    required this.onTap,
  });

  final SendMoneyContact contact;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72.0,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: highlighted
                    ? Border.all(
                        color: accent,
                        width: 2.5,
                      )
                    : null,
              ),
              child: CircleAvatar(
                radius: 28.0,
                backgroundColor: accent.withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  contact.initials,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: contact.initials.length > 1 ? 16.0 : 20.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              contact.shortName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentEmptyCard extends StatelessWidget {
  const _RecentEmptyCard({required this.borderColor});

  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        "sendMoney.recentEmpty".t(context),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _RecentSendsCard extends StatelessWidget {
  const _RecentSendsCard({
    required this.transfers,
    required this.borderColor,
    required this.onTapTransfer,
  });

  final List<PeerTransfer> transfers;
  final Color borderColor;
  final void Function(PeerTransfer) onTapTransfer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          for (int i = 0; i < transfers.length; i++) ...[
            if (i > 0) Divider(height: 1.0, color: borderColor),
            _RecentSendRow(
              transfer: transfers[i],
              onTap: () => onTapTransfer(transfers[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentSendRow extends StatelessWidget {
  const _RecentSendRow({required this.transfer, required this.onTap});

  final PeerTransfer transfer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String title = transfer.toDisplayName.isNotEmpty
        ? transfer.toDisplayName
        : "@${transfer.toHandle}";
    final String? when = transfer.createdAt != null
        ? DateFormat("MMM dd, yyyy • HH:mm").format(
            transfer.createdAt!.toLocal(),
          )
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.0,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Symbols.person_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 22.0,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (when != null) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      when,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MoneyText(
                  Money(-transfer.amount.abs(), transfer.currency),
                  displayAbsoluteAmount: true,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: SendMoneyHomePage._expenseRed,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "sendMoney.category.personal".t(context),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
