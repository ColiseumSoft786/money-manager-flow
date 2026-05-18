import "package:flutter/material.dart";
import "package:flow/routes/preferences/transfer/transfer_preferences_theme.dart";
import "package:material_symbols_icons/symbols.dart";

class TransferHeroIllustration extends StatelessWidget {
  const TransferHeroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220.0,
        height: 120.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200.0,
              height: 200.0,
              decoration: const BoxDecoration(
                color: TransferPreferencesTheme.heroCircleFill,
                shape: BoxShape.circle,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HeroWalletCard(
                  icon: Symbols.account_balance_wallet_rounded,
                  iconColor: TransferPreferencesTheme.primary(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Icon(
                    Symbols.arrow_forward_rounded,
                    size: 20.0,
                    color: TransferPreferencesTheme.primary(context),
                    fill: 0.0,
                  ),
                ),
                _HeroWalletCard(
                  icon: Symbols.savings_rounded,
                  iconColor: TransferPreferencesTheme.heroMutedIcon,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroWalletCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const _HeroWalletCard({required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.0,
      height: 56.0,
      decoration: BoxDecoration(
        color: TransferPreferencesTheme.heroCardFill,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: TransferPreferencesTheme.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.06),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 28.0, color: iconColor, fill: 0.0),
    );
  }
}
