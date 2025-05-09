import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/screens/account_settings_screen.dart';
import 'package:task_manager/screens/login_screen.dart';

class MainAppPage extends StatelessWidget {
  const MainAppPage({super.key});
  
  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You have $count ${title.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right, size: 20),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    // Get current user from Firebase
    final user = FirebaseAuth.instance.currentUser;
    
    // Redirect to login if user is not logged in
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main App Page'),
      ),      drawer: Drawer(
        child: Column(
          children: [
            // Drawer header
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.displayName ?? 'User', 
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                user?.email ?? '',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user?.photoURL != null 
                    ? user!.photoURL!.startsWith('file://')
                        ? FileImage(File(user.photoURL!.replaceFirst('file://', '')))
                        : NetworkImage(user.photoURL!) as ImageProvider
                    : null,
                child: user?.photoURL == null 
                    ? Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor)
                    : null,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              otherAccountsPictures: [
                IconButton(
                  icon: const Icon(Icons.brightness_6, color: Colors.white),
                  onPressed: () {
                    // Theme toggle button
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Theme toggle will be implemented soon')),
                    );
                  },
                ),
              ],
            ),
            
            // Drawer items
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tasks'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to tasks screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tasks screen will be implemented soon')),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to categories screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Categories screen will be implemented soon')),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to analytics screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analytics screen will be implemented soon')),
                );
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to settings screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings screen will be implemented soon')),
                );
              },
            ),
            
            // Spacer to push the user profile to the bottom
            const Spacer(),
            
            const Divider(),
              // User profile at the bottom - clickable to go to account settings
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
                color: Colors.grey.shade100,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountSettingsScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).primaryColor.withAlpha((0.2 * 255).toInt()),
                            backgroundImage: user?.photoURL != null 
                                ? NetworkImage(user!.photoURL!) 
                                : null,
                            child: user?.photoURL == null 
                                ? Icon(Icons.person, size: 24, color: Theme.of(context).primaryColor)
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              width: 10,
                              height: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user?.displayName ?? 'User',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Account Settings',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt()),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Welcome, ${user?.displayName?.split(' ').first ?? 'User'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here\'s your task summary for today',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // Task summary cards
              Expanded(
                child: ListView(
                  children: [
                    _buildSummaryCard(
                      context,
                      title: 'Today\'s Tasks',
                      count: '5',
                      icon: Icons.today,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      context,
                      title: 'Upcoming Tasks',
                      count: '12',
                      icon: Icons.upcoming,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      context,
                      title: 'Completed Tasks',
                      count: '32',
                      icon: Icons.task_alt,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new task
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add task functionality will be implemented soon')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
