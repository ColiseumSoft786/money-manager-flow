import "package:cross_file/cross_file.dart";
import "package:dashed_border/dashed_border.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/import/import_page_theme.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class FileSelectArea extends StatefulWidget {
  final Function(XFile? file)? onFileDropped;
  final VoidCallback? onTap;

  const FileSelectArea({super.key, this.onFileDropped, this.onTap});

  @override
  State<FileSelectArea> createState() => _FileSelectAreaState();
}

class _FileSelectAreaState extends State<FileSelectArea> {
  bool _dragging = false;

  static final BorderRadius _borderRadius = BorderRadius.circular(
    ImportPageTheme.uploadRadius,
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool showDropText = isDesktop();

    return DropTarget(
      onDragDone: (detail) {
        widget.onFileDropped?.call(detail.files.firstOrNull);
      },
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AnimatedContainer(
              width: double.infinity,
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _dragging
                    ? ImportPageTheme.uploadFill.withValues(alpha: 0.85)
                    : ImportPageTheme.uploadFill,
                borderRadius: _borderRadius,
                border: DashedBorder(
                  color: ImportPageTheme.uploadDash,
                  width: 1.5,
                  borderRadius: _borderRadius,
                  dashLength: 6.0,
                  dashGap: 5.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(37, 99, 235, 0.06),
                    blurRadius: 12.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 28.0, 20.0, 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64.0,
                      height: 64.0,
                      decoration: BoxDecoration(
                        color: ImportPageTheme.uploadIconCircle(context),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ImportPageTheme.primary(context).withValues(
                              alpha: 0.28,
                            ),
                            blurRadius: 14.0,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Symbols.cloud_upload_rounded,
                        size: 32.0,
                        color: Colors.white,
                        fill: 0.0,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      showDropText
                          ? "sync.import.pickFile.pickOrDrop".t(context)
                          : "sync.import.pickFile".t(context),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17.0,
                        color: ImportPageTheme.titleInk,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      "sync.import.pickFile.formatsHint".t(context),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ImportPageTheme.subtitleInk,
                        fontSize: 13.0,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18.0),
                    Center(
                      child: SizedBox(
                        height: 44.0,
                        child: FilledButton(
                          onPressed: widget.onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: ImportPageTheme.primary(context),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            "sync.import.pickFile.browse".t(context),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.0,
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
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_dragging,
              child: AnimatedOpacity(
                opacity: _dragging ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: ImportPageTheme.primary(context).withValues(alpha: 0.92),
                    borderRadius: _borderRadius,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "sync.import.pickFile.dropzone.active".t(context),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
