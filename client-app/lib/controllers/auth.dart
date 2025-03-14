import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:plan_sync/util/snackbar.dart';

class Auth extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  User? get activeUser => _auth.currentUser;
  late List<Function> authChangeListeners;

  void onInit() {
    authChangeListeners = [];
  }

  void addUserStatusListener(Function fn) => authChangeListeners.add(fn);
  void removeUserStatusListener(Function fn) => authChangeListeners.remove(fn);
  void notifyAuthStatusListeners() {
    for (var fn in authChangeListeners) {
      fn.call();
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    Logger.i("login using google");
    // Trigger the authentication flow
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ["profile", "email"],
      ).signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth == null) {
        Logger.e(
          "googleAuth was null, login potentially cancelled by the user",
        );
        CustomSnackbar.error(
          "Authentication Error",
          "Login was cancelled by the user.",
          context,
        );

        return;
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await FirebaseCrashlytics.instance.setUserIdentifier(activeUser!.uid);

      notifyAuthStatusListeners();
      return;
    } on FirebaseAuthException catch (error) {
      CustomSnackbar.error(
        "Authentication Error",
        "${error.code} : ${error.message}",
        context,
      );
      logout();
      return;
    } catch (error, trace) {
      CustomSnackbar.error(
        "Authentication Error",
        "Team has been notified, try again later",
        context,
      );
      FirebaseCrashlytics.instance.recordError(error, trace);
      logout();
      return;
    }
  }

  Future<void> loginWithApple(BuildContext context) async {
    final appleAuth = AppleAuthProvider();
    appleAuth.addScope('email');
    appleAuth.addScope('name');

    try {
      await FirebaseAuth.instance.signInWithProvider(
        appleAuth,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "web-context-canceled" || e.code == "canceled") {
        CustomSnackbar.error(
          "Authentication Error",
          "Procedure was cancelled by the user.",
          context,
        );
      }
      return;
    } catch (error, trace) {
      CustomSnackbar.error(
        "Authentication Error",
        "Team has been notified, try again later",
        context,
      );
      FirebaseCrashlytics.instance.recordError(error, trace);
      logout();
      return;
    }

    if (activeUser == null) {
      Logger.e("Active User Null post login -> auth.dart:58");
      return;
    }
    await FirebaseCrashlytics.instance.setUserIdentifier(activeUser!.uid);

    notifyAuthStatusListeners();
    return;
  }

  Future<void> logout() async {
    Logger.i("logout sequence");
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await FirebaseCrashlytics.instance.setUserIdentifier("");
    notifyAuthStatusListeners();
    return;
  }

  Future<void> deleteCurrentUser(BuildContext context) async {
    final provider =
        Platform.isAndroid ? GoogleAuthProvider() : AppleAuthProvider();

    UserCredential? authenticatedUser;
    try {
      authenticatedUser = await _auth.currentUser?.reauthenticateWithProvider(
        provider,
      );
    } on FirebaseAuthException catch (e) {
      // commonly happens if user used Apple Sign in with private
      // relay service.
      if (e.code == "user-mismatch") {
        CustomSnackbar.error(
          "User Mismatch",
          "We we're unable to verify your account, contact us to continue deletion.",
          context,
        );
        return;
      }
    }

    if (authenticatedUser == null) {
      CustomSnackbar.error(
        "Operation Failed",
        "We we're unable to verify your account, try again.",
        context,
      );
      return;
    }
    return _auth.currentUser?.delete().then((value) {
      CustomSnackbar.info(
        "Account Deleted",
        "We have sent delete request, it'll be done shortly!",
        context,
      );
      return;
    }).onError((err, trace) async {
      CustomSnackbar.error(
        "Operation Failed",
        "We faced some error. Please try again later.",
        context,
      );

      if (kReleaseMode) {
        FlutterErrorDetails flutterErrorDetails = FlutterErrorDetails(
          exception: err ?? Exception("Null exception on user delete"),
          stack: trace,
        );
        await FirebaseCrashlytics.instance.recordFlutterError(
          flutterErrorDetails,
        );
      }
      return;
    });
  }
}
