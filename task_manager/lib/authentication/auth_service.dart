import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<bool> signInWithGoogle() async {
    try {
      print('[Google Sign-In] Starting sign-in process...');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print('[Google Sign-In] Sign-in cancelled by user.');
        throw Exception('Sign-in cancelled');
      }

      print('[Google Sign-In] Account selected: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      print('[Google Sign-In] Signed in as UID: ${result.user?.uid}, Email: ${result.user?.email}');
      return true;
    } catch (e) {
      print('[Google Sign-In] Error: $e');
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      print('Trying to sign in: $email');
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Signed in as: ${result.user?.uid}');
      return true;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else {
        throw Exception('Email sign-in failed: ${e.message}');
      }
    } catch (e) {
      print('General exception: $e');
      throw Exception('Email sign-in failed: ${e.toString()}');
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign-up failed: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    return await _authService.signInWithEmail(email, password);
  }
  
  Future<void> signUpWithEmail(String email, String password) async {
    _handleAuth(() => _authService.signInWithEmail(email, password), successMsg: 'Email login successful!');
  }

  Future<void> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }

  Future<void> _handleAuth(Future<void> Function() authMethod, {String? successMsg}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authMethod();
      _errorMessage = successMsg;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}