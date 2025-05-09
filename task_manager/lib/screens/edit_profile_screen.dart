import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_manager/services/user_profile_service.dart';
import 'package:flutter/foundation.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileScreen({super.key, required this.userProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;  bool _isLoading = false;
  final bool _isUploadingImage = false;
  String? _errorMessage;
  bool _showCheckIcon = false;
  
  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  
  final UserProfileService _profileService = UserProfileService();  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userProfile.displayName;
    // Username is no longer editable
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Define color transition from blue to green
    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.green,
    ).animate(_animationController);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  Future<void> _pickImage(ImageSource source) async {
    try {
      if (kDebugMode) {
        print('Attempting to pick image from source: $source');
      }
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kDebugMode) {
          print('Image picked successfully: ${pickedFile.path}');
        }
        setState(() {
          _imageFile = File(pickedFile.path);
          _showCheckIcon = true;
        });

        // Animate to check icon with green background
        _animationController.forward();

        // Show check icon for 2 seconds then revert back to camera icon
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          // Animate back to camera icon
          _animationController.reverse();
          setState(() {
            _showCheckIcon = false;
          });
        }
      } else {
        if (kDebugMode) {
          print('No image was picked.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred while picking image: $e');
      }
      setState(() {
        _errorMessage = 'Failed to pick image: ${e.toString()}';
      });
    }
  }
  
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_imageFile != null || widget.userProfile.photoUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _imageFile = null;
                      // We'll handle removal in the save changes method
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Handle profile photo changes for non-Google accounts
      if (!widget.userProfile.isGoogleAccount) {
        if (_imageFile != null) {
          await _profileService.updateProfilePhoto(_imageFile);
        } else if (widget.userProfile.photoUrl != null) {
          await _profileService.updateProfilePhoto(null);
        }
      }

      // Update name if changed (only for email accounts)
      if (!widget.userProfile.isGoogleAccount) {
        final newName = _nameController.text.trim();
        if (newName != widget.userProfile.displayName) {
          await _profileService.updateDisplayName(newName);
        }
      }

      // Reload the user profile to reflect changes
      await _profileService.reloadUserProfile();

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate changes were made
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
            height: MediaQuery.of(context).size.height,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 0, 0, 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      
                    // Profile Photo Section
                    if (!widget.userProfile.isGoogleAccount)
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: _imageFile != null
                                      ? FileImage(_imageFile!) as ImageProvider
                                      : (widget.userProfile.photoUrl != null
                                          ? widget.userProfile.photoUrl!.startsWith('file://')
                                              ? FileImage(File(widget.userProfile.photoUrl!.replaceFirst('file://', '')))
                                              : NetworkImage(widget.userProfile.photoUrl!)
                                          : null),
                                  child: (_imageFile == null && widget.userProfile.photoUrl == null)
                                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                                      : null,
                                ),                          Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: _colorAnimation.value,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: IconButton(
                                          icon: AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 300),
                                            transitionBuilder: (Widget child, Animation<double> animation) {
                                              return RotationTransition(
                                                turns: animation, 
                                                child: ScaleTransition(
                                                  scale: animation,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: _showCheckIcon 
                                              ? Icon(Icons.check, color: Colors.white, size: 20, key: ValueKey('check'))
                                              : Icon(Icons.camera_alt, color: Colors.white, size: 20, key: ValueKey('camera')),
                                          ),
                                          onPressed: _isUploadingImage || _showCheckIcon
                                              ? null
                                              : () {
                                                  _showPhotoOptions();
                                                },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (_isUploadingImage)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    
                    // Name field
                    Text(
                      'Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                      enabled: !widget.userProfile.isGoogleAccount, // Disable if Google account
                    ),
                    if (widget.userProfile.isGoogleAccount)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Name cannot be changed for Google accounts.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                      // Username field (display only)
                    Text(
                      'Username',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '@${widget.userProfile.username}',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          Icon(Icons.lock_outline, size: 18, color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Username cannot be changed for security reasons.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save Changes'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
