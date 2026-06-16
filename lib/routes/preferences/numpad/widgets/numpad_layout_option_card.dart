import "package:flow/l10n/extensions.dart";
import "package:flow/routes/preferences/numpad/numpad_preferences_theme.dart";
import "package:flow/widgets/numpad.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class NumpadLayoutOptionCard extends StatelessWidget {
  final bool isPhoneLayout;
  final bool selected;
  final VoidCallback onTap;

  const NumpadLayoutOptionCard({
    super.key,
    required this.isPhoneLayout,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final String title = isPhoneLayout
        ? "preferences.numpad.layout.modern".t(context)
        : "preferences.numpad.layout.classic".t(context);
    final String subtitle = isPhoneLayout
        ? "preferences.numpad.layout.modern.subtitle".t(context)
        : "preferences.numpad.layout.classic.subtitle".t(context);

    final Color fillColor = selected
        ? NumpadPreferencesTheme.selectedFill(context)
        : NumpadPreferencesTheme.cardFill;
    final Color borderColor = selected
        ? NumpadPreferencesTheme.selectedBorder(context)
        : NumpadPreferencesTheme.cardBorder;

    return AnimatedContainer(
      duration:  Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(NumpadPreferencesTheme.cardRadius),
        border: Border.all(
          color: borderColor,
          width: selected ? 2.0 : 1.0,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: NumpadPreferencesTheme.primary(context).withValues(alpha: 0.12),
                  blurRadius: 16.0,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color.fromRGBO(15, 23, 42, 0.03),
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NumpadPreferencesTheme.cardRadius),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 14.0, 12.0, 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      isPhoneLayout
                          ? Symbols.smartphone_rounded
                          : Symbols.calculate_rounded,
                      size: 18.0,
                      color: selected
                          ? NumpadPreferencesTheme.primary(context)
                          : NumpadPreferencesTheme.subtitleInk,
                      fill: 0.0,
                    ),
                    const Spacer(),
                    if (selected)
                      Container(
                        width: 22.0,
                        height: 22.0,
                        decoration:  BoxDecoration(
                          color: NumpadPreferencesTheme.primary(context),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Symbols.check_rounded,
                          size: 14.0,
                          color: Colors.white,
                          fill: 0.0,
                        ),
                      )
                    else
                      Container(
                        width: 22.0,
                        height: 22.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: NumpadPreferencesTheme.subtitleInk.withValues(
                              alpha: 0.35,
                            ),
                            width: 2.0,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10.0),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: NumpadPreferencesTheme.previewPlateFill,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Numpad(
                          width: constraints.maxWidth,
                          padding: EdgeInsets.zero,
                          showPanel: false,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                          children: isPhoneLayout
                              ? _buildPhoneNumpad(context)
                              : _buildClassicNumpad(context),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                    color: NumpadPreferencesTheme.titleInk,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: NumpadPreferencesTheme.subtitleInk,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildClassicNumpad(BuildContext context) {
    return "789 456 123 0  ".characters
        .map(
          (char) => NumpadButton(
            crossAxisCellCount: char == "0" ? 2 : 1,
            borderRadiusSize: 8.0,
            backgroundColor: NumpadPreferencesTheme.cardFill,
            child: Text(
              char,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildPhoneNumpad(BuildContext context) {
    return "123 456 789 0  ".characters
        .map(
          (char) => NumpadButton(
            crossAxisCellCount: char == "0" ? 2 : 1,
            borderRadiusSize: 8.0,
            backgroundColor: NumpadPreferencesTheme.cardFill,
            child: Text(
              char,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
        )
        .toList();
  }
}
