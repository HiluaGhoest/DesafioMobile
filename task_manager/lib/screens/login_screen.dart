import 'package:task_manager/authentication/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:task_manager/util/theme_provider.dart';
import 'dart:ui';
import 'package:task_manager/screens/main_app_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  String? _loginError;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: ThemeProvider.backgroundGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  decoration: BoxDecoration(
                    color: ThemeProvider.primaryButton.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Icon(
                    Icons.eco_rounded,
                    color: ThemeProvider.primaryButton,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 32),
                // Card
                Container(
                  width: 340,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: ThemeProvider.cardDecoration(context).copyWith(
                    color: Colors.white.withOpacity(0.7), // Less transparent
                    backgroundBlendMode: BlendMode.overlay,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Welcome Back',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Google Sign-In Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: ThemeProvider.googleButtonBorder),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () async {
                                        setState(() {
                                          _loginError = null;
                                        });
                                        try {
                                          final success = await context.read<AuthProvider>().signInWithGoogle();
                                          if (success && mounted) {
                                            print('Google sign-in successful');
                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(builder: (_) => MainAppPage()),
                                            );
                                          }
                                        } catch (e) {
                                          print('Google sign-in failed: $e');
                                          setState(() {
                                            _loginError = 'Google sign-in failed: ${e.toString()}';
                                          });
                                        }
                                      },
                                icon: Image.asset(
                                  ThemeProvider.googleLogo,
                                  height: 22,
                                ),
                                label: const Text('Continue with Google'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: const [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('or'),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Email
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Email', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Enter your email',
                                border: OutlineInputBorder(),
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
                              child: Text('Password', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Enter your password',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            // Remember Me and Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value!;
                                        });
                                      },
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const Text('Remember me', style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final email = _emailController.text.trim();
                                    if (email.isEmpty) {
                                      setState(() {
                                        _loginError = 'Please enter your email to reset your password.';
                                      });
                                      return;
                                    }
                                    try {
                                      await context.read<AuthProvider>().sendPasswordResetEmail(email);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Password reset email sent!')),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        _loginError = 'Failed to send password reset email: ${e.toString()}';
                                      });
                                    }
                                  },
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: ThemeProvider.forgotPassword,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ThemeProvider.primaryButton,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() != true) return;
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text;
                                  setState(() {
                                    _loginError = null;
                                  });
                                  try {
                                    final success = await context.read<AuthProvider>().signInWithEmail(email, password);
                                    if (success && mounted) {
                                      print('Login successful');
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (_) => MainAppPage()),
                                      );
                                    }
                                  } catch (e) {
                                    print('Login failed: $e');
                                    setState(() {
                                      _loginError = 'Login failed: credentials are incorrect or user does not exist, please sign up first';
                                    });
                                  }
                                },
                                child: const Text('Sign In'),
                              ),
                            ),
                            // Error message display
                            if (_loginError != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                _loginError!,
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign Up Link
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(color: ThemeProvider.signUpGreen, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Handle sign up navigation
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
    );
  }
}