import "package:flow/l10n/extensions.dart";
import "package:flow/theme/auth_screen_colors.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// CashPilot auth entry — layout matches marketing welcome mock.
class AuthWelcomePage extends StatelessWidget {
  const AuthWelcomePage({super.key});

  static const String _heroAsset = "assets/images/Capture.JPG";
  static const String _logoAsset = "assets/images/walletIcon.png";

  static const double _horizontalPadding = 28.0;
  static const double _logoBoxSize = 56.0;
  static const double _logoRadius = 16.0;
  static const double _heroRadius = 28.0;
  static const double _pillRadius = 999.0;

  @override
  Widget build(BuildContext context) {
    final AuthScreenColors colors = AuthScreenColors.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20.0),
                    _LogoHeader(textTheme: textTheme, colors: colors),
                    const SizedBox(height: 24.0),
                    const _HeroImage(),
                    const SizedBox(height: 28.0),
                    Text(
                      "auth.welcome.headline".t(context),
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 26.0,
                        height: 1.2,
                        color: colors.headline,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      "auth.welcome.subheadline".t(context),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.0,
                        height: 1.35,
                        color: colors.subtitle,
                      ),
                    ),
                    const SizedBox(height: 28.0),
                    Button(
                      fullWidth: true,
                      onTap: () => context.push("/auth/sign-up"),
                      backgroundColor: AuthScreenColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 6.0,
                      shadowColor: AuthScreenColors.primaryButtonShadow,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(_pillRadius),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 20.0,
                      ),
                      trailing: const Icon(
                        Symbols.arrow_forward_rounded,
                        size: 22.0,
                        color: Colors.white,
                      ),
                      child: Text(
                        "auth.welcome.signUp".t(context),
                        style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_pillRadius),
                        border: Border.all(
                          color: colors.secondaryButtonBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Button(
                        fullWidth: true,
                        onTap: () => context.push("/auth/sign-in"),
                        backgroundColor: colors.secondaryButtonFill,
                        foregroundColor: colors.secondaryButtonForeground,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(_pillRadius),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 20.0,
                        ),
                        child: Text(
                          "auth.welcome.signIn".t(context),
                          style: const TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader({required this.textTheme, required this.colors});

  final TextTheme textTheme;
  final AuthScreenColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AuthScreenColors.primary,
            borderRadius: BorderRadius.circular(AuthWelcomePage._logoRadius),
            boxShadow: const [
              BoxShadow(
                color: AuthScreenColors.logoShadow,
                blurRadius: 16.0,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            width: AuthWelcomePage._logoBoxSize,
            height: AuthWelcomePage._logoBoxSize,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                AuthWelcomePage._logoAsset,
                fit: BoxFit.contain,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14.0),
        Text(
          "appName".t(context),
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 28.0,
            color: AuthScreenColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10.0),
        Text(
          "auth.welcome.tagline".t(context),
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 15.0,
            height: 1.45,
            color: colors.tagline,
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AuthWelcomePage._heroRadius),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.asset(
          AuthWelcomePage._heroAsset,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}
