import "package:flow/routes/preferences/transaction_geo/transaction_geo_preferences_theme.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class GeoMapPreviewCard extends StatelessWidget {
  const GeoMapPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        TransactionGeoPreferencesTheme.mapRadius,
      ),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _StylizedMapBackground(),
            const Align(
              alignment: Alignment(0.0, -0.1),
              child: Icon(
                Symbols.location_on_rounded,
                size: 40.0,
                color: TransactionGeoPreferencesTheme.mapPin,
                fill: 1.0,
              ),
            ),
            Positioned(
              right: 12.0,
              bottom: 12.0,
              child: Material(
                color: TransactionGeoPreferencesTheme.cardFill,
                elevation: 2,
                shadowColor: Colors.black26,
                shape: const CircleBorder(),
                child: SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: Icon(
                    Symbols.my_location_rounded,
                    size: 22.0,
                    color: TransactionGeoPreferencesTheme.primary(context),
                    fill: 0.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StylizedMapBackground extends StatelessWidget {
  const _StylizedMapBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint base = Paint()
      ..color = TransactionGeoPreferencesTheme.mapRoadFill;
    canvas.drawRect(Offset.zero & size, base);

    void block(Rect rect, Color color) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6.0)),
        Paint()..color = color,
      );
    }

    block(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.12, size.width * 0.42, size.height * 0.35),
      TransactionGeoPreferencesTheme.mapParkFill,
    );
    block(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.08, size.width * 0.38, size.height * 0.28),
      TransactionGeoPreferencesTheme.mapBlockFill,
    );
    block(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.55, size.width * 0.35, size.height * 0.32),
      TransactionGeoPreferencesTheme.mapBlockFill,
    );
    block(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.48, size.width * 0.42, size.height * 0.38),
      TransactionGeoPreferencesTheme.mapParkFill.withValues(alpha: 0.75),
    );

    final Paint road = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.85, size.height * 0.45),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.1),
      Offset(size.width * 0.5, size.height * 0.9),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
