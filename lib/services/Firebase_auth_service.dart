

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flow/data/firebase_friend.dart";
import "package:flow/prefs/local_preferences.dart";
import "package:flow/services/firebase_send_money_service.dart";
import "package:flutter/foundation.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("FirebaseAuthService");
class FirebaseAuthService{
  static FirebaseAuthService? _instance;
  factory FirebaseAuthService()=>_instance??=FirebaseAuthService._();
  FirebaseAuthService._();

  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _db=FirebaseFirestore.instance;

  final ValueNotifier<int>authRevision=ValueNotifier(0);
   User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;
  

  void _notify() => authRevision.value++;

  Future<void> initialize() async {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _cacheUser(user);
        FirebaseIncomingTransfersListener().restart();
      } else {
        await LocalPreferences().clearFirebaseUser();
        FirebaseIncomingTransfersListener().stop();
      }
      _notify();
    });

    await _validateStoredSession();
    if (currentUser != null) {
      FirebaseIncomingTransfersListener().restart();
    }
    _notify();
  }

  /// Cached login on the phone survives deleting the user in Firebase Console.
  Future<void> _validateStoredSession() async {
    final User? user = currentUser;
    if (user == null) {
      await LocalPreferences().clearFirebaseUser();
      return;
    }

    try {
      await user.reload();
      final User? refreshed = _auth.currentUser;
      if (refreshed == null) {
        _log.info("No Firebase user after reload; signing out locally");
        await _localSignOut();
        return;
      }
      await refreshed.getIdToken(true);
      await _cacheUser(refreshed);
      await _ensureFirestoreProfile(refreshed);
    } on FirebaseAuthException catch (e, stackTrace) {
      if (_isInvalidSession(e)) {
        _log.info(
          "Firebase session invalid (${e.code}); signing out locally",
          e,
          stackTrace,
        );
        await _localSignOut();
      } else {
        _log.warning("Firebase session check failed", e, stackTrace);
        await _cacheUser(user);
      }
    } catch (e, stackTrace) {
      _log.fine(
        "Could not validate Firebase session (offline?); keeping local session",
        e,
        stackTrace,
      );
      await _cacheUser(user);
    }
  }

  bool _isInvalidSession(FirebaseAuthException e) {
    switch (e.code) {
      case "user-not-found":
      case "user-disabled":
      case "invalid-user-token":
      case "user-token-expired":
        return true;
      default:
        return false;
    }
  }

  Future<void> _localSignOut() async {
    try {
      await _auth.signOut();
    } catch (e, stackTrace) {
      _log.warning("Firebase signOut failed; clearing local session", e, stackTrace);
    }
    await LocalPreferences().clearFirebaseUser();
    _notify();
  }

  Future<void>_cacheUser(User user)async{
    final name=user.displayName?.trim().isNotEmpty==true
     ?user.displayName!.trim()
     :(user.email?.split("@").first ?? "");
     await LocalPreferences().saveFirebaseUser(userId: user.uid,
      displayName: name);
  }

  Future<void> _ensureFirestoreProfile(User user, {String? displayName}) async {
    try {
      final ref = _db.collection("users").doc(user.uid);
      final snap = await ref.get();
      if (!snap.exists) {
        final handle = _defaultHandle(user, displayName);
        await ref.set({
          "email": user.email?.trim().toLowerCase(),
          "displayName": displayName ?? user.displayName ?? "",
          "handle": handle,
          "handleLower": normalizeFriendHandle(handle),
          "discoverable": true,
          "createdAt": FieldValue.serverTimestamp(),
        });
      } else {
        final Map<String, Object?> patch = {};
        if (displayName != null && displayName.isNotEmpty) {
          patch["displayName"] = displayName.trim();
        }
        final data = snap.data();
        if (data?["handleLower"] == null && data?["handle"] != null) {
          patch["handleLower"] = normalizeFriendHandle(
            data!["handle"] as String,
          );
        }
        if (user.email != null && (data?["email"] == null)) {
          patch["email"] = user.email!.trim().toLowerCase();
        }
        if (patch.isNotEmpty) {
          await ref.update(patch);
        }
      }
    } catch (e, stackTrace) {
      _log.warning(
        "Firestore users/${user.uid} denied or failed — update Firestore rules in Firebase Console",
        e,
        stackTrace,
      );
    }
  }

  String _defaultHandle(User user ,String? displayName){
    final base=(displayName ?? user.email?.split("@").first ?? "user")
    .toLowerCase()
    .replaceAll(RegExp(r"[^a-z0-9_]"), "_");
     return "${base}_${user.uid.substring(0, 6)}";
  }

  Future<void>signUp({
 required String email,
    required String password,
    required String displayName
  })async{
   final cred=await _auth.createUserWithEmailAndPassword(email: email.trim(),
    password: password);
    final user=cred.user;
    if(user==null)
    throw FirebaseAuthException(code: "sign_up_failed");
    await user.updateDisplayName(displayName);
    await _ensureFirestoreProfile(user,displayName: displayName);
    await _cacheUser(user);
    _notify();

  }

  Future<void>signIn({
    required String email,
    required String password,
  })async{
    await _auth.signInWithEmailAndPassword(email: email.trim(),
     password: password);
     final user=currentUser;
     if(user != null){
      await _ensureFirestoreProfile(user);
      await _cacheUser(user);
     }
     _notify();

  }

  Future<void> signOut() async {
    await _localSignOut();
  }

  String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case "email-already-in-use":
        return "This email is already registered. Try Sign In.";
      case "invalid-email":
        return "Enter a valid email.";
      case "weak-password":
        return "Password must be at least 6 characters.";
      case "user-not-found":
      case "wrong-password":
      case "invalid-credential":
        return "Wrong email or password.";
      case "too-many-requests":
        return "Too many attempts. Wait a few minutes.";
      default:
        return e.message ?? e.code;
    }
  }


}