import "dart:io";

import "package:cross_file/cross_file.dart";
import "package:flow/entity/file_attachment.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/transaction_page/transaction_entry_theme.dart";
import "package:flow/routes/transaction_page/widgets/transaction_entry_card.dart";
import "package:flow/utils/extensions/file_attachment.dart";
import "package:flow/utils/pick_file.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:material_symbols_icons/symbols.dart";

class TransactionEntryAttachmentsSection extends StatelessWidget {
  final List<FileAttachment>? attachments;
  final VoidCallback onPickFiles;
  final void Function(List<XFile> files)? onAddFiles;
  final ValueChanged<FileAttachment> onRemove;

  const TransactionEntryAttachmentsSection({
    super.key,
    this.attachments,
    required this.onPickFiles,
    this.onAddFiles,
    required this.onRemove,
  });

  bool get _hasAttachments => attachments?.isNotEmpty == true;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return TransactionEntryCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPickFiles,
              borderRadius: BorderRadius.circular(
                TransactionEntryTheme.cardRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: TransactionEntryTheme.iconPlateSize,
                      height: TransactionEntryTheme.iconPlateSize,
                      decoration: BoxDecoration(
                        color: TransactionEntryTheme.iconPlateFill(context),
                        borderRadius: BorderRadius.circular(
                          TransactionEntryTheme.iconPlateRadius,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Symbols.attach_file_rounded,
                        size: 22.0,
                        color: TransactionEntryTheme.iconPlateInk(context),
                        fill: 0.0,
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Text(
                        "fileAttachment.add".t(context),
                        style: TransactionEntryTheme.rowTitleStyle(context, theme),
                      ),
                    ),
                    Text(
                      "transaction.attachments.hint".t(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: TransactionEntryTheme.placeholderInk(context),
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_hasAttachments) ...[
            Divider(
              height: 1.0,
              thickness: 1.0,
              indent: 16.0,
              endIndent: 16.0,
              color: TransactionEntryTheme.rowDivider(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 16.0),
              child: SizedBox(
                height: 100.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (Platform.isIOS || Platform.isAndroid)
                      _AttachmentTile(
                        label: "fileAttachment.takePhoto".t(context),
                        icon: Symbols.photo_camera_rounded,
                        dashed: true,
                        onTap: () => _takePhoto(context),
                      ),
                    ...attachments!.map(
                      (file) => _AttachmentPreview(
                        file: file,
                        onRemove: () => onRemove(file),
                      ),
                    ),
                    _AttachmentTile(
                      label: "fileAttachment.file".t(context),
                      icon: Symbols.folder_open_rounded,
                      filled: true,
                      onTap: onPickFiles,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _takePhoto(BuildContext context) async {
    final XFile? file = await pickImage(source: ImageSource.camera);
    if (file == null) return;
    onAddFiles?.call([file]);
  }
}

class _AttachmentTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool dashed;
  final bool filled;

  const _AttachmentTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.dashed = false,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.0),
          child: Ink(
            width: 84.0,
            height: double.infinity,
            decoration: BoxDecoration(
              color: filled
                  ? TransactionEntryTheme.attachmentTileFill(context)
                  : TransactionEntryTheme.canvas(context),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: dashed
                    ? TransactionEntryTheme.attachmentDashedBorder(context)
                    : TransactionEntryTheme.cardBorder(context),
                width: dashed ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 26.0,
                  color: TransactionEntryTheme.iconPlateInk(context),
                  fill: 0.0,
                ),
                const SizedBox(height: 6.0),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: TransactionEntryTheme.valueInk(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 11.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final FileAttachment file;
  final VoidCallback onRemove;

  const _AttachmentPreview({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final bool isImage = file.canPreviewAsImage;

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.0),
            child: SizedBox(
              width: 84.0,
              height: 100.0,
              child: isImage
                  ? Image.file(
                      file.file,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      cacheWidth: 168,
                    )
                  : ColoredBox(
                      color: TransactionEntryTheme.attachmentTileFill(context),
                      child: Icon(
                        Symbols.insert_drive_file_rounded,
                        color: TransactionEntryTheme.iconPlateInk(context),
                        size: 28.0,
                      ),
                    ),
            ),
          ),
          Positioned(
            top: -5.0,
            right: -5.0,
            child: Material(
              color: TransactionEntryTheme.canvas(context),
              shape: const CircleBorder(),
              elevation: 1.0,
              shadowColor: Colors.black26,
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TransactionEntryTheme.cardBorder(context),
                    ),
                  ),
                  child: Icon(
                    Symbols.close_rounded,
                    size: 16.0,
                    color: TransactionEntryTheme.valueInk(context),
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
