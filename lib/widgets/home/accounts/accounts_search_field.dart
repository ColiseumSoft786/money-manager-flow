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
        color: AccountsTabTheme.titleInk,
        fontSize: 15.0,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AccountsTabTheme.subtitleInk),
        filled: true,
        fillColor: AccountsTabTheme.cardFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 12.0,
        ),
        prefixIcon: const Icon(
          Symbols.search_rounded,
          color: AccountsTabTheme.subtitleInk,
          size: 22.0,
        ),
        suffixIcon: onClear != null
            ? IconButton(
                onPressed: onClear,
                icon: const Icon(
                  Symbols.close_rounded,
                  color: AccountsTabTheme.subtitleInk,
                  size: 20.0,
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AccountsTabTheme.cardBorder),
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
          borderSide: const BorderSide(color: AccountsTabTheme.cardBorder),
        ),
      ),
    );
  }
}
