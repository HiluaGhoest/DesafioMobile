import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/authentication/auth_service.dart';
import 'package:task_manager/util/colors/app_colors.dart';
import 'package:task_manager/util/theme_provider.dart';
import 'package:task_manager/screens/main_app_page.dart';

class SignupRequirement {
  final String description;
  final bool Function(String) validator;
  bool isMet = false;

  SignupRequirement({
    required this.description,
    required this.validator,
  });
}

class SignUpModal extends StatefulWidget {
  const SignUpModal({super.key});

  @override
  State<SignUpModal> createState() => _SignUpModalState();
}

class _SignUpModalState extends State<SignUpModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _signUpError;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final List<SignupRequirement> _passwordRequirements = [
    SignupRequirement(
      description: 'At least 8 characters',
      validator: (password) => password.length >= 8,
    ),
    SignupRequirement(
      description: 'At least one uppercase letter',
      validator: (password) => password.contains(RegExp(r'[A-Z]')),
    ),
    SignupRequirement(
      description: 'At least one lowercase letter',
      validator: (password) => password.contains(RegExp(r'[a-z]')),
    ),
    SignupRequirement(
      description: 'At least one number',
      validator: (password) => password.contains(RegExp(r'[0-9]')),
    ),
    SignupRequirement(
      description: 'Passwords match',
      validator: (password) => false, // Will be handled separately
    ),
  ];

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }
  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      // Validate all requirements except the last one (password match)
      for (int i = 0; i < _passwordRequirements.length - 1; i++) {
        _passwordRequirements[i].isMet = _passwordRequirements[i].validator(password);
      }

      // Validate password match separately
      _passwordRequirements.last.isMet = 
          password.isNotEmpty && 
          confirmPassword.isNotEmpty && 
          password == confirmPassword;
    });
  }

  bool _allRequirementsMet() {
    return _passwordRequirements.every((requirement) => requirement.isMet);
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.white, 
        child: Container(
        width: 340,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: ThemeProvider.cardDecoration(context),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [                Text(
                  'Create an Account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headlineSmall?.color,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Name
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Name', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha((0.6 * 255).toInt())),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary(context), width: 2),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Username
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Username', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _usernameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    hintText: 'Choose a username',
                    hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha((0.6 * 255).toInt()),
                    ),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary(context), width: 2),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    // Check for valid username (letters, numbers, underscores only)
                    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
                    if (!usernameRegex.hasMatch(value)) {
                      return 'Username can only contain letters, numbers, and underscores';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Email
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ),
                const SizedBox(height: 6),TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha((0.6 * 255).toInt())),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary(context), width: 2),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ),
                const SizedBox(height: 6),                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha((0.6 * 255).toInt())),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary(context), width: 2),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (!_allRequirementsMet()) {
                      return 'Password does not meet all requirements';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Confirm Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ),
                const SizedBox(height: 6),                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha((0.6 * 255).toInt())),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary(context), width: 2),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password is required';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password Requirements
                Container(                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withAlpha((0.7 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 8),
                      ..._passwordRequirements.map((requirement) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [                                Icon(
                                  requirement.isMet ? Icons.check_circle : Icons.cancel,
                                  color: requirement.isMet ? AppColors.primary(context) : Theme.of(context).colorScheme.error,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(                                  child: Text(
                                    requirement.description,
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isLoading || !_allRequirementsMet()
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() != true) return;
                            
                            setState(() {
                              _isLoading = true;
                              _signUpError = null;
                            });                            final name = _nameController.text.trim();
                            final username = _usernameController.text.trim();
                            final email = _emailController.text.trim();
                            final password = _passwordController.text;                            try {
                              // Create the account with name and username and automatically sign in
                              await context.read<AuthProvider>().signUpWithEmail(
                                email, 
                                password,
                                displayName: name,
                                username: username
                              );
                              
                              if (mounted) {
                                // User is already logged in after signup because Firebase automatically
                                // signs in the user after account creation
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Account created successfully! You are now logged in.')),
                                );
                                
                                // Close the dialog and navigate to main page
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pop(); // Close the dialog
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const MainAppPage()),
                                );
                              }
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                                if (e.toString().contains('email-already-in-use')) {
                                  _signUpError = 'This email is already registered. Please sign in instead.';
                                } else {
                                  _signUpError = 'Sign up failed: ${e.toString()}';
                                }
                              });
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Create Account'),
                  ),
                ),
                // Error message display
                if (_signUpError != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _signUpError!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],                // Cancel Button
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.warning(context), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
