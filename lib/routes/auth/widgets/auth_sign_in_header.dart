import "package:flow/l10n/extensions.dart";
import "package:flow/theme/auth_screen_colors.dart";
import "package:flutter/material.dart";

/// Blue wave header with CashPilot branding (sign-in mock).
class AuthSignInHeader extends StatelessWidget {
  const AuthSignInHeader({super.key});

  static const double height = 220.0;
  static const String _logoAsset = "assets/images/walletIcon.png";

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _AuthSignInWaveClipper(),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AuthScreenColors.primary,
              ),
            ),
            CustomPaint(
              painter: _AuthHeaderPatternPainter(
                AuthScreenColors.of(context).headerPattern,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 12.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 52.0,
                        height: 52.0,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            _logoAsset,
                            fit: BoxFit.contain,
                            color: AuthScreenColors.primary,
                            colorBlendMode: BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      "appName".t(context),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 26.0,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthSignInWaveClipper extends CustomClipper<Path> {
  const _AuthSignInWaveClipper();

  @override
  Path getClip(Size size) {
    final Path path = Path()..lineTo(0, 0);
    path.lineTo(0, size.height - 36.0);
    path.quadraticBezierTo(
      size.width * 0.22,
      size.height + 8.0,
      size.width * 0.5,
      size.height - 28.0,
    );
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height - 56.0,
      size.width,
      size.height - 24.0,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _AuthHeaderPatternPainter extends CustomPainter {
  const _AuthHeaderPatternPainter(this.patternColor);

  final Color patternColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 6; i++) {
      final Path wave = Path();
      final double y = 24.0 + i * 28.0;
      wave.moveTo(-20.0, y);
      for (double x = 0; x <= size.width + 40; x += 40) {
        wave.quadraticBezierTo(x + 20, y - 12, x + 40, y);
      }
      canvas.drawPath(wave, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
