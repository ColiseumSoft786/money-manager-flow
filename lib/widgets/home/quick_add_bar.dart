import "package:flow/data/quickAddParse.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/quick_add_service.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/home/dashboard/glass_panel.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class QuickAddBar extends StatefulWidget {
  const QuickAddBar({super.key});

  @override
  State<QuickAddBar> createState() => _QuickAddBarState();
}

class _QuickAddBarState extends State<QuickAddBar> {
  final TextEditingController _controller = TextEditingController();
  QuickaddparseResult? preview;

  static const double _barHeight = 48.0;
  static const double _submitButtonSize = 40.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onChanged(String value) {
    setState(() {
      preview = value.trim().isEmpty
          ? null
          : QuickAddService.instance.preview(value);
    });
  }

  Future<void> submit() async {
    final String raw = _controller.text.trim();
    if (raw.isEmpty) return;
    try {
      QuickAddService.instance.submit(raw);
      _controller.clear();
      setState(() => preview = null);
      if (mounted) {
        context.showToast(text: "quickAdd.success".t(context));
      }
    } on QuickAddException {
      if (mounted) {
        context.showErrorToast(error: "quickAdd.parseFailed".t(context));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final bool hasText = _controller.text.trim().isNotEmpty;
    final Color accent = GlassPanel.accentInk(context);
    final TextStyle fieldStyle = context.textTheme.bodyLarge!.copyWith(
      color: scheme.onSurface,
      fontSize: 15.0,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          borderRadius: const BorderRadius.all(Radius.circular(28.0)),
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
            height: _barHeight,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12.0),
                  child: Icon(
                    Symbols.bolt_rounded,
                    color: accent,
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: onChanged,
                    onSubmitted: (_) => submit(),
                    textInputAction: TextInputAction.done,
                    style: fieldStyle,
                    cursorColor: scheme.primary,
                    decoration: InputDecoration(
                      hintText: "quickAdd.hint".t(context),
                      filled: true,
                      fillColor: Colors.transparent,
                      hintStyle: fieldStyle.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
                Material(
                  color: hasText
                      ? accent
                      : accent.withValues(alpha: 0.4),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: submit,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: _submitButtonSize,
                      height: _submitButtonSize,
                      child: Icon(
                        Symbols.north_east_rounded,
                        color: scheme.onPrimary,
                        size: 20.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (preview != null && preview!.isValid) ...[
          const SizedBox(height: 8.0),
          GlassPanel(
            borderRadius: const BorderRadius.all(Radius.circular(14.0)),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            tint: scheme.primary,
            child: Text(
              previewLine(context, preview!),
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String previewLine(BuildContext context, QuickaddparseResult result) {
    final String typeLabel =
        "enum.TransactionType@${result.type.name}".t(context);
    final String dateLabel = Moment(result.transactionDate).format("MMM D");
    final String categoryLabel =
        result.category?.name ?? "quickAdd.noCategory".t(context);

    return "${result.amount} · $typeLabel · $categoryLabel · $dateLabel · ${result.title}";
  }
}
