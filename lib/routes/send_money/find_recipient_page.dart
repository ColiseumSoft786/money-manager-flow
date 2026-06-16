import "package:flow/data/firebase_friend.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/send_money/send_money_contact.dart";
import "package:flow/services/firebase_friends_service.dart";
import "package:flow/services/firebase_send_money_service.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// Find someone — matches CashPilot find-someone mock.
class FindRecipientPage extends StatefulWidget {
  const FindRecipientPage({super.key});

  @override
  State<FindRecipientPage> createState() => _FindRecipientPageState();
}

class _FindRecipientPageState extends State<FindRecipientPage> {
  final TextEditingController _queryController = TextEditingController();
  final FirebaseFriendsService _friendsService = FirebaseFriendsService();

  bool _searching = false;
  FirebaseUserProfile? _selected;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _select(FirebaseUserProfile profile) {
    setState(() => _selected = profile);
  }

  Future<void> _search() async {
    final String query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searching = true;
    });

    try {
      final FirebaseUserProfile? found = await _friendsService.findUser(query);
      if (!mounted) return;
      setState(() {
        _searching = false;
        if (found != null) {
          _selected = found;
        }
      });
      if (found == null) {
        _showMessage("friends.error.notFound".t(context));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _searching = false);
      _showMessage(e.toString());
    }
  }

  void _continue() {
    final FirebaseUserProfile? target = _selected;
    if (target == null) return;
    context.push("/send-money/pay", extra: target);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color pageBg = dark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFF8FAFC);
    final Color headingInk = Theme.of(context).colorScheme.onSurface;
    final Color labelInk = Theme.of(context).colorScheme.onSurfaceVariant;
    final Color fieldFill = Theme.of(context).colorScheme.surface;
    final Color fieldBorder = dark
        ? Theme.of(context).colorScheme.outlineVariant
        : const Color(0xFFE2E8F0);
    final Color accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Text("sendMoney.findSomeone".t(context)),
      ),
      body: StreamBuilder(
        stream: FirebaseSendMoneyService().watchOutgoing(),
        builder: (context, transferSnap) {
          if (!transferSnap.hasData) {
            return const Spinner.center();
          }

          final List<SendMoneyContact> recent =
              SendMoneyContact.fromTransfers(transferSnap.data!);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  children: [
                    _FieldLabel(
                      text: "sendMoney.recipientInfo".t(context),
                      color: labelInk,
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _queryController,
                      autocorrect: false,
                      style: TextStyle(color: headingInk),
                      cursorColor: headingInk,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      onChanged: (_) {
                        if (_selected != null &&
                            _queryController.text.trim().isEmpty) {
                          setState(() => _selected = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "sendMoney.searchPlaceholder".t(context),
                        hintStyle: TextStyle(color: labelInk),
                        filled: true,
                        fillColor: fieldFill,
                        prefixIcon: Icon(
                          Symbols.search_rounded,
                          color: labelInk,
                        ),
                        suffixIcon: _searching
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Spinner.inline(size: 20.0),
                              )
                            : IconButton(
                                onPressed: _search,
                                icon: Icon(
                                  Symbols.arrow_forward_rounded,
                                  color: labelInk,
                                ),
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide(color: fieldBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide(color: fieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide(
                            color: accent,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (_selected != null &&
                        !recent.any((c) => c.userId == _selected!.userId)) ...[
                      const SizedBox(height: 16.0),
                      _SearchResultRow(
                        profile: _selected!,
                        selected: true,
                        onTap: () {},
                      ),
                    ],
                    if (recent.isNotEmpty) ...[
                      const SizedBox(height: 24.0),
                      _FieldLabel(
                        text: "sendMoney.recentOrSuggested".t(context),
                        color: labelInk,
                      ),
                      const SizedBox(height: 12.0),
                      _RecentContactsLayout(
                        contacts: recent,
                        selectedUserId: _selected?.userId,
                        onSelect: (c) => _select(c.toProfile()),
                      ),
                    ],
                    if (recent.isEmpty && _selected == null) ...[
                      const SizedBox(height: 48.0),
                      _EmptyFindIllustration(
                        message: "sendMoney.findEmptyHint".t(context),
                        labelColor: labelInk,
                      ),
                    ] else if (recent.isEmpty && _selected != null) ...[
                      const SizedBox(height: 32.0),
                    ] else ...[
                      const SizedBox(height: 32.0),
                      _EmptyFindIllustration(
                        message: "sendMoney.findEmptyHint".t(context),
                        labelColor: labelInk,
                        compact: true,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: FilledButton(
                  onPressed: _selected != null ? _continue : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    disabledBackgroundColor: accent.withValues(alpha: 0.35),
                    minimumSize: const Size.fromHeight(52.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "sendMoney.continueButton".t(context),
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(
                        Symbols.arrow_forward_rounded,
                        size: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.color});

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

class _RecentContactsLayout extends StatelessWidget {
  const _RecentContactsLayout({
    required this.contacts,
    required this.selectedUserId,
    required this.onSelect,
  });

  final List<SendMoneyContact> contacts;
  final String? selectedUserId;
  final void Function(SendMoneyContact) onSelect;

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) return const SizedBox.shrink();

    final SendMoneyContact first = contacts.first;
    final List<SendMoneyContact> rest = contacts.length > 1
        ? contacts.sublist(1)
        : const [];

    return Column(
      children: [
        _FeaturedContactCard(
          contact: first,
          selected: selectedUserId == first.userId,
          onTap: () => onSelect(first),
        ),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 12.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < rest.length && i < 2; i++) ...[
                if (i > 0) const SizedBox(width: 12.0),
                Expanded(
                  child: _GridContactCard(
                    contact: rest[i],
                    colorIndex: i + 1,
                    selected: selectedUserId == rest[i].userId,
                    onTap: () => onSelect(rest[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _FeaturedContactCard extends StatelessWidget {
  const _FeaturedContactCard({
    required this.contact,
    required this.selected,
    required this.onTap,
  });

  final SendMoneyContact contact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color headingInk = Theme.of(context).colorScheme.onSurface;
    final Color subtitleInk = Theme.of(context).colorScheme.onSurfaceVariant;
    final Color accent = Theme.of(context).colorScheme.primary;
    final Color border = selected
        ? accent
        : Theme.of(context).colorScheme.outlineVariant;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: border,
              width: selected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _ContactAvatar(contact: contact, colorIndex: 0, size: 48.0),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.displayLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: headingInk,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      contact.handleLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: subtitleInk,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 16.0,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Symbols.chevron_right_rounded,
                  size: 20.0,
                  color: subtitleInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridContactCard extends StatelessWidget {
  const _GridContactCard({
    required this.contact,
    required this.colorIndex,
    required this.selected,
    required this.onTap,
  });

  final SendMoneyContact contact;
  final int colorIndex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color headingInk = Theme.of(context).colorScheme.onSurface;
    final Color subtitleInk = Theme.of(context).colorScheme.onSurfaceVariant;
    final Color accent = Theme.of(context).colorScheme.primary;
    final Color bg = _contactTint(context, colorIndex).withValues(alpha: 0.35);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: selected
                ? Border.all(color: accent, width: 2.0)
                : null,
          ),
          child: Column(
            children: [
              _ContactAvatar(contact: contact, colorIndex: colorIndex, size: 56.0),
              const SizedBox(height: 12.0),
              Text(
                contact.displayLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: headingInk,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                contact.handleLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtitleInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  final FirebaseUserProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contact = SendMoneyContact(
      userId: profile.userId,
      displayName: profile.displayName,
      handle: profile.handle,
    );
    return _FeaturedContactCard(
      contact: contact,
      selected: selected,
      onTap: onTap,
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({
    required this.contact,
    required this.colorIndex,
    required this.size,
  });

  final SendMoneyContact contact;
  final int colorIndex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color tint = _contactTint(context, colorIndex);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: tint.withValues(alpha: 0.25),
      child: Text(
        contact.initials,
        style: TextStyle(
          color: tint,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}

Color _contactTint(BuildContext context, int index) {
  final ColorScheme scheme = Theme.of(context).colorScheme;
  return switch (index % 3) {
    0 => scheme.primary,
    1 => scheme.secondary,
    _ => scheme.tertiary,
  };
}

class _EmptyFindIllustration extends StatelessWidget {
  const _EmptyFindIllustration({
    required this.message,
    required this.labelColor,
    this.compact = false,
  });

  final String message;
  final Color labelColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    final double box = compact ? 100.0 : 140.0;
    return Column(
      children: [
        Container(
          width: box,
          height: box,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Icon(
            Symbols.person_search_rounded,
            size: compact ? 48.0 : 64.0,
            color: accent.withValues(alpha: 0.35),
          ),
        ),
        SizedBox(height: compact ? 12.0 : 20.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: labelColor,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
