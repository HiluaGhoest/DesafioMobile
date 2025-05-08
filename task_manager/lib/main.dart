import 'package:task_manager/authentication/auth_service.dart';
import 'package:task_manager/screens/login_screen.dart';
import 'package:task_manager/util/colors/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Firebase is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized(); // Ensures widget binding is initialized
  
  try {
    Firebase.app(); // Tenta pegar o app padrão
  } catch (e) {
    // Se falhar, inicializa
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
      ],
      child: MainApp(),
    ),
  );
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: AppTheme.lightTheme,
      home: LoginScreen(),
    );
  }
}