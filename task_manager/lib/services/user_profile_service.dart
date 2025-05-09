import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:task_manager/services/local_storage_service.dart';

class UserProfile {
  final String userId;
  final String email;
  final String displayName;
  final String username;
  final String? photoUrl;
  final bool isGoogleAccount;
  final DateTime createdAt;
  final DateTime lastUpdated;

  UserProfile({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.username,
    this.photoUrl,
    required this.isGoogleAccount,
    required this.createdAt,
    required this.lastUpdated,
  });

  UserProfile.fromFirestore(Map<String, dynamic> data, String id)
      : userId = id,
        email = data['email'] ?? '',
        displayName = data['displayName'] ?? '',
        username = data['username'] ?? '',
        photoUrl = data['photoUrl'],
        isGoogleAccount = data['isGoogleAccount'] ?? false,
        createdAt = (data['createdAt'] as Timestamp).toDate(),
        lastUpdated = (data['lastUpdated'] as Timestamp).toDate();

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'username': username,
      'photoUrl': photoUrl,
      'isGoogleAccount': isGoogleAccount,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
    };
  }
}

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _users => _firestore.collection('users');

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    DocumentSnapshot doc = await _users.doc(user.uid).get();
    if (doc.exists) {
      return UserProfile.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
  // Create or update user profile
  Future<void> createOrUpdateUserProfile({
    String? displayName,
    required String username,  // Now required in all cases
    String? photoUrl,
    bool? isGoogleAccount,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is signed in');
    }
    
    if (kDebugMode) {
      print('[UserProfile] Creating/updating profile for ${user.uid} with username: $username');
    }

    // Check if user profile exists
    DocumentSnapshot doc = await _users.doc(user.uid).get();
    final now = DateTime.now();

    if (doc.exists) {
      // Update existing profile
      final existingData = doc.data() as Map<String, dynamic>;
      // Don't change username if it already exists
      await _users.doc(user.uid).update({
        'displayName': displayName ?? existingData['displayName'],
        'photoUrl': photoUrl ?? existingData['photoUrl'],
        'lastUpdated': now,
      });
      if (kDebugMode) {
        print('[UserProfile] Updated existing profile for ${user.uid}');
      }
    } else {
      // Create new profile - displayName is required
      if (displayName == null) {
        throw Exception('displayName is required when creating a new profile');
      }

      await _users.doc(user.uid).set({
        'email': user.email,
        'displayName': displayName,
        'username': username,
        'photoUrl': photoUrl ?? user.photoURL,
        'isGoogleAccount': isGoogleAccount ?? false,
        'createdAt': now,
        'lastUpdated': now,
      });

      // Update Firebase Auth display name if not set
      if (user.displayName == null || user.displayName!.isEmpty) {
        await user.updateDisplayName(displayName);
      }
    }
  }
  
  // Generate a unique username based on displayName
  Future<String> generateUniqueUsername(String baseName) async {
    try {
      if (kDebugMode) {
        print('[UserProfile] Generating username from: $baseName');
      }
      
      // Format name properly for username (e.g., "Attilio Santana" -> "attilio_santana")
      String sanitizedName = baseName
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'[^\w\s]+'), '') // Remove special characters
          .replaceAll(RegExp(r'\s+'), '_');    // Replace spaces with underscores
      
      // Ensure we have at least some characters to work with
      if (sanitizedName.isEmpty || sanitizedName == "user") {
        // If baseName is already "user" or empty, use "googleuser" as base
        // This prevents returning just "user_1", "user_2", etc.
        sanitizedName = "googleuser";
      }
  
      // If the sanitized name is too short, pad it
      if (sanitizedName.length < 3) {
        sanitizedName = sanitizedName.padRight(3, '0');
      }
      
      if (kDebugMode) {
        print('[UserProfile] Sanitized name: $sanitizedName');
      }
  
      // First, check if the base username is available
      QuerySnapshot existingUsernames = await _users
          .where('username', isEqualTo: sanitizedName)
          .limit(1)
          .get();
  
      if (existingUsernames.docs.isEmpty) {
        if (kDebugMode) {
          print('[UserProfile] Base username available: $sanitizedName');
        }
        return sanitizedName;
      }
  
      // If username exists, add a number suffix (e.g., attilio_santana_1)
      int counter = 1;
      String newUsername = '${sanitizedName}_$counter';
  
      // Keep incrementing until we find an available username
      // Set a maximum limit to prevent infinite loops
      int maxAttempts = 100;
      int attempts = 0;
      
      while (attempts < maxAttempts) {
        if (kDebugMode) {
          print('[UserProfile] Trying alternative username: $newUsername');
        }
        
        QuerySnapshot usernameCheck = await _users
            .where('username', isEqualTo: newUsername)
            .limit(1)
            .get();
  
        if (usernameCheck.docs.isEmpty) {
          if (kDebugMode) {
            print('[UserProfile] Found available username: $newUsername');
          }
          return newUsername;
        }
  
        counter++;
        attempts++;
        newUsername = '${sanitizedName}_$counter';
      }
      
      // If we reach here, we couldn't find a unique username with the base
      // Generate a username with timestamp to ensure uniqueness
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      final fallbackUsername = '${sanitizedName}_$timestamp';
      if (kDebugMode) {
        print('[UserProfile] Using fallback username with timestamp: $fallbackUsername');
      }
      return fallbackUsername;
    } catch (e) {
      if (kDebugMode) {
        print('[UserProfile] Error generating username: $e');
      }
      // Generate a failsafe username if all else fails
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      // Here's the critical fix - use the same format as the successful path
      // Instead of just 'user_$timestamp', use the base name if possible
      String fallbackBase = baseName.toLowerCase().trim().isEmpty ? "googleuser" : baseName.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');
      return '${fallbackBase}_$timestamp';
    }
  }

  // Update user display name
  Future<void> updateDisplayName(String displayName) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is signed in');
    }

    await _users.doc(user.uid).update({
      'displayName': displayName,
      'lastUpdated': DateTime.now(),
    });

    await user.updateDisplayName(displayName);
  }
  // Update username
  Future<void> updateUsername(String username) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is signed in');
    }

    // Check if username already exists (except for current user)
    QuerySnapshot existingUsernames = await _users
        .where('username', isEqualTo: username)
        .where(FieldPath.documentId, isNotEqualTo: user.uid)
        .limit(1)
        .get();

    if (existingUsernames.docs.isNotEmpty) {
      throw Exception('This username is already taken');
    }

    await _users.doc(user.uid).update({
      'username': username,
      'lastUpdated': DateTime.now(),
    });
  }  // Update user profile photo
  Future<void> updateProfilePhoto(File? imageFile) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is signed in');
    }
    
    try {
      // If imageFile is null, we're removing the photo
      if (imageFile == null) {
        // Delete the local photo
        await LocalStorageService.instance.deleteProfileImage();
        
        // Update user's profile in Firebase Auth to remove photo URL
        await user.updatePhotoURL(null);
        
        // Update user's profile in Firestore to remove photo URL
        await _users.doc(user.uid).update({
          'photoUrl': FieldValue.delete(),
          'lastUpdated': DateTime.now(),
        });
        
        if (kDebugMode) {
          print('[Profile] Removed profile photo');
        }
        return;
      }
      
      // Save the image locally
      final localPath = await LocalStorageService.instance.saveProfileImage(imageFile);
      
      // Format the path as a file URI for consistent usage
      final fileUri = 'file://$localPath';
      
      // Update user's profile in Firebase Auth
      await user.updatePhotoURL(fileUri);
      
      // Update user's profile in Firestore
      await _users.doc(user.uid).update({
        'photoUrl': fileUri,
        'lastUpdated': DateTime.now(),
      });
      
      if (kDebugMode) {
        print('[Profile] Updated profile photo: $fileUri');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Profile] Error updating profile photo: $e');
      }
      throw Exception('Failed to update profile photo: ${e.toString()}');
    }
  }
  // Delete user profile from Firestore when account is deleted
  Future<void> deleteUserProfile() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is signed in');
    }

    // Delete the local profile photo if it exists
    await LocalStorageService.instance.deleteProfileImage();

    // Delete the user profile from Firestore
    await _users.doc(user.uid).delete();
  }

  Future<void> reloadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // Reload the user's data from Firebase
    }
  }
}
