import "package:flow/l10n/extensions.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/routes/transaction_page/transaction_entry_theme.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/extensions/quill_theme.dart";
import "package:flow/utils/flutter_quill/divider_embed_builder.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flutter/material.dart";
import "package:flutter_quill/flutter_quill.dart";
import "package:go_router/go_router.dart";
import "package:markdown/markdown.dart" as md;
import "package:markdown_quill/markdown_quill.dart";
import "package:material_symbols_icons/symbols.dart";

class EditMarkdownPageProps {
  final String? initialValue;
  final int? maxLength;

  /// Figma-style notes editor (transaction entry).
  final bool transactionEntryLayout;

  const EditMarkdownPageProps({
    this.initialValue,
    this.maxLength,
    this.transactionEntryLayout = false,
  });
}

class EditMarkdownPage extends StatefulWidget {
  final String? initialValue;
  final int? maxLength;
  final bool transactionEntryLayout;

  const EditMarkdownPage({
    super.key,
    this.initialValue,
    this.maxLength,
    this.transactionEntryLayout = false,
  });

  factory EditMarkdownPage.fromProps({required EditMarkdownPageProps props}) {
    return EditMarkdownPage(
      initialValue: props.initialValue,
      maxLength: props.maxLength,
      transactionEntryLayout: props.transactionEntryLayout,
    );
  }

  @override
  State<EditMarkdownPage> createState() => _EditMarkdownPageState();
}

