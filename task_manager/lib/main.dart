import 'package:task_manager/authentication/auth_service.dart' as app_auth;
import 'package:task_manager/screens/login_screen.dart';
import 'package:task_manager/screens/main_app_page.dart';
import 'package:task_manager/util/colors/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Firebase is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Set preferred orientations for better UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  try {
    Firebase.app(); // Try to get the default Firebase app
  } catch (e) {
    // If it fails, initialize Firebase with our configuration
    await Firebase.initializeApp(
      name: 'task_manager',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  // Initialize Firebase Analytics
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => app_auth.AuthService()),
        Provider<FirebaseAnalytics>(create: (_) => analytics),
        ChangeNotifierProvider(
          create: (context) => app_auth.AuthProvider(context.read<app_auth.AuthService>()),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

/// Main application widget that configures theme and handles authentication state
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MainAppWithProviders();
  }
}

class _MainAppWithProviders extends StatelessWidget {
  const _MainAppWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    // Get analytics instance from provider
    final analytics = Provider.of<FirebaseAnalytics>(context, listen: false);
    // Create analytics observer for route tracking
    final observer = FirebaseAnalyticsObserver(analytics: analytics);

    return MaterialApp(
      title: 'Task Manager',
      theme: AppTheme.lightTheme,
      // Add analytics observer
      navigatorObservers: [observer],
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // If user is logged in
            if (snapshot.hasData) {
              // Log user login event
              analytics.logLogin();
              return const MainAppPage();
            }

            // If user is not logged in
            return const LoginScreen();
          }

          // While checking authentication state
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}