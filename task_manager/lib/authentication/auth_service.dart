import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_manager/services/user_profile_service.dart';
import 'package:flutter/foundation.dart';

class AuthService {  Future<bool> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('[Google Sign-In] Starting sign-in process...');
      }
      // Create a GoogleSignIn instance with forceCodeForRefreshToken to ensure the account chooser is shown
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );
      
      // First ensure we're signed out
      await googleSignIn.signOut();
      
      // Now trigger sign in, which will show the account picker
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (kDebugMode) {
          print('[Google Sign-In] Sign-in cancelled by user.');
        }
        throw Exception('Sign-in cancelled');
      }

      if (kDebugMode) {
        print('[Google Sign-In] Account selected: ${googleUser.email}');
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        // This will sign in if the account exists, or create a new account if it doesn't
        final result = await FirebaseAuth.instance.signInWithCredential(credential);
          // Check if this is a new user
        final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
        final user = result.user;
        
        if (isNewUser && user != null) {
          if (kDebugMode) {
            print('[Google Sign-In] Created new account with UID: ${user.uid}, Email: ${user.email}');
          }
          
          // Initialize UserProfileService
          final UserProfileService profileService = UserProfileService();
            // Get display name and email from Google account
          final displayName = user.displayName ?? googleUser.displayName ?? 'Google User';
          final email = user.email ?? googleUser.email;
          
          if (kDebugMode) {
            print('[Google Sign-In] Generating username for: $displayName, email: $email');
          }
            try {
            // Always prefer the display name for generating a username
            // This makes usernames more coherent with the user's actual name (e.g., attilio_santana_123)
            String baseForUsername;
            if (displayName.isNotEmpty && displayName != 'Google User') {
              baseForUsername = displayName;
              if (kDebugMode) {
                print('[Google Sign-In] Using display name for username: $baseForUsername');
              }
            } 
            // Fall back to email prefix if display name isn't available
            else if (email.isNotEmpty && email.contains('@')) {
              baseForUsername = email.split('@')[0];
              if (kDebugMode) {
                print('[Google Sign-In] Using email prefix for username: $baseForUsername');
              }
            } 
            // Last resort default
            else {
              baseForUsername = 'googleuser';
              if (kDebugMode) {
                print('[Google Sign-In] Using default name for username: $baseForUsername');
              }
            }
            
            final username = await profileService.generateUniqueUsername(baseForUsername);
            if (kDebugMode) {
              print('[Google Sign-In] Generated username: $username');
            }
            
            // Create user profile in Firestore
            await profileService.createOrUpdateUserProfile(
              displayName: displayName,
              username: username,
              photoUrl: user.photoURL,
              isGoogleAccount: true,
            );
            
            if (kDebugMode) {
              print('[Google Sign-In] Successfully created user profile with username: $username');
            }
          } catch (e) {
            if (kDebugMode) {
              print('[Google Sign-In] Error during profile creation: $e');
            }
            // Create a fallback profile if username generation fails
            final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
            final fallbackUsername = 'google_$timestamp';
            
            await profileService.createOrUpdateUserProfile(
              displayName: displayName,
              username: fallbackUsername,
              photoUrl: user.photoURL,
              isGoogleAccount: true,
            );
            
            if (kDebugMode) {
              print('[Google Sign-In] Created profile with fallback username: $fallbackUsername');
            }
          }
        } else {
          if (kDebugMode) {
            print('[Google Sign-In] Signed in existing user with UID: ${user?.uid}, Email: ${user?.email}');
          }
        }
        
        return true;
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          print('[Google Sign-In] FirebaseAuthException: ${e.code} - ${e.message}');
        }
        switch (e.code) {
          case 'account-exists-with-different-credential':
            throw Exception('An account already exists with the same email address but different sign-in credentials. Try signing in with a different method.');
          case 'invalid-credential':
            throw Exception('The authentication credential is malformed or expired.');
          case 'operation-not-allowed':
            throw Exception('Google sign-in is not enabled for this project.');
          case 'user-disabled':
            throw Exception('Your account has been disabled.');
          case 'user-not-found':
            throw Exception('No user found for that email.');
          case 'wrong-password':
            throw Exception('The password is invalid or the user does not have a password.');
          case 'network-request-failed':
            throw Exception('A network error occurred. Please check your connection and try again.');
          default:
        }        throw Exception('Google sign-in failed with code: ${e.code}');
        }
      }
    catch (e) {
      if (kDebugMode) {
        print('[Google Sign-In] Error: $e');
      }
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Google sign-in failed: ${e.toString()}');
      }
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      if (kDebugMode) {
        print('Trying to sign in: $email');
      }
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) {
        print('Signed in as: ${result.user?.uid}');
      }
      return true;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException: ${e.code} - ${e.message}');
      }
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else {
        throw Exception('Email sign-in failed: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('General exception: $e');
      }
      throw Exception('Email sign-in failed: ${e.toString()}');
    }
  }  Future<User?> signUpWithEmail(String email, String password, {String? displayName, String? username}) async {
    try {
      if (kDebugMode) {
        print('[Email Sign-Up] Attempting to create account: $email');
      }
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = result.user;
      if (kDebugMode) {
        print('[Email Sign-Up] Created account with UID: ${user?.uid}');
      }
      
      if (user != null) {
        // Initialize UserProfileService
        final UserProfileService profileService = UserProfileService();
        
        // Generate username if not provided
        final actualUsername = username ?? await profileService.generateUniqueUsername(
          displayName ?? email.split('@')[0]
        );
        
        // Set the display name in Firebase Auth
        await user.updateDisplayName(displayName);          // Create user profile in Firestore
          await profileService.createOrUpdateUserProfile(
            displayName: displayName ?? email.split('@')[0],
            username: actualUsername,  // Already required
            isGoogleAccount: false,
          );
        
        // Return the user object for automatic login
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('[Email Sign-Up] FirebaseAuthException: ${e.code} - ${e.message}');
      }
      if (e.code == 'email-already-in-use') {
        throw Exception('This email address is already in use.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password is too weak.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address.');
      } else {
        throw Exception('Sign-up failed: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Email Sign-Up] Error: $e');
      }
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
  
  // Method to update the current user's password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        throw Exception('No user is signed in');
      }

      if (user.email == null) {
        throw Exception('Cannot update password: email is missing');
      }
      
      if (kDebugMode) {
        print('[Auth] Updating password for user: ${user.email}');
      }
      
      // First, reauthenticate the user
      await reauthenticateWithPassword(currentPassword);
      
      // Then update the password
      await user.updatePassword(newPassword);
      if (kDebugMode) {
        print('[Auth] Password updated successfully');
      }
      
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('[Auth] Password update failed: ${e.code} - ${e.message}');
      }
      if (e.code == 'requires-recent-login') {
        throw Exception('For security reasons, please sign out and sign back in before changing your password');
      } else {
        throw Exception('Password update failed: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Error updating password: $e');
      }
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      
      // If possible, disconnect to truly clear the Google account from memory
      try {
        await googleSignIn.disconnect();
        if (kDebugMode) {
          print('[Auth] Successfully disconnected Google Sign-In');
        }
      } catch (e) {
        // Ignore disconnect errors as they're not critical
        if (kDebugMode) {
          print('[Auth] Error disconnecting Google Sign-In (not critical): $e');
        }
      }
      
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      if (kDebugMode) {
        print('[Auth] Successfully signed out from both Google and Firebase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Error during sign out: $e');
      }
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }  // Method to reauthenticate before sensitive operations
  Future<bool> reauthenticateWithPassword(String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        throw Exception('No user is signed in');
      }

      if (user.email == null) {
        throw Exception('Cannot reauthenticate: email is missing');
      }
      
      if (kDebugMode) {
        print('[Auth] Reauthenticating user: ${user.email}');
      }
      
      // Create credential
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      // Reauthenticate
      await user.reauthenticateWithCredential(credential);
      if (kDebugMode) {
        print('[Auth] Reauthentication successful');
      }
      return true;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('[Auth] Reauthentication failed: ${e.code} - ${e.message}');
      }
      if (e.code == 'wrong-password') {
        throw Exception('Incorrect password. Please try again.');
      } else {
        throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Unexpected error during reauthentication: $e');
      }
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }
  
  // Method to handle reauthentication for Google users
  Future<bool> reauthenticateWithGoogle() async {
    try {
      // Sign in with Google again
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Reauthenticate the user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is signed in');
      }
      
      await user.reauthenticateWithCredential(credential);
      if (kDebugMode) {
        print('[Auth] Google reauthentication successful');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Error during Google reauthentication: $e');
      }
      throw Exception('Google reauthentication failed: ${e.toString()}');
    }
  }  Future<void> deleteAccount({String? password}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        throw Exception('No user is signed in');
      }
      
      // Always require password for account deletion
      if (password == null) {
        throw Exception('Password required to delete account');
      }
      
      if (kDebugMode) {
        print('[Auth] Attempting to delete account for user: ${user.email}');
        print('[Auth] Provider data: ${user.providerData.map((info) => info.providerId).join(", ")}');
      }
      
      // Check authentication provider
      bool isGoogleUser = user.providerData.any(
        (info) => info.providerId == 'google.com'
      );
      
      if (kDebugMode) {
        print('[Auth] Is Google user: $isGoogleUser');
        print('[Auth] Password provided: Yes');
      }
      
      // First, try to reauthenticate proactively
      try {
        // For Google users, try password first, then fall back to Google reauthentication if password fails
        if (isGoogleUser) {
          try {
            // Try with password first (if user has set up an email/password as well)
            if (kDebugMode) {
              print('[Auth] Attempting to reauthenticate Google user with password');
            }
            await reauthenticateWithPassword(password);
          } catch (passwordAuthError) {
            if (kDebugMode) {
              print('[Auth] Password auth failed for Google user, trying Google auth: $passwordAuthError');
            }
            // Fall back to Google authentication
            await reauthenticateWithGoogle();
          }
        } else {
          // Regular email/password authentication
          if (kDebugMode) {
            print('[Auth] Proactively reauthenticating with password');
          }
          await reauthenticateWithPassword(password);
        }
      } catch (reAuthError) {
        if (kDebugMode) {
          print('[Auth] Proactive reauthentication failed: $reAuthError');
        }
        throw Exception('Authentication failed: $reAuthError');
      }
      
      // Try to delete the account after reauthentication
      try {
        // First, delete the user's profile data from Firestore
        final UserProfileService profileService = UserProfileService();
        await profileService.deleteUserProfile();
        
        // Then try to delete the user account
        await user.delete();
        if (kDebugMode) {
          print('[Auth] Account successfully deleted');
        }
        return;
      } on FirebaseAuthException catch (e) {        // If we get requires-recent-login (which shouldn't happen now), we'll try again
        if (e.code == 'requires-recent-login') {
          if (kDebugMode) {
            print('[Auth] Requires recent login even after reauthentication, trying again...');
          }
          
          bool reauthSuccess = false;
          
          // Try more aggressively with password and Google Sign-In
          try {
            if (isGoogleUser) {
              try {
                // Try password first for Google user
                reauthSuccess = await reauthenticateWithPassword(password);
              } catch (innerError) {
                // If password auth fails for Google user, fall back to Google auth
                if (kDebugMode) {
                  print('[Auth] Password auth failed on second attempt: $innerError');
                }
                reauthSuccess = await reauthenticateWithGoogle();
              }
            } else {
              // Standard email/password auth
              reauthSuccess = await reauthenticateWithPassword(password);
            }
          } catch (finalAuthError) {
            if (kDebugMode) {
              print('[Auth] Final authentication attempt failed: $finalAuthError');
            }
            throw Exception('Authentication failed after multiple attempts: $finalAuthError');
          }
          
          if (reauthSuccess) {
            // Try deleting again after reauthentication
            // First, delete the user's profile data from Firestore
            final UserProfileService profileService = UserProfileService();
            await profileService.deleteUserProfile();
            
            // Delete the Firebase user account
            await user.delete();
            if (kDebugMode) {
              print('[Auth] Account successfully deleted after reauthentication');
            }
          }
        } else {
          // Some other Firebase Auth error
          throw Exception('Failed to delete account: ${e.message}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Auth] Error deleting account: $e');
      }
      throw Exception('Failed to delete account: ${e.toString()}');
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
  }  Future<User?> signUpWithEmail(String email, String password, {String? displayName, String? username}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final user = await _authService.signUpWithEmail(email, password, displayName: displayName, username: username);
      _errorMessage = 'Account created successfully!';
      _isLoading = false;
      notifyListeners();
      return user; // Return the user that was created
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // Re-throw to allow the UI to handle it
    }
  }
  Future<void> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }
  
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    return await _authService.updatePassword(currentPassword, newPassword);
  }
  
  Future<void> signOut() async {
    return await _authService.signOut();
  }    Future<void> deleteAccount({String? password}) async {
    return await _authService.deleteAccount(password: password);
  }
}