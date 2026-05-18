import "package:flow/l10n/extensions.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

/// Centered delete confirmation dialog (preferences-style).
class FlowDeletionAlertDialog extends StatelessWidget {
  final String title;
  final String message;

  const FlowDeletionAlertDialog({
    super.key,
    required this.title,
    required this.message,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => FlowDeletionAlertDialog(
        title: title,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.0,
              height: 56.0,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Symbols.delete_rounded,
                size: 28.0,
                color: Color(0xFF4A86F7),
                fill: 0.0,
              ),
            ),
            const SizedBox(height: 18.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                color: Color(0xFF0F172A),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 14.0,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              children: [
                Expanded(
                  child: _DialogActionButton(
                    label: "general.cancel".t(context),
                    onPressed: () => Navigator.of(context).pop(false),
                    foregroundColor: const Color(0xFF0F172A),
                    backgroundColor: const Color(0xFFF1F5F9),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _DialogActionButton(
                    label: "general.delete".t(context),
                    onPressed: () => Navigator.of(context).pop(true),
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF4A86F7),
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

class _DialogActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color foregroundColor;
  final Color backgroundColor;

  const _DialogActionButton({
    required this.label,
    required this.onPressed,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15.0,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
