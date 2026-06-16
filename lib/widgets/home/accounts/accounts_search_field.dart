import "package:flow/routes/home/accounts/accounts_tab_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class AccountsSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final VoidCallback? onClear;

  const AccountsSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AccountsTabTheme.titleInk(context),
        fontSize: 15.0,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AccountsTabTheme.subtitleInk(context)),
        filled: true,
        fillColor: AccountsTabTheme.cardFill(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 12.0,
        ),
        prefixIcon: Icon(
          Symbols.search_rounded,
          color: AccountsTabTheme.subtitleInk(context),
          size: 22.0,
        ),
        suffixIcon: onClear != null
            ? IconButton(
                onPressed: onClear,
                icon: Icon(
                  Symbols.close_rounded,
                  color: AccountsTabTheme.subtitleInk(context),
                  size: 20.0,
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AccountsTabTheme.cardBorder(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: AccountsTabTheme.primary(context),
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AccountsTabTheme.cardBorder(context)),
        ),
      ),
    );
  }
}
