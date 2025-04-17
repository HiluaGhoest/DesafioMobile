import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception('Sign-in cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else {
        throw Exception('Email sign-in failed: ${e.message}');
      }
    } catch (e) {
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


}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> signInWithGoogle() async {
    _handleAuth(() => _authService.signInWithGoogle(), successMsg: 'Google login successful!');
  }

  Future<void> signInWithEmail(String email, String password) async {
    _handleAuth(() => _authService.signInWithEmail(email, password), successMsg: 'Email Sign Up successful!');
  }
  
  Future<void> signUpWithEmail(String email, String password) async {
    _handleAuth(() => _authService.signInWithEmail(email, password), successMsg: 'Email login successful!');
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