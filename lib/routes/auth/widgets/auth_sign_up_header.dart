import "package:flow/l10n/extensions.dart";
import "package:flow/theme/auth_screen_colors.dart";
import "package:flutter/material.dart";

/// Blue rounded header for Create Account (signup mock).
class AuthSignUpHeader extends StatelessWidget {
  const AuthSignUpHeader({super.key});

  static const double height = 240.0;
  static const String _logoAsset = "assets/images/walletIcon.png";

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final AuthScreenColors colors = AuthScreenColors.of(context);

    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AuthScreenColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.0),
          bottomRight: Radius.circular(28.0),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _AuthSignUpHeaderPatternPainter(colors.headerPattern),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.signUpLogoPlate,
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 10.0,
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
                          color: Colors.white,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    "appName".t(context),
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 26.0,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      "auth.signUp.slogan".t(context),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 14.0,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthSignUpHeaderPatternPainter extends CustomPainter {
  const _AuthSignUpHeaderPatternPainter(this.patternColor);

  final Color patternColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 5; i++) {
      final Path wave = Path();
      final double y = 32.0 + i * 32.0;
      wave.moveTo(-20.0, y);
      for (double x = 0; x <= size.width + 40; x += 40) {
        wave.quadraticBezierTo(x + 20, y - 10, x + 40, y);
      }
      canvas.drawPath(wave, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
