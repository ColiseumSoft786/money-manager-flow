import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/routes/preferences/language/language_selection_theme.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class LanguageSelectionSheet extends StatefulWidget {
  final Locale? currentLocale;

  const LanguageSelectionSheet({super.key, this.currentLocale});

  @override
  State<LanguageSelectionSheet> createState() => _LanguageSelectionSheetState();
}

class _LanguageSelectionSheetState extends State<LanguageSelectionSheet> {
  String _query = "";

  List<Locale> get _locales => FlowLocalizations.supportedLocales;

  List<Locale> get _filteredLocales {
    final String normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return _locales;

    return _locales
        .where(
          (Locale locale) =>
              locale.name.toLowerCase().contains(normalized) ||
              locale.endonym.toLowerCase().contains(normalized),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.92;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);
    final List<Locale> locales = _filteredLocales;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Material(
            color: LanguageSelectionTheme.canvas,
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SheetHeader(
                    title: "preferences.language".t(context),
                    onBack: () => context.pop(),
                  ),
                  const Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: LanguageSelectionTheme.divider,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 12.0),
                    child: TextField(
                      onChanged: (String value) =>
                          setState(() => _query = value),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: LanguageSelectionTheme.searchFill,
                        hintText: "preferences.language.search".t(context),
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: LanguageSelectionTheme.subtitleInk,
                          fontSize: 15.0,
                        ),
                        prefixIcon: Icon(
                          Symbols.search_rounded,
                          size: 22.0,
                          color: LanguageSelectionTheme.subtitleInk,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 12.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: LanguageSelectionTheme.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: LanguageSelectionTheme.primary(context),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: LanguageSelectionTheme.sheetFill,
                          borderRadius: BorderRadius.circular(
                            LanguageSelectionTheme.cardRadius,
                          ),
                          border: Border.all(
                            color: LanguageSelectionTheme.border,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            LanguageSelectionTheme.cardRadius,
                          ),
                          child: locales.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    "preferences.language.searchNoResults".t(
                                      context,
                                    ),
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: LanguageSelectionTheme.subtitleInk,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: locales.length,
                                  separatorBuilder: (_, __) => const Divider(
                                    height: 1.0,
                                    thickness: 1.0,
                                    indent: 16.0,
                                    endIndent: 16.0,
                                    color: LanguageSelectionTheme.divider,
                                  ),
                                  itemBuilder: (context, index) {
                                    final Locale locale = locales[index];
                                    final bool selected =
                                        widget.currentLocale == locale;

                                    return _LanguageRow(
                                      title: locale.name,
                                      subtitle: locale.endonym,
                                      selected: selected,
                                      onTap: () => context.pop(locale),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _SheetHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: Icon(
                Symbols.arrow_back_rounded,
                color: LanguageSelectionTheme.titleInk,
              ),
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 17.0,
              color: LanguageSelectionTheme.titleInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                        color: LanguageSelectionTheme.titleInk,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: LanguageSelectionTheme.subtitleInk,
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              _LanguageRadio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageRadio extends StatelessWidget {
  final bool selected;

  const _LanguageRadio({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22.0,
      height: 22.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? LanguageSelectionTheme.primary(context) : Colors.transparent,
        border: Border.all(
          color: selected
              ? LanguageSelectionTheme.primary(context)
              : LanguageSelectionTheme.radioIdleBorder,
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
