import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/authentication/auth_service.dart' as app_auth;
import 'package:task_manager/screens/change_password_screen.dart';
import 'package:task_manager/screens/edit_profile_screen.dart';
import 'package:task_manager/screens/login_screen.dart';
import 'package:task_manager/screens/settings_screen.dart';
import 'package:task_manager/services/user_profile_service.dart';
import 'package:flutter/foundation.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final UserProfileService _profileService = UserProfileService();
  bool _isLoading = true;
  UserProfile? _userProfile;
  String? _errorMessage;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
    // Show dialog to get password confirmation for account deletion
  Future<String?> _showPasswordConfirmationDialog() async {
    // Reset controller and state
    _passwordController.clear();
    _obscurePassword = true;
    
    if (kDebugMode) {
      print('Showing password confirmation dialog');
    }
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Confirm Password'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                    const Text(
                      'For security, please enter your account password to confirm deletion.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This action cannot be undone. If you use Google Sign-In, please enter your Google account password.',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your account password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your password'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        Navigator.of(dialogContext).pop(value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (kDebugMode) {
                      print('Password dialog: Cancel button pressed');
                    }
                    Navigator.of(dialogContext).pop(null); // Cancel
                  },
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    if (_passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your password'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    if (kDebugMode) {
                      print('Password dialog: Confirm button pressed with password');
                    }
                    Navigator.of(dialogContext).pop(_passwordController.text);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('CONFIRM'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  // Handle account deletion with proper reauthentication
  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    // Debug: Print user info
    if (kDebugMode) {
      print('Current user: ${user.email}');
      print('Authentication providers: ${user.providerData.map((info) => info.providerId).join(", ")}');
    }
    
    // Check if user is signed in with Google
    bool isGoogleUser = user.providerData.any(
      (info) => info.providerId == 'google.com'
    );
    
    if (kDebugMode) {
      print('Is Google user: $isGoogleUser');
    }
    
    // Show confirmation dialog before deleting account
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    ) ?? false;
    if (kDebugMode) {
      print('User confirmed deletion: $confirmed');
    }
    if (!confirmed) return;
    
    // Always request password confirmation, regardless of auth provider
    String? password;
    if (kDebugMode) {
      print('Requesting password confirmation');
    }
    password = await _showPasswordConfirmationDialog();
    if (kDebugMode) {
      print('Password provided: ${password != null ? "Yes" : "No"}');
    }
    if (password == null) return; // User cancelled
    try {
      if (kDebugMode) {
        print('Attempting to delete account with provider: ${isGoogleUser ? "Google" : "Email"}');
      }
      
      // Show loading indicator
      // ignore: use_build_context_synchronously
      if (mounted) {
        if (mounted) {
          if (mounted) {
            if (mounted) {
              if (mounted) {
                if (mounted) {
                  if (mounted) {
                    if (mounted) {
                      if (mounted) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Deleting account...'))
                          );
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      
      // Delete the account with password for reauthentication
      // ignore: use_build_context_synchronously
      await Provider.of<app_auth.AuthProvider>(context, listen: false)
        .deleteAccount(password: password);
      
      if (kDebugMode) {
        print('Account deletion successful');
      }
      
      // Account deleted successfully, navigate to login screen
      if (mounted) {
        if (mounted) {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e');
      }
      
      // Show error message
      if (mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
        }
      }
      
      String errorMessage = 'Error deleting account';
      
      // Extract meaningful error messages
      if (e.toString().contains('Password required')) {
        errorMessage = 'Password is required to delete your account';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (e.toString().contains('requires-recent-login')) {
        errorMessage = 'For security reasons, please sign out and sign back in before deleting your account';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'DISMISS',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        )
      );
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileService.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load profile: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color(0xFFB2D8B2), // Match the gradient's top color
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height, // Gradient covers half the page
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                stops: [0.0, 0.5],
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFB2D8B2), // Slightly darker green
                  Colors.white,
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Error loading profile',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(_errorMessage!, textAlign: TextAlign.center),
                                      const SizedBox(height: 24),
                                      ElevatedButton(
                                        onPressed: _loadUserProfile,
                                        child: const Text('Try Again'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      // User profile header with circular avatar and username
                                      Center(
                                        child: Column(
                                          children: [
                                            Stack(
                                              children: [
                                                CircleAvatar(
                                                  radius: 64,
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: _userProfile?.photoUrl != null 
                                                      ? _userProfile!.photoUrl!.startsWith('file://')
                                                          ? FileImage(File(_userProfile!.photoUrl!.replaceFirst('file://', '')))
                                                          : NetworkImage(_userProfile!.photoUrl!) as ImageProvider
                                                      : (user?.photoURL != null
                                                          ? NetworkImage(user!.photoURL!) as ImageProvider
                                                          : null),
                                                  child: (_userProfile?.photoUrl == null && user?.photoURL == null)
                                                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                                      : null,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              _userProfile?.displayName ?? user?.displayName ?? 'Sarah Johnson',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '@${_userProfile?.username ?? 'sarahj'}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _userProfile?.email ?? user?.email ?? 'sarah.johnson@email.com',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(
                                        height: 64),
                                      
                                      // Settings Card
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withAlpha((0.1 * 255).toInt()),
                                              spreadRadius: 1,
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            // Edit Profile
                                            ListTile(
                                              leading: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    color: Colors.green.withAlpha((0.1 * 255).toInt()),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.person_outline,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              title: const Text(
                                                'Edit Profile',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              trailing: const Icon(
                                                Icons.chevron_right,
                                                color: Colors.grey,
                                              ),
                                              onTap: () async {
                                                if (_userProfile == null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Profile data not available')),
                                                  );
                                                  return;
                                                }
                                                
                                                final result = await Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => EditProfileScreen(userProfile: _userProfile!),
                                                  ),
                                                );
                                                
                                                if (result == true) {
                                                  // Refresh profile if changes were made
                                                  await _loadUserProfile();
                                                }
                                              },
                                            ),
                                            
                                            const Divider(height: 1, indent: 16, endIndent: 16),
                                            
                                            // Change Password
                                            ListTile(
                                              leading: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    color: Colors.green.withAlpha((0.1 * 255).toInt()),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.lock_outline,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              title: const Text(
                                                'Change Password',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              trailing: const Icon(
                                                Icons.chevron_right,
                                                color: Colors.grey,
                                              ),
                                              onTap: () async {
                                                // Check if user is signed in with Google
                                                final user = FirebaseAuth.instance.currentUser;
                                                final isGoogleUser = user?.providerData.any(
                                                  (info) => info.providerId == 'google.com'
                                                ) ?? false;
                                                
                                                if (isGoogleUser) {
                                                  // Show message for Google users
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Google account users cannot change password through the app.'),
                                                      duration: Duration(seconds: 5),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                
                                                // Navigate to change password screen
                                                final result = await Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => const ChangePasswordScreen(),
                                                  ),
                                                );
                                                
                                                // Refresh profile if needed
                                                if (result == true) {
                                                  _loadUserProfile();
                                                }
                                              },
                                            ),
                                              const Divider(height: 1, indent: 16, endIndent: 16),
                                            
                                            // Language Settings
                                            ListTile(
                                              leading: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.withAlpha((0.1 * 255).toInt()),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.language,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              title: const Text(
                                                'Language Settings',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              trailing: const Icon(
                                                Icons.chevron_right,
                                                color: Colors.grey,
                                              ),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => const SettingsScreen(),
                                                  ),
                                                );
                                              },
                                            ),
                                            
                                            const Divider(height: 1, indent: 16, endIndent: 16),
                                            
                                            // Logout
                                            ListTile(
                                              leading: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withAlpha((0.1 * 255).toInt()),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.logout,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              title: const Text(
                                                'Logout',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              trailing: const Icon(
                                                Icons.chevron_right,
                                                color: Colors.grey,
                                              ),
                                              onTap: () async {
                                                try {
                                                  // Show loading indicator
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Signing out...'))
                                                  );
                                                  
                                                  // Sign out from both Google and Firebase
                                                  await Provider.of<app_auth.AuthProvider>(context, listen: false).signOut();
                                                  
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.of(context).pushAndRemoveUntil(
                                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                                    (route) => false,
                                                  );
                                                } catch (e) {
                                                  // Show error message
                                                  // ignore: use_build_context_synchronously
                                                  ScaffoldMessenger.of(context).clearSnackBars();
                                                  // ignore: use_build_context_synchronously
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Error signing out: ${e.toString()}'))
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                  ),
                // Delete Account Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha((0.1 * 255).toInt()),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.all(16.0),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: _deleteAccount,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
