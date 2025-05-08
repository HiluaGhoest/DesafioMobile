import 'package:flutter/material.dart';

class MainAppPage extends StatelessWidget {
  const MainAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main App Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Main App!'),
      ),
    );
  }
}
