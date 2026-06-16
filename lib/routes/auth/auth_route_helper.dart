import "package:flow/services/Firebase_auth_service.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

/// Auth is required only for Send Money — not for the local budget app.
class AuthRouteHelper {
  AuthRouteHelper._();

  static bool isSendMoneyPath(String path) {
    return path == "/send-money" || path.startsWith("/send-money/");
  }

  /// Redirect unsigned users to sign-in before Send Money screens.
  static String? redirectSendMoneyIfUnsigned(
    BuildContext context,
    GoRouterState state,
  ) {
    if (FirebaseAuthService().isSignedIn) return null;
    final String returnTo = Uri.encodeComponent(state.uri.toString());
    return "/auth/sign-in?returnTo=$returnTo";
  }

  /// After sign-in/up, return to Send Money or home.
  static String postAuthPath(String? returnTo) {
    if (returnTo == null || returnTo.isEmpty) return "/";
    final String path = Uri.tryParse(returnTo)?.path ?? returnTo;
    if (isSendMoneyPath(path)) return path;
    return "/";
  }

  static String signInPath({String? returnTo}) {
    if (returnTo == null || returnTo.isEmpty) return "/auth/sign-in";
    return "/auth/sign-in?returnTo=${Uri.encodeComponent(returnTo)}";
  }

  static String signUpPath({String? returnTo}) {
    if (returnTo == null || returnTo.isEmpty) return "/auth/sign-up";
    return "/auth/sign-up?returnTo=${Uri.encodeComponent(returnTo)}";
  }

  static bool isSendMoneyReturnTo(String? returnTo) {
    if (returnTo == null || returnTo.isEmpty) return false;
    final String path = Uri.tryParse(returnTo)?.path ?? returnTo;
    return isSendMoneyPath(path);
  }
}
