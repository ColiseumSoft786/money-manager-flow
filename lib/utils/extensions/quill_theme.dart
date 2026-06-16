import "dart:io";

import "package:flow/theme/helpers.dart";
import "package:flutter/material.dart";
import "package:flutter_quill/flutter_quill.dart";

extension QuillFlowTheme on BuildContext {
  TextStyle get quillInlineCodeStyle => textTheme.bodyMedium!.copyWith(
    fontFamily: (Platform.isIOS || Platform.isMacOS) ? "Menlo" : "Roboto Mono",
    fontFamilyFallback: [
      "Ubuntu Mono",
      "Courier New",
      "Courier",
      "Lucida Console",
      "Consolas",
      "monospace",
    ],
  );

  DefaultTextBlockStyle _quillBlock(TextStyle style) => DefaultTextBlockStyle(
    style,
    const HorizontalSpacing(0.0, 0.0),
    const VerticalSpacing(8.0, 0.0),
    const VerticalSpacing(0.0, 0.0),
    null,
  );

  DefaultStyles get quillDefaultStyles {
    final TextStyle body = textTheme.bodyLarge!.copyWith(
      color: colorScheme.onSurface,
    );

    return DefaultStyles(
      paragraph: _quillBlock(body),
      placeHolder: DefaultTextBlockStyle(
        body.copyWith(color: colorScheme.onSurfaceVariant),
        const HorizontalSpacing(0.0, 0.0),
        const VerticalSpacing(0.0, 0.0),
        const VerticalSpacing(0.0, 0.0),
        null,
      ),
    quote: DefaultTextBlockStyle(
      textTheme.bodyLarge!.copyWith(
        fontStyle: FontStyle.italic,
        color: colorScheme.onSurfaceVariant,
      ),
      HorizontalSpacing(0.0, 0.0),
      VerticalSpacing(8.0, 8.0),
      VerticalSpacing(0.0, 0.0),
      BoxDecoration(
        border: Border(
          left: BorderSide(color: colorScheme.primary, width: 4.0),
        ),
        color: colorScheme.primary.withAlpha(0x15),
      ),
    ),
    link: textTheme.bodyLarge?.copyWith(color: colorScheme.primary),
    code: DefaultTextBlockStyle(
      quillInlineCodeStyle.copyWith(color: colorScheme.primary),
      HorizontalSpacing(0.0, 0.0),
      VerticalSpacing(8.0, 8.0),
      VerticalSpacing(0.0, 0.0),
      BoxDecoration(color: colorScheme.primary.withAlpha(0x15)),
    ),
    inlineCode: InlineCodeStyle(
      style: quillInlineCodeStyle,
      backgroundColor: colorScheme.primary.withAlpha(0x15),
    ),
    );
  }
}