class _EditMarkdownPageState extends State<EditMarkdownPage> {
  late final QuillController _controller;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
          onRichTextPaste: (delta, isExternal) async {
            return MarkdownToDelta(
              markdownDocument: md.Document(encodeHtml: false),
            ).convert(DeltaToMarkdown().convert(delta));
          },
          onImagePaste: (imageBytes) async {
            return null;
          },
          onGifPaste: (imageBytes) async {
            return null;
          },
        ),
      ),
    );

    final bool hasInitialValue =
        widget.initialValue != null && widget.initialValue!.trim().isNotEmpty;

    _controller.document = hasInitialValue
        ? Document.fromDelta(
            MarkdownToDelta(
              markdownDocument: md.Document(encodeHtml: false),
            ).convert(widget.initialValue!),
          )
        : Document();

    if (widget.transactionEntryLayout) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _editorFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transactionEntryLayout) {
      return _buildTransactionEntryScaffold(context);
    }

    return _buildLegacyScaffold(context);
  }

  Widget _buildTransactionEntryScaffold(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color divider = TransactionEntryTheme.cardBorder(context);
    final Color toolbarInk = TransactionEntryTheme.valueInk(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: TransactionEntryTheme.canvas(context),
        appBar: AppBar(
          leadingWidth: 40.0,
          leading: FormCloseButton(canPop: () => !hasChanged()),
          title: Text("transaction.notes.title".t(context)),
          centerTitle: true,
          backgroundColor: TransactionEntryTheme.appBarFill(context),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Divider(
              height: 1.0,
              thickness: 1.0,
              color: divider,
            ),
          ),
          titleTextStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: TransactionEntryTheme.valueInk(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Material(
                color: TransactionEntryTheme.saveActionFill(context),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: save,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Symbols.check_rounded,
                      color: Colors.white,
                      size: 22.0,
                      fill: 0.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.zero,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "transaction.notes.detailsLabel".t(context),
                      style: TransactionEntryTheme.sectionLabelStyle(
                        context,
                        theme,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    QuillEditor(
                      focusNode: _editorFocusNode,
                      scrollController: _editorScrollController,
                      controller: _controller,
                      config: QuillEditorConfig(
                        embedBuilders: [DividerEmbedBuilder()],
                        enableScribble: true,
                        customStyles: context.quillDefaultStyles,
                        placeholder: "transaction.notes.placeholder".t(
                          context,
                        ),
                        padding: EdgeInsets.zero,
                        expands: false,
                        autoFocus: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Material(
              color: TransactionEntryTheme.appBarFill(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: divider,
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 12.0),
                      child: Row(
                        children: [
                          _ToolbarFormatButton(
                            tooltip: "transaction.notes.format.bold".t(context),
                            child: Text(
                              "B",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: toolbarInk,
                              ),
                            ),
                            onPressed: () => _toggleFormat(Attribute.bold),
                          ),
                          _ToolbarFormatButton(
                            tooltip: "transaction.notes.format.italic".t(context),
                            child: Text(
                              "I",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w700,
                                color: toolbarInk,
                              ),
                            ),
                            onPressed: () => _toggleFormat(Attribute.italic),
                          ),
                          _ToolbarFormatButton(
                            tooltip:
                                "transaction.notes.format.bulletedList".t(context),
                            icon: Symbols.format_list_bulleted_rounded,
                            onPressed: () =>
                                _toggleFormat(Attribute.ul),
                          ),
                          _ToolbarFormatButton(
                            tooltip:
                                "transaction.notes.format.numberedList".t(context),
                            icon: Symbols.format_list_numbered_rounded,
                            onPressed: () =>
                                _toggleFormat(Attribute.ol),
                          ),
                          _ToolbarFormatButton(
                            tooltip: "transaction.notes.format.quote".t(context),
                            icon: Symbols.format_quote_rounded,
                            onPressed: () =>
                                _toggleFormat(Attribute.blockQuote),
                          ),
                          const Spacer(),
                          Button(
                            onTap: save,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                            backgroundColor:
                                TransactionEntryTheme.saveActionFill(context),
                            foregroundColor: Colors.white,
                            iconColor: Colors.white,
                            leading: const Icon(
                              Symbols.save_rounded,
                              size: 20.0,
                              fill: 0.0,
                            ),
                            child: Text(
                              "general.save".t(context),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacyScaffold(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 40.0,
          leading: FormCloseButton(canPop: () => !hasChanged()),
          actions: [
            IconButton(
              onPressed: save,
              icon: const Icon(Symbols.check_rounded),
              tooltip: "general.save".t(context),
            ),
          ],
          centerTitle: true,
          backgroundColor: context.colorScheme.surface,
        ),
        body: SafeArea(
          child: Column(
            children: [
              QuillSimpleToolbar(
                controller: _controller,
                config: _defaultQuillToolbarConfig,
              ),
              Expanded(
                child: Frame.standalone(
                  child: QuillEditor(
                    focusNode: _editorFocusNode,
                    scrollController: _editorScrollController,
                    controller: _controller,
                    config: QuillEditorConfig(
                      embedBuilders: [DividerEmbedBuilder()],
                      enableScribble: true,
                      customStyles: context.quillDefaultStyles,
                      placeholder: "transaction.description.placeholder".t(
                        context,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFormat(Attribute attribute) {
    final Style style = _controller.getSelectionStyle();
    final bool isActive = style.attributes.containsKey(attribute.key);
    _controller.formatSelection(
      isActive ? Attribute.clone(attribute, null) : attribute,
    );
  }

  Future<void> save() async {
    final markdown = DeltaToMarkdown().convert(_controller.document.toDelta());
    context.pop<String>(markdown);
  }

  bool hasChanged() {
    try {
      final String currentMarkdown = DeltaToMarkdown()
          .convert(_controller.document.toDelta())
          .trim();

      if ((widget.initialValue?.trim() ?? "").isEmpty &&
          currentMarkdown.isEmpty) {
        return false;
      }

      final String initialMarkdown = DeltaToMarkdown()
          .convert(
            MarkdownToDelta(
              markdownDocument: md.Document(encodeHtml: false),
            ).convert(widget.initialValue?.trim() ?? ""),
          )
          .trim();

      return currentMarkdown != initialMarkdown;
    } catch (e) {
      return false;
    }
  }
}

class _ToolbarFormatButton extends StatelessWidget {
  final String tooltip;
  final Widget? child;
  final IconData? icon;
  final VoidCallback onPressed;

  const _ToolbarFormatButton({
    required this.tooltip,
    required this.onPressed,
    this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: child ??
          Icon(
            icon!,
            size: 22.0,
            color: TransactionEntryTheme.valueInk(context),
            fill: 0.0,
          ),
    );
  }
}

const QuillSimpleToolbarConfig _defaultQuillToolbarConfig =
    QuillSimpleToolbarConfig(
      multiRowsDisplay: true,
      showDividers: true,
      showFontFamily: false,
      showFontSize: false,
      showBoldButton: true,
      showItalicButton: true,
      showSmallButton: false,
      showUnderLineButton: true,
      showLineHeightButton: false,
      showStrikeThrough: true,
      showInlineCode: true,
      showColorButton: false,
      showBackgroundColorButton: false,
      showClearFormat: true,
      showAlignmentButtons: false,
      showLeftAlignment: false,
      showCenterAlignment: false,
      showRightAlignment: false,
      showJustifyAlignment: false,
      showHeaderStyle: true,
      showListNumbers: true,
      showListBullets: true,
      showListCheck: true,
      showCodeBlock: true,
      showQuote: true,
      showIndent: false,
      showLink: true,
      showUndo: true,
      showRedo: true,
      showDirection: false,
      showSearchButton: true,
      showSubscript: false,
      showSuperscript: false,
      showClipboardCut: false,
      showClipboardCopy: false,
      showClipboardPaste: false,
      linkStyleType: LinkStyleType.original,
      headerStyleType: HeaderStyleType.original,
    );
