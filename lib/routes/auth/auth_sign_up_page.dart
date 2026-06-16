import "package:firebase_auth/firebase_auth.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/routes/auth/auth_route_helper.dart";
import "package:flow/routes/auth/widgets/auth_sign_up_header.dart";
import "package:flow/services/Firebase_auth_service.dart";
import "package:flow/theme/auth_screen_colors.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/widgets/general/button.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class AuthSignUpPage extends StatefulWidget {
  const AuthSignUpPage({super.key, this.returnTo});

  final String? returnTo;

  @override
  State<AuthSignUpPage> createState() => _AuthSignUpPageState();
}

class _AuthSignUpPageState extends State<AuthSignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  static const double _horizontalPadding = 24.0;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  

  Future<void> _submit() async {
    if (!_acceptedTerms) {
      _showError("auth.error.termsRequired".t(context));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuthService().signUp(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _displayNameController.text,
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
    if (value == null || value.length < 6) {
      return "auth.error.passwordTooShort".t(context);
    }
    return null;
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "auth.error.displayNameRequired".t(context);
    }
    return null;
  }

  Widget _labeledField({
    required AuthScreenColors colors,
    required String labelKey,
    required Widget field,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelKey.t(context),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.label,
          ),
        ),
        const SizedBox(height: 8.0),
        field,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthScreenColors colors = AuthScreenColors.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.bodyBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthSignUpHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                _horizontalPadding,
                20.0,
                _horizontalPadding,
                24.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "auth.signUp.title".t(context),
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 28.0,
                        color: colors.headline,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "auth.signUp.subtitle".t(context),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.subtitle,
                        fontSize: 16.0,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 28.0),
                    _labeledField(
                      colors: colors,
                      labelKey: "auth.signUp.displayName",
                      field: TextFormField(
                        controller: _displayNameController,
                        textCapitalization: TextCapitalization.words,
                        enabled: !_loading,
                        validator: _validateDisplayName,
                        style: colors.fieldTextStyle,
                        cursorColor: colors.inputText,
                        decoration: colors.inputDecoration(
                          hintText: "auth.signUp.displayNameHint".t(context),
                          outlined: true,
                          prefixIcon: Icon(
                            Symbols.person_rounded,
                            color: colors.icon,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    _labeledField(
                      colors: colors,
                      labelKey: "auth.signIn.emailLabel",
                      field: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enabled: !_loading,
                        validator: _validateEmail,
                        style: colors.fieldTextStyle,
                        cursorColor: colors.inputText,
                        decoration: colors.inputDecoration(
                          hintText: "auth.signIn.emailHint".t(context),
                          outlined: true,
                          prefixIcon: Icon(
                            Symbols.mail_rounded,
                            color: colors.icon,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    _labeledField(
                      colors: colors,
                      labelKey: "auth.signIn.passwordLabel",
                      field: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: !_loading,
                        validator: _validatePassword,
                        style: colors.fieldTextStyle,
                        cursorColor: colors.inputText,
                        decoration: colors.inputDecoration(
                          hintText: "••••••••",
                          outlined: true,
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
                    ),
                    const SizedBox(height: 18.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22.0,
                          height: 22.0,
                          child: Checkbox(
                            value: _acceptedTerms,
                            onChanged: _loading
                                ? null
                                : (value) => setState(
                                    () => _acceptedTerms = value ?? false,
                                  ),
                            activeColor: AuthScreenColors.primary,
                            checkColor: Colors.white,
                            fillColor: WidgetStatePropertyAll(colors.inputFill),
                            shape: const CircleBorder(),
                            side: BorderSide(
                              color: colors.icon,
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: _TermsText(
                            colors: colors,
                            onTermsTap: () => context.push("/support"),
                            onPrivacyTap: () => context.push("/support"),
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
                      trailing: const Icon(
                        Symbols.arrow_forward_rounded,
                        size: 22.0,
                        color: Colors.white,
                      ),
                      child: _loading
                          ? const Spinner.inline(color: Colors.white)
                          : Text(
                              "auth.signUp.submit".t(context),
                              style: const TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24.0),
                    Center(
                      child: GestureDetector(
                        onTap: _loading
                            ? null
                            : () => context.push(
                                AuthRouteHelper.signInPath(
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
                                text: "auth.signUp.hasAccount".t(context),
                              ),
                              TextSpan(
                                text: "auth.signUp.signInLink".t(context),
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

class _TermsText extends StatelessWidget {
  const _TermsText({
    required this.colors,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  final AuthScreenColors colors;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = Theme.of(context).textTheme.bodySmall!.copyWith(
      color: colors.subtitle,
      height: 1.45,
    );
    final TextStyle link = base.copyWith(
      color: AuthScreenColors.primary,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: "auth.signUp.termsPrefix".t(context)),
          TextSpan(
            text: "auth.signUp.termsOfService".t(context),
            style: link,
            recognizer: TapGestureRecognizer()..onTap = onTermsTap,
          ),
          TextSpan(text: "auth.signUp.termsAnd".t(context)),
          TextSpan(
            text: "auth.signUp.privacyPolicy".t(context),
            style: link,
            recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
          ),
          const TextSpan(text: "."),
        ],
      ),
    );
  }
}
