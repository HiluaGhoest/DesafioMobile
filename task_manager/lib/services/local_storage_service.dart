import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Service for storing and retrieving local files
class LocalStorageService {
  // Private constructor for singleton pattern
  LocalStorageService._();
  
  // Singleton instance
  static final LocalStorageService instance = LocalStorageService._();
  
  /// Save profile image to local storage
  /// Returns the file path where the image was saved
  Future<String> saveProfileImage(File imageFile) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Get the app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      
      // Create directory for profile images if it doesn't exist
      final profileImagesDir = Directory('${appDir.path}/profile_images');
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }
      
      // Define target file path
      final targetPath = '${profileImagesDir.path}/$userId.jpg';
      
      // Copy the image to target path
      final savedFile = await imageFile.copy(targetPath);
      
      debugPrint('Profile image saved to: $targetPath');
      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving profile image: $e');
      throw Exception('Failed to save profile image: ${e.toString()}');
    }
  }
  
  /// Get the local path for a user's profile image
  Future<String?> getProfileImagePath() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return null;
      
      final appDir = await getApplicationDocumentsDirectory();
      final profileImagePath = '${appDir.path}/profile_images/$userId.jpg';
      
      final file = File(profileImagePath);
      if (await file.exists()) {
        return profileImagePath;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error getting profile image path: $e');
      return null;
    }
  }
  
  /// Delete a user's profile image from local storage
  Future<void> deleteProfileImage() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final appDir = await getApplicationDocumentsDirectory();
      final profileImagePath = '${appDir.path}/profile_images/$userId.jpg';
      
      final file = File(profileImagePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Profile image deleted: $profileImagePath');
      }
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
    }
  }
}
