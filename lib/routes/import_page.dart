import "dart:io";

import "package:cross_file/cross_file.dart";
import "package:flow/constants.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/import/import_page_theme.dart";
import "package:flow/sync/import.dart";
import "package:flow/sync/import/base.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/utils/extensions/importer.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/import/file_select_area.dart";
import "package:flow/widgets/import/import_option_card.dart";
import "package:flow/widgets/import/import_privacy_banner.dart";
import "package:flow/widgets/import/import_section_header.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:material_symbols_icons/symbols.dart";

final Logger _log = Logger("ImportPage");

class ImportPage extends StatefulWidget {
  final bool? setupMode;

  const ImportPage({this.setupMode = false, super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  Importer? importer;

  bool busy = false;

  dynamic error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ImportPageTheme.canvas,
      appBar: AppBar(
        backgroundColor: ImportPageTheme.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "sync.import".t(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: ImportPageTheme.titleInk,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: kFlowAccountRowDividerLight,
          ),
        ),
      ),
      body: SafeArea(
        child: busy
            ? const Spinner.center()
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.34,
                      child: Center(
                        child: FileSelectArea(
                          onFileDropped: initiateImportFromDroppedFile,
                          onTap: initiateImport,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ImportSectionHeader(
                            label: "sync.import.other".t(context),
                          ),
                          ImportOptionCard(
                            leading: ImportOptionIconPlate(
                              fill: ImportPageTheme.ivyPlate,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: Image.asset(
                                  "assets/images/external/ivy_wallet.png",
                                  width: 28.0,
                                  height: 28.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: "sync.import.ivyWallet.title".t(context),
                            subtitle: "sync.import.ivyWallet.subtitle".t(
                              context,
                            ),
                            onTap: () => initiateImport(
                              externalFormat: ImportExternalFormat.ivyWallet,
                            ),
                          ),
                          ImportOptionCard(
                            leading: ImportOptionIconPlate(
                              fill: ImportPageTheme.templatePlate,
                              child: Icon(
                                Symbols.download_rounded,
                                size: 24.0,
                                color: ImportPageTheme.templateIcon(context),
                                fill: 0.0,
                              ),
                            ),
                            title: "sync.import.getCSVTemplate".t(context),
                            subtitle: "sync.import.getCSVTemplate.subtitle".t(
                              context,
                            ),
                            onTap: () => openUrl(csvImportTemplateUrl),
                          ),
                          const SizedBox(height: 16.0),
                          const ImportPrivacyBanner(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> initiateImport({
    File? backupFile,
    ImportExternalFormat? externalFormat,
  }) async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      importer = await importBackup(
        backupFile: backupFile,
        externalFormat: externalFormat,
      );

      if (mounted) {
        if (importer == null) {
          context.showErrorToast(error: "error.input.noFilePicked".t(context));
        } else {
          importer!.goToRelevantPage(
            context,
            setupMode: widget.setupMode ?? false,
          );
        }
      }
    } catch (e, stackTrace) {
      _log.severe("Importer error", e, stackTrace);
      if (mounted) {
        context.showErrorToast(error: e);
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> initiateImportFromDroppedFile(XFile? file) async {
    if (file == null) {
      context.showErrorToast(error: "error.input.noFilePicked".t(context));
      return;
    }

    _log.fine("Trying to import from dragged file: ${file.path}");

    final backupFile = File(file.path);

    if (!(await backupFile.exists())) {
      if (mounted) {
        context.showErrorToast(error: "error.input.noFilePicked".t(context));
      }
      return;
    }

    return initiateImport(backupFile: backupFile);
  }
}
