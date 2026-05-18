import "package:flow/entity/transaction.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/routes/transaction_page/transaction_entry_theme.dart";
import "package:flow/theme/theme.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";

class TitleInput extends StatefulWidget {
  final FocusNode focusNode;
  final TextEditingController controller;

  final int? selectedAccountId;
  final int? selectedCategoryId;
  final TransactionType transactionType;

  final double? amount;
  final String? currency;
  final DateTime? transactionDate;

  final String fallbackTitle;

  final Function(String) onSubmitted;

  /// When true, renders without [Frame] for use inside [TransactionEntryAmountCard].
  final bool embedded;

  const TitleInput({
    super.key,
    required this.focusNode,
    required this.controller,
    this.selectedAccountId,
    this.selectedCategoryId,
    this.amount,
    this.currency,
    this.transactionDate,
    required this.transactionType,
    required this.fallbackTitle,
    required this.onSubmitted,
    this.embedded = false,
  });

  @override
  State<TitleInput> createState() => _TitleInputState();
}

class _TitleInputState extends State<TitleInput> {
  static const Duration _debounceDuration = Duration(milliseconds: 280);

  Future<Iterable<RelevanceScoredTitle>> _optionsBuilder(
    TextEditingValue value,
  ) => _debouncedSearch(value.text);

  Future<Iterable<RelevanceScoredTitle>> _debouncedSearch(String query) async {
    if (query.trim().isEmpty) {
      return const [];
    }

    await Future<void>.delayed(_debounceDuration);

    if (!mounted || widget.controller.text != query) {
      return const [];
    }

    return _fetchOptions(query);
  }

  Future<List<RelevanceScoredTitle>> _fetchOptions(String query) =>
      ObjectBox()
          .transactionTitleSuggestions(
            currentInput: query,
            accountId: widget.selectedAccountId,
            categoryId: widget.selectedCategoryId,
            type: widget.transactionType,
            amount: widget.amount,
            currency: widget.currency,
            transactionDate: widget.transactionDate,
            limit: 5,
          )
          .then(
            (results) => results
                .where(
                  (item) => item.title != "transaction.fallbackTitle".tr(),
                )
                .toList(),
          );

  @override
  Widget build(BuildContext context) {
    final Widget field = Autocomplete<RelevanceScoredTitle>(
      focusNode: widget.focusNode,
      textEditingController: widget.controller,
      optionsBuilder: _optionsBuilder,
      displayStringForOption: (option) => option.title,
      onSelected: (option) {
        widget.controller.text = option.title;
      },
      optionsViewBuilder: (context, onSelected, options) {
        if (options.isEmpty) {
          return const SizedBox.shrink();
        }

        return Material(
          elevation: 4.0,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(8.0),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200.0),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8.0),
              ),
              border: Border.all(color: context.flowColors.semi),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final RelevanceScoredTitle item = options.elementAt(index);
                return ListTile(
                  dense: true,
                  title: Text(item.title),
                  onTap: () => onSelected(item),
                );
              },
            ),
          ),
        );
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) =>
              TextField(
                controller: widget.controller,
                focusNode: focusNode,
                style: widget.embedded
                    ? context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TransactionEntryTheme.valueInk,
                      )
                    : context.textTheme.headlineMedium,
                textAlign:
                    widget.embedded ? TextAlign.start : TextAlign.center,
                maxLength: Transaction.maxTitleLength,
                onSubmitted: widget.onSubmitted,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: widget.fallbackTitle,
                  hintStyle: widget.embedded
                      ? context.textTheme.titleMedium?.copyWith(
                          color: TransactionEntryTheme.placeholderInk,
                          fontWeight: FontWeight.w500,
                        )
                      : context.textTheme.headlineMedium?.copyWith(
                          color: context.textTheme.headlineMedium?.color
                              ?.withAlpha(0x80),
                        ),
                  border: widget.embedded
                      ? InputBorder.none
                      : const UnderlineInputBorder(),
                  enabledBorder: widget.embedded
                      ? InputBorder.none
                      : const UnderlineInputBorder(),
                  focusedBorder: widget.embedded
                      ? InputBorder.none
                      : const UnderlineInputBorder(),
                  counter: const SizedBox.shrink(),
                  isDense: widget.embedded,
                  contentPadding: widget.embedded
                      ? const EdgeInsets.symmetric(vertical: 8.0)
                      : null,
                ),
              ),
    );

    return widget.embedded ? field : Frame(child: field);
  }
}
