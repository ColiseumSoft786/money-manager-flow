import "package:firebase_auth/firebase_auth.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/auth/auth_route_helper.dart";
import "package:flow/routes/auth/widgets/auth_sign_in_header.dart";
import "package:flow/services/Firebase_auth_service.dart";
import "package:flow/theme/auth_screen_colors.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class AuthSignInPage extends StatefulWidget {
  const AuthSignInPage({super.key, this.returnTo});

  /// Where to go after a successful sign-in (Send Money paths only).
  final String? returnTo;

  @override
  State<AuthSignInPage> createState() => _AuthSignInPageState();
}

class _AuthSignInPageState extends State<AuthSignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberDevice = false;

  static const double _horizontalPadding = 24.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuthService().signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      context.go(AuthRouteHelper.postAuthPath(widget.returnTo));
    } on FirebaseAuthException catch (e) {
      _showError(FirebaseAuthService().friendlyError(e));
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty || !email.contains("@")) {
      _showError("auth.error.invalidEmail".t(context));
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showError("auth.signIn.resetEmailSent".t(context));
    } on FirebaseAuthException catch (e) {
      _showError(FirebaseAuthService().friendlyError(e));
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? "";
    if (trimmed.isEmpty || !trimmed.contains("@")) {
      return "auth.error.invalidEmail".t(context);
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "auth.error.passwordTooShort".t(context);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AuthScreenColors colors = AuthScreenColors.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    final bool forSendMoney = AuthRouteHelper.isSendMoneyReturnTo(
      widget.returnTo,
    );

    return Scaffold(
      backgroundColor: colors.bodyBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthSignInHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                _horizontalPadding,
                8.0,
                _horizontalPadding,
                24.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "auth.signIn.welcomeBack".t(context),
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 28.0,
                        color: colors.headline,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      forSendMoney
                          ? "auth.signIn.sendMoneySubtitle".t(context)
                          : "auth.signIn.subtitle".t(context),
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.subtitle,
                        fontSize: 16.0,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 28.0),
                    Text(
                      "auth.signIn.emailLabel".t(context),
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.label,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enabled: !_loading,
                      validator: _validateEmail,
                      style: colors.fieldTextStyle,
                      cursorColor: colors.inputText,
                      decoration: colors.inputDecoration(
                        hintText: "auth.signIn.emailHint".t(context),
                        prefixIcon: Icon(
                          Symbols.mail_rounded,
                          color: colors.icon,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "auth.signIn.passwordLabel".t(context),
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.label,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _loading ? null : _forgotPassword,
                          child: Text(
                            "auth.signIn.forgotPassword".t(context),
                            style: textTheme.labelMedium?.copyWith(
                              color: AuthScreenColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !_loading,
                      validator: _validatePassword,
                      style: colors.fieldTextStyle,
                      cursorColor: colors.inputText,
                      decoration: colors.inputDecoration(
                        hintText: "••••••••",
                        prefixIcon: Icon(
                          Symbols.lock_rounded,
                          color: colors.icon,
                        ),
                        suffixIcon: IconButton(
                          onPressed: _loading
                              ? null
                              : () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                          icon: Icon(
                            _obscurePassword
                                ? Symbols.visibility_rounded
                                : Symbols.visibility_off_rounded,
                            color: colors.icon,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        SizedBox(
                          width: 22.0,
                          height: 22.0,
                          child: Checkbox(
                            value: _rememberDevice,
                            onChanged: _loading
                                ? null
                                : (value) => setState(
                                    () => _rememberDevice = value ?? false,
                                  ),
                            activeColor: AuthScreenColors.primary,
                            checkColor: Colors.white,
                            fillColor: WidgetStatePropertyAll(colors.inputFill),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            side: BorderSide(
                              color: colors.icon,
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            "auth.signIn.rememberDevice".t(context),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.subtitle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    Button(
                      fullWidth: true,
                      onTap: _loading ? null : _submit,
                      backgroundColor: AuthScreenColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 6.0,
                      shadowColor: AuthScreenColors.primaryButtonShadow,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(kFlowAuthSignInFieldRadius),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 20.0,
                      ),
                      child: _loading
                          ? const Spinner.inline(color: Colors.white)
                          : Text(
                              "auth.signIn.submit".t(context),
                              style: const TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    const SizedBox(height: 28.0),
                    Center(
                      child: GestureDetector(
                        onTap: _loading
                            ? null
                            : () => context.push(
                                AuthRouteHelper.signUpPath(
                                  returnTo: widget.returnTo,
                                ),
                              ),
                        child: Text.rich(
                          TextSpan(
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.subtitle,
                            ),
                            children: [
                              TextSpan(
                                text: "auth.signIn.noAccount".t(context),
                              ),
                              TextSpan(
                                text: "auth.signIn.signUpLink".t(context),
                                style: const TextStyle(
                                  color: AuthScreenColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (forSendMoney) ...[
                      const SizedBox(height: 20.0),
                      Center(
                        child: TextButton(
                          onPressed: _loading ? null : () => context.go("/"),
                          child: Text(
                            "auth.signIn.continueWithoutAccount".t(context),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
