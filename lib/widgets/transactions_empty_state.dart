import "package:flow/l10n/extensions.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Empty-state card for [TransactionsPage] and similar transaction lists.
class TransactionsEmptyState extends StatelessWidget {
  final String? description;
  final VoidCallback? onAddTransaction;

  const TransactionsEmptyState({
    super.key,
    this.description,
    this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const Color titleInk = kFlowHomeTransactionHeadingInk;
    const Color subtitleInk = kFlowAccountRowBalanceInkLight;
    const Color primaryAccent = kFlowSetupAccountsContinueButtonFill;
    const Color iconHalo = Color(0xFFDBEAFE); // blue-100
    const Color cardBorder = Color(0xFFE5E7EB);

    final String resolvedDescription =
        description ?? "transactions.query.noResult.description".t(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 32.0),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: cardBorder, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 36.0, 24.0, 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 128.0,
                  height: 112.0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 108.0,
                        height: 108.0,
                        decoration: const BoxDecoration(
                          color: iconHalo,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Symbols.receipt_long_rounded,
                          size: 52.0,
                          color: primaryAccent,
                          fill: 0.0,
                        ),
                      ),
                      Positioned(
                        right: 4.0,
                        bottom: 0.0,
                        child: Container(
                          width: 46.0,
                          height: 46.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12.0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Symbols.search_rounded,
                            size: 22.0,
                            color: primaryAccent,
                            fill: 0.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28.0),
                Text(
                  "transactions.query.noResult".t(context),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20.0,
                    color: titleInk,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  resolvedDescription,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: subtitleInk,
                    fontSize: 14.0,
                    height: 1.5,
                  ),
                ),
                if (onAddTransaction != null) ...[
                  const SizedBox(height: 28.0),
                  Button(
                    onTap: onAddTransaction,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 14.5),
                    borderRadius: BorderRadius.circular(14.0),
                    backgroundColor: primaryAccent,
                    foregroundColor: Colors.white,
                    elevation: 3.0,
                    shadowColor: primaryAccent.withValues(alpha: 0.35),
                    child: Text(
                      "transactions.query.addTransaction".t(context),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
