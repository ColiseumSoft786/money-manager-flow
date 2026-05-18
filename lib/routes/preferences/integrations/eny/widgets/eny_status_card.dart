import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/integrations/eny/eny_preferences_theme.dart";
import "package:flow/routes/preferences/integrations/eny/widgets/eny_status_badge.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class EnyStatusCard extends StatelessWidget {
  final bool connected;
  final String? email;
  final bool creditsBusy;
  final int? remainingCredits;
  final VoidCallback onConnect;
  final VoidCallback? onRefreshCredits;

  const EnyStatusCard({
    super.key,
    required this.connected,
    required this.email,
    required this.creditsBusy,
    required this.remainingCredits,
    required this.onConnect,
    this.onRefreshCredits,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: EnyPreferencesTheme.cardFill,
        borderRadius: BorderRadius.circular(EnyPreferencesTheme.cardRadius),
        border: Border.all(color: EnyPreferencesTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  "integrations.eny.status.title".t(context),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                    color: EnyPreferencesTheme.titleInk,
                  ),
                ),
                const Spacer(),
                EnyStatusBadge(
                  connected: connected,
                  label: "integrations.eny.connected#$connected".t(context),
                ),
              ],
            ),
            if (email != null) ...[
              const SizedBox(height: 8.0),
              Text(
                email!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: EnyPreferencesTheme.titleInk,
                ),
              ),
            ],
            const SizedBox(height: 10.0),
            Text(
              connected
                  ? "integrations.eny.status.connectedDescription".t(context)
                  : "integrations.eny.status.disconnectedDescription".t(
                      context,
                    ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: EnyPreferencesTheme.subtitleInk,
                fontSize: 13.0,
                height: 1.45,
              ),
            ),
            if (connected && onRefreshCredits != null) ...[
              const SizedBox(height: 14.0),
              Material(
                color: EnyPreferencesTheme.canvas,
                borderRadius: BorderRadius.circular(12.0),
                child: InkWell(
                  onTap: creditsBusy ? null : onRefreshCredits,
                  borderRadius: BorderRadius.circular(12.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.paid_rounded,
                          size: 22.0,
                          color: EnyPreferencesTheme.primary(context),
                          fill: 0.0,
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            "integrations.eny.creditsRemaining".t(context),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.0,
                              color: EnyPreferencesTheme.titleInk,
                            ),
                          ),
                        ),
                        Text(
                          (creditsBusy || remainingCredits == null)
                              ? "...."
                              : remainingCredits.toString(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                            color: EnyPreferencesTheme.titleInk,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Icon(
                          Symbols.refresh_rounded,
                          size: 18.0,
                          color: EnyPreferencesTheme.subtitleInk,
                          fill: 0.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (!connected) ...[
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onConnect,
                  style: FilledButton.styleFrom(
                    backgroundColor: EnyPreferencesTheme.primary(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Symbols.link_rounded, size: 20.0, fill: 0.0),
                  label: Text(
                    "integrations.eny.connectNow".t(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
