import "package:flow/entity/transaction_tag.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class TransactionTagsPage extends StatefulWidget {
  const TransactionTagsPage({super.key});

  @override
  State<TransactionTagsPage> createState() => _TransactionTagsPageState();
}

class _TransactionTagsPageState extends State<TransactionTagsPage> {
  QueryBuilder<TransactionTag> qb() => ObjectBox()
      .box<TransactionTag>()
      .query()
      .order(TransactionTag_.createdDate);

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color screenBackground = isDark ? scheme.surface : Colors.white;
    final Color cardFill = isDark ? scheme.surfaceContainerHigh : Colors.white;
    final Color titleInk = isDark ? scheme.onSurface : kFlowHomeTransactionHeadingInk;
    final Color subtitleInk =
        isDark ? scheme.onSurfaceVariant : kFlowAccountRowBalanceInkLight;
    final Color chevronInk =
        isDark ? scheme.onSurfaceVariant : kFlowMonthSelectorChevronInkLight;
    final Color dividerInk =
        isDark ? scheme.outlineVariant : kFlowAccountRowDividerLight;
    final Color cardShadow =
        isDark ? Colors.transparent : const Color.fromRGBO(0, 0, 0, 0.08);
    final Color iconPlateFill = context.flowAccent.iconPlateFill;
    final Color iconPlateInk = context.flowAccent.iconPlateInk;

    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: screenBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "transaction.tags".t(context),
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: titleInk,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: dividerInk,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<TransactionTag>>(
          stream: qb()
              .watch(triggerImmediately: true)
              .map((event) => event.find()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Spinner.center();
            }

            final List<TransactionTag> tags = snapshot.requireData;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: _NewTagCard(
                    titleInk: titleInk,
                    subtitleInk: subtitleInk,
                    chevronInk: chevronInk,
                    cardShadow: cardShadow,
                    iconPlateFill: iconPlateFill,
                    iconPlateInk: iconPlateInk,
                    cardFill: cardFill,
                    onTap: () => context.push("/transactionTags/new"),
                  ),
                ),
                if (tags.isEmpty)
                  Expanded(
                    child: _EmptyTagsState(
                      titleInk: titleInk,
                      subtitleInk: subtitleInk,
                      cardShadow: cardShadow,
                      iconPlateFill: iconPlateFill,
                      iconPlateInk: iconPlateInk,
                      cardFill: cardFill,
                      onCreate: () => context.push("/transactionTags/new"),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        16.0,
                        16.0,
                        24.0,
                      ),
                      itemCount: tags.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                      itemBuilder: (context, index) {
                        final TransactionTag tag = tags[index];
                        return _TagRow(
                          tag: tag,
                          titleInk: titleInk,
                          chevronInk: chevronInk,
                          cardShadow: cardShadow,
                          cardFill: cardFill,
                          onTap: () =>
                              context.push("/transactionTags/${tag.id}"),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Top action card — circular blue “+” plate, title, subtitle, chevron.
class _NewTagCard extends StatelessWidget {
  final Color titleInk;
  final Color subtitleInk;
  final Color chevronInk;
  final Color cardShadow;
  final Color iconPlateFill;
  final Color iconPlateInk;
  final Color cardFill;
  final VoidCallback onTap;

  const _NewTagCard({
    required this.titleInk,
    required this.subtitleInk,
    required this.chevronInk,
    required this.cardShadow,
    required this.iconPlateFill,
    required this.iconPlateInk,
    required this.cardFill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius radius = BorderRadius.circular(16.0);

    return Material(
      color: cardFill,
      elevation: 0,
      shadowColor: cardShadow,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: cardFill,
          boxShadow: [
            BoxShadow(
              color: cardShadow,
              blurRadius: 12.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 14.0, 12.0, 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: iconPlateFill,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Symbols.add_rounded,
                    size: 24.0,
                    color: iconPlateInk,
                    fill: 0.0,
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "transaction.tags.new".t(context),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                          color: titleInk,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        "transaction.tags.newCardSubtitle".t(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtitleInk,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Icon(
                  Symbols.chevron_right_rounded,
                  size: 22.0,
                  color: chevronInk,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Centered empty state: elevated icon tile, copy, primary CTA.
class _EmptyTagsState extends StatelessWidget {
  final Color titleInk;
  final Color subtitleInk;
  final Color cardShadow;
  final Color iconPlateFill;
  final Color iconPlateInk;
  final Color cardFill;
  final VoidCallback onCreate;

  const _EmptyTagsState({
    required this.titleInk,
    required this.subtitleInk,
    required this.cardShadow,
    required this.iconPlateFill,
    required this.iconPlateInk,
    required this.cardFill,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const Color primaryAccent = kFlowSetupAccountsContinueButtonFill;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: cardFill,
                borderRadius: BorderRadius.circular(22.0),
                boxShadow: [
                  BoxShadow(
                    color: cardShadow,
                    blurRadius: 18.0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Icon(
                  Symbols.label_off_rounded,
                  size: 56.0,
                  color: iconPlateInk,
                  fill: 0.0,
                ),
              ),
            ),
            const SizedBox(height: 28.0),
            Text(
              "transaction.tags.emptyTitle".t(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20.0,
                color: titleInk,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              "transaction.tags.emptyDescription".t(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: subtitleInk,
                fontSize: 14.0,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28.0),
            Button(
              onTap: onCreate,
              padding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 28.0,
              ),
              borderRadius: BorderRadius.circular(100.0),
              backgroundColor: primaryAccent,
              foregroundColor: Colors.white,
              elevation: 3.0,
              shadowColor: primaryAccent.withValues(alpha: 0.35),
              child: Text(
                "transaction.tags.createFirst".t(context),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Existing tag row — white card with icon, title, chevron (when list is non-empty).
class _TagRow extends StatelessWidget {
  final TransactionTag tag;
  final Color titleInk;
  final Color chevronInk;
  final Color cardShadow;
  final Color cardFill;
  final VoidCallback onTap;

  const _TagRow({
    required this.tag,
    required this.titleInk,
    required this.chevronInk,
    required this.cardShadow,
    required this.cardFill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius radius = BorderRadius.circular(14.0);

    return Material(
      color: cardFill,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: cardFill,
          boxShadow: [
            BoxShadow(
              color: cardShadow,
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 10.0, 12.0),
            child: Row(
              children: [
                FlowIcon(tag.icon, size: 22.0, plated: true, colorScheme: tag.colorScheme),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    tag.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                      color: titleInk,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Icon(
                  Symbols.chevron_right_rounded,
                  size: 20.0,
                  color: chevronInk,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
