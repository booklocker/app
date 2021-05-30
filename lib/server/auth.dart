import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationResult {
  final User? user;
  final String? error;

  AuthenticationResult({this.user, this.error});
}

class Authentication {
  static Future<FirebaseApp> initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  static Future<AuthenticationResult> signUpWithEmail({required String email, required String password}) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      final UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      return AuthenticationResult(user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      return AuthenticationResult(error: e.message.toString());
    } catch (e) {
      print("Unexpected authentication error: ");
      print(e);

      return AuthenticationResult(error: "An unexpected error occurred. Please try again");
    }
  }

  static Future<AuthenticationResult> signInWithEmail({required String email, required String password}) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      return AuthenticationResult(user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      var message = e.message.toString();
      switch (e.code) {
        case "wrong-password":
          message = "Invalid password";
          break;
        case "user-not-found":
          message = "You don't have an existing account. Please try signing up";
          break;
      }
      print("Error code when signing in: " + e.code);
      return AuthenticationResult(error: message);
    } catch (e) {
      print("Unexpected authentication error: ");
      print(e);

      return AuthenticationResult(error: "An unexpected error occurred. Please try again");
    }
  }

  static Future<AuthenticationResult> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential = await auth.signInWithPopup(authProvider);
        return AuthenticationResult(user: userCredential.user);
      } catch (e) {
        print("Unexpected authentication error: ");
        print(e);

        return AuthenticationResult(error: "An unexpected error occurred. Please try again");
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential = await auth.signInWithCredential(credential);
          return AuthenticationResult(user: userCredential.user);
        } on FirebaseAuthException catch (e) {
          var message = e.message;
          switch (e.code) {
            case "account-exists-with-different-credential":
              message = "Please log in manually to continue";
              break;
          }
          return AuthenticationResult(error: message);
        } catch (e) {
          print("Unexpected authentication error: ");
          print(e);
        }
      }
    }

    return AuthenticationResult(error: "An unexpected error occurred. Please try again");
  }

  static Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Failed to sign out:");
      print(e);
    }
  }
}
