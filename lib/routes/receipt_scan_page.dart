import "dart:io";

import "package:camera/camera.dart";
import "package:flow/data/reciept_scan.dart";
import "package:flow/data/transaction_programmable_object.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/transaction_page.dart";
import "package:flow/services/camera.dart";
import "package:flow/services/reciept_scan_service.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/utils/extensions/directionality.dart";
import "package:flow/utils/extensions/toast.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/camera_page_base.dart";
import "package:flow/widgets/camera_page_base/overlay_button.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/rtl_flipper.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flow/widgets/image_drop_zone.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:toastification/toastification.dart";

class ReceiptScanPage extends StatefulWidget {
  const ReceiptScanPage({super.key});

  @override
  State<ReceiptScanPage> createState() => _ReceiptScanPageState();
}

class _ReceiptScanPageState extends State<ReceiptScanPage> {
  final GlobalKey<CameraPageBaseState> _cameraPageKey =
      GlobalKey<CameraPageBaseState>();

  bool _busy = false;
  bool _flashBusy = false;
  bool _lensChangeBusy = false;
  XFile? _takenPicture;

  bool get isCameraSupported => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    CameraService.ensureInitialized().then((_) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final IconData flashIcon = switch (_cameraPageKey.currentState?.flashMode) {
      FlashMode.auto => Symbols.flash_auto_rounded,
      FlashMode.always => Symbols.flash_on_rounded,
      FlashMode.torch => Symbols.flashlight_on_rounded,
      _ => Symbols.flash_off_rounded,
    };

    final List<Widget> topButtons = [
      OverlayButton(
        child: _takenPicture == null
            ? const RTLFlipper(child: Icon(Symbols.chevron_left_rounded))
            : const Icon(Symbols.close_rounded),
        onTap: () {
          if (_takenPicture != null) {
            setState(() => _takenPicture = null);
          } else if (context.canPop()) {
            context.pop();
          }
        },
      ),
      if (isCameraSupported && CameraService.cameras?.isNotEmpty == true)
        OverlayButton(
          child: Icon(flashIcon),
          onTap: () async {
            if (_flashBusy) return;
            setState(() => _flashBusy = true);
            try {
              await _cameraPageKey.currentState?.rotateFlashMode();
            } finally {
              _flashBusy = false;
              if (mounted) setState(() {});
            }
          },
        ),
    ];

    return CameraPageBase(
      key: _cameraPageKey,
      unsupportedWidget: Positioned.fill(
        child: SafeArea(
          child: ImageDropZone(
            onFileDropped: (file) {
              if (file?.mimeType?.startsWith("image") == true) {
                setState(() => _takenPicture = file);
              }
            },
            onTap: _pickFromGallery,
          ),
        ),
      ),
      children: [
        if (_takenPicture != null)
          Positioned.fill(
            child: Image.file(File(_takenPicture!.path), fit: BoxFit.cover),
          ),
        Positioned(
          top: 20.0,
          left: 20.0,
          right: 20.0,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  spacing: 12.0,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: context.isRtl
                      ? topButtons.reversed.toList()
                      : topButtons,
                ),
                if (_takenPicture == null) ...[
                  const SizedBox(height: 12.0),
                  Text(
                    "receiptScan.title".t(context),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      shadows: const [
                        Shadow(
                          color: Color.fromRGBO(0, 0, 0, 0.45),
                          blurRadius: 8.0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "receiptScan.hint".t(context),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      shadows: const [
                        Shadow(
                          color: Color.fromRGBO(0, 0, 0, 0.45),
                          blurRadius: 8.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20.0,
          left: 20.0,
          right: 20.0,
          child: SafeArea(child: _buildBottomButtons(context)),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    if (_takenPicture != null) {
      return Column(
        spacing: 16.0,
        mainAxisSize: MainAxisSize.min,
        children: [
          OverlayButton(
            child: Icon(
              Symbols.delete_forever_rounded,
              color: context.colorScheme.error,
            ),
            onTap: () => setState(() => _takenPicture = null),
          ),
          Button(
            trailing: _busy
                ? const SizedBox.square(dimension: 24.0, child: Spinner())
                : const Icon(Symbols.document_scanner_rounded),
            onTap: _busy ? null : _fillTransactionForm,
            child: Text("receiptScan.fillForm".t(context)),
          ),
        ],
      );
    }

    final List<Widget> buttons = [
      if ((CameraService.cameras?.length ?? 0) > 1)
        OverlayButton(
          onTap: () async {
            if (_lensChangeBusy) return;
            setState(() => _lensChangeBusy = true);
            try {
              await _cameraPageKey.currentState?.rotateCamera();
            } finally {
              _lensChangeBusy = false;
              if (mounted) setState(() {});
            }
          },
          child: const Icon(Symbols.switch_camera_rounded),
        )
      else
        Opacity(
          opacity: 0,
          child: IgnorePointer(
            child: OverlayButton(
              onTap: () {},
              child: Icon(Icons.switch_camera_rounded),
            ),
          ),
        ),
      if (isCameraSupported && CameraService.cameras?.isNotEmpty == true)
        OverlayButton(
          onTap: _busy ? null : _takePicture,
          child: SizedBox.square(
            dimension: 24.0,
            child: _busy
                ? const Spinner.center()
                : const Icon(Symbols.photo_camera_rounded),
          ),
        ),
      OverlayButton(
        onTap: _pickFromGallery,
        child: const Icon(Symbols.photo_library_rounded),
      ),
    ];

    return Row(
      spacing: 12.0,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: context.isRtl ? buttons.reversed.toList() : buttons,
    );
  }

  Future<void> _pickFromGallery() async {
    final XFile? file = await pickImage();
    if (file == null || !mounted) return;
    setState(() => _takenPicture = file);
  }

  Future<void> _takePicture() async {
    if (_busy || _cameraPageKey.currentState?.controller == null) return;

    setState(() {
      _takenPicture = null;
      _busy = true;
    });

    try {
      final XFile? picture =
          await _cameraPageKey.currentState?.controller?.takePicture();
      _takenPicture = picture;
    } finally {
      _busy = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _fillTransactionForm() async {
    if (_takenPicture == null) return;

    setState(() => _busy = true);
    try {
      final result =
          await ReceiptScanService().scanImageFile(File(_takenPicture!.path));

      if (!mounted) return;

      if (result == null || !result.hasMinimumData) {
        context.showToast(
          text: "receiptScan.failed".t(context),
          type: ToastificationType.warning,
        );
        if (result?.rawText != null && result!.rawText!.trim().isNotEmpty) {
          context.showToast(
            text: result.rawText!.trim().split(RegExp(r"\r?\n")).take(2).join(" • "),
            type: ToastificationType.info,
          );
        }
        return;
      }

      final TransactionProgrammableObject? params =
          receiptScanToTransactionParams(result);
      if (params == null) return;

      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => TransactionPage.create(params: params),
        ),
      );

      if (mounted && context.canPop()) {
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
