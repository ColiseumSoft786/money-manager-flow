import "package:flow/routes/preferences/transfer/transfer_preferences_theme.dart";
import "package:flutter/material.dart";

class TransferOptionRadio extends StatelessWidget {
  final bool selected;

  const TransferOptionRadio({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22.0,
      height: 22.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? TransferPreferencesTheme.primary(context) : Colors.transparent,
        border: Border.all(
          color: selected
              ? TransferPreferencesTheme.primary(context)
              : TransferPreferencesTheme.radioIdleBorder,
          width: 2.0,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8.0,
                height: 8.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
