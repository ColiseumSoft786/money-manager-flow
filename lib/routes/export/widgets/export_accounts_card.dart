import "package:flow/entity/account.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/export/export_options_theme.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class ExportAccountsCard extends StatelessWidget {
  final List<Account> accounts;
  final Set<String> selectedUuids;
  final ValueChanged<Account> onToggleAccount;
  final VoidCallback onSelectAll;

  const ExportAccountsCard({
    super.key,
    required this.accounts,
    required this.selectedUuids,
    required this.onToggleAccount,
    required this.onSelectAll,
  });

  bool get _allSelected => selectedUuids.length == accounts.length;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ExportOptionsTheme.cardFill(context),
        borderRadius: BorderRadius.circular(ExportOptionsTheme.cardRadius),
        border: Border.all(color: ExportOptionsTheme.cardBorder(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "sync.export.pdf.accounts".t(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ExportOptionsTheme.titleInk(context),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onSelectAll,
                  style: TextButton.styleFrom(
                    foregroundColor: ExportOptionsTheme.primary(context),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _allSelected
                        ? "general.select.clear".t(context)
                        : "general.select.all".t(context),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              "sync.export.pdf.accounts.selected".t(context, {
                "n": selectedUuids.length,
                "total": accounts.length,
              }),
              style: theme.textTheme.bodySmall?.copyWith(
                color: ExportOptionsTheme.mutedInk(context),
                fontSize: 12.0,
              ),
            ),
            const SizedBox(height: 8.0),
            for (int i = 0; i < accounts.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: ExportOptionsTheme.cardBorder(context),
                ),
              _AccountRow(
                account: accounts[i],
                selected: selectedUuids.contains(accounts[i].uuid),
                onTap: () => onToggleAccount(accounts[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final Account account;
  final bool selected;
  final VoidCallback onTap;

  const _AccountRow({
    required this.account,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: selected
          ? ExportOptionsTheme.tabSelectedFill(context).withValues(alpha: 0.55)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              FlowIcon(
                account.icon,
                size: 22.0,
                plated: true,
                platePadding: const EdgeInsets.all(8.0),
                borderRadius: BorderRadius.circular(999.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  account.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0,
                    color: ExportOptionsTheme.titleInk(context),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22.0,
                height: 22.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? ExportOptionsTheme.primary(context)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? ExportOptionsTheme.primary(context)
                        : const Color(0xFFCBD5E1),
                    width: 2.0,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Symbols.check_rounded,
                        size: 14.0,
                        color: Colors.white,
                        fill: 1,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
