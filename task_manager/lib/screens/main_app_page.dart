import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/data_models/activity.dart';
import 'package:task_manager/data_models/task.dart';
import 'package:task_manager/screens/account_settings_screen.dart';
import 'package:task_manager/screens/activities_screen.dart';
import 'package:task_manager/screens/login_screen.dart';
import 'package:task_manager/screens/settings_screen.dart';
import 'package:task_manager/screens/statistics_screen.dart';
import 'package:task_manager/services/activity_service.dart';
import 'package:task_manager/services/task_service.dart';
import 'package:task_manager/util/theme_provider.dart';
import 'package:task_manager/widgets/day_selector.dart';
import 'package:task_manager/widgets/task_card.dart';
import 'package:task_manager/widgets/task_dialog.dart';
import 'package:task_manager/util/colors/app_colors.dart';

class MainAppPage extends StatefulWidget {
  const MainAppPage({super.key});

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  final TaskService _taskService = TaskService();
  final ActivityService _activityService = ActivityService();
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    // Check authentication state after the widget is properly mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });
  }

  void _checkAuthState() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        onSave: (task) {
          _taskService.addTask(task);
        },
      ),
    );
  }
  
  void _showEditTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        onSave: (updatedTask) {
          _taskService.updateTask(updatedTask);
        },
      ),
    );
  }
  
  void _deleteTask(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _taskService.deleteTask(taskId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
    void _toggleTaskCompletion(Task task, bool isCompleted) {
    _taskService.toggleTaskCompletion(task.id!, isCompleted);
  }
  
  void _markActivityCompleted(Activity activity) {
    if (activity.id != null) {
      _activityService.markActivityCompleted(activity.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${activity.name} marked as completed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current user from Firebase - moved outside of build method
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Tasks', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary(context),
        iconTheme: const IconThemeData(color: Colors.white), // This controls the sidebar button color
        elevation: 0,
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: Provider.of<ThemeProvider>(context).backgroundGradient,
          ),
          child: Column(
            children: [
              // Task Manager Title
              Container(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary(context).withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Task Manager',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Organize your day',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Drawer items
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  Icons.calendar_today, 
                  color: AppColors.primary(context),
                ),
                title: const Text(
                  'Calendar', 
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to calendar screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calendar screen will be implemented soon')),
                  );
                },
              ),
                ListTile(
                leading: Icon(
                  Icons.list_alt, 
                  color: AppColors.primary(context),
                ),
                title: const Text(
                  'Activities',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to activities screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ActivitiesScreen()),
                  );
                },
              ),
                ListTile(
                leading: Icon(
                  Icons.bar_chart, 
                  color: AppColors.primary(context),
                ),
                title: const Text(
                  'Statistics',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to statistics screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                  );
                },
              ),
              
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: AppColors.primary(context),
                ),
                title: const Text(
                  'Settings',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to settings screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              
              // Divider
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(thickness: 1),
              ),
              
              // Logout Option
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.redAccent.shade200,
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.redAccent.shade200,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  FirebaseAuth.instance.signOut();
                },
              ),
              
              // Spacer to push the user profile to the bottom
              const Spacer(),
              
              // User profile at the bottom - clickable to go to account settings
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  border: const Border(
                    top: BorderSide(color: Color(0xFFE8E3DC)),
                  ),
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
                        // Account bubble/avatar with green border
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary(context),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: user?.photoURL != null 
                                ? NetworkImage(user!.photoURL!) 
                                : null,
                            child: user?.photoURL == null 
                                ? Text(
                                    (user?.displayName?.isNotEmpty == true 
                                        ? user!.displayName![0] 
                                        : 'U'),
                                    style: TextStyle(
                                      color: AppColors.primary(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user?.displayName ?? 'User Profile', 
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'Account Settings',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.surface(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Provider.of<ThemeProvider>(context).backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message with styled container
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.waving_hand,
                          color: AppColors.primary(context),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Welcome, ${user?.displayName?.split(' ').first ?? 'User'}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Here are your tasks and activities for today',
                        style: TextStyle(
                          fontSize: 16,                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                // Day selector with styled container
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: DaySelector(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
              ),
              
              // Activities due today section (only shown when current date is selected)
              if (DateFormat('yyyy-MM-dd').format(_selectedDate) == 
                  DateFormat('yyyy-MM-dd').format(DateTime.now()))
              StreamBuilder<List<Activity>>(
                stream: _activityService.getActivitiesDueToday(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return const SizedBox();
                  }
                  
                  final activities = snapshot.data ?? [];
                  if (activities.isEmpty) {
                    return const SizedBox();
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Activities Due Today',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ActivitiesScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary(context),
                              ),
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 140,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final activity = activities[index];
                            
                            // Check if already completed today
                            bool completedToday = false;
                            if (activity.lastCompletionDate != null) {
                              final now = DateTime.now();
                              final lastCompletion = activity.lastCompletionDate!;
                              completedToday = lastCompletion.year == now.year &&
                                  lastCompletion.month == now.month &&
                                  lastCompletion.day == now.day;
                            }
                            
                            return Container(
                              width: 210,
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                color: completedToday
                                    ? AppColors.primary(context).withOpacity(0.1)
                                    : Colors.white,
                                border: completedToday
                                    ? Border.all(
                                        color: AppColors.primary(context).withOpacity(0.5),
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: completedToday
                                                    ? Colors.green
                                                    : Colors.orange,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              activity.time.format(context),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          activity.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            decoration: completedToday
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          activity.getRecurrenceDescription(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const Spacer(),
                                        if (!completedToday)
                                          TextButton.icon(
                                            onPressed: () => _markActivityCompleted(activity),
                                            icon: const Icon(Icons.check, size: 16),
                                            label: const Text('Complete'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.primary(context),
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              minimumSize: const Size(0, 28),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          )
                                        else
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 14,
                                                color: Colors.green,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Completed',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (context) => Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(Icons.visibility),
                                                title: const Text('View Details'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const ActivitiesScreen()),
                                                  );
                                                },
                                              ),
                                              if (!completedToday)
                                                ListTile(
                                                  leading: const Icon(Icons.check),
                                                  title: const Text('Mark Completed'),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    _markActivityCompleted(activity);
                                                  },
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(
                        indent: 16,
                        endIndent: 16,
                      ),
                    ],
                  );
                },
              ),
              
              // Task list for selected date
              Expanded(child: StreamBuilder<List<Task>>(
                  stream: _taskService.getTasksForDate(_selectedDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary(context)),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading tasks...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                      if (snapshot.hasError) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading tasks',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                snapshot.error.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    // Force refresh
                                  });
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary(context),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    final tasks = snapshot.data ?? [];
                      if (tasks.isEmpty) {
                      // Format the selected date for display
                      final dateFormat = DateFormat('EEEE, MMMM d');
                      final formattedDate = dateFormat.format(_selectedDate);
                      final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
                          DateFormat('yyyy-MM-dd').format(DateTime.now());
                      
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary(context).withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Icon(
                                    isToday ? Icons.today : Icons.event_available,
                                    size: 60,
                                    color: AppColors.primary(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                isToday ? 'Your day looks clear!' : 'No tasks for this day',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF505050),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isToday 
                                    ? 'You have no tasks scheduled for today.'
                                    : 'Nothing scheduled for $formattedDate.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: _showAddTaskDialog,
                                icon: const Icon(Icons.add),
                                label: Text(isToday ? 'Add a task for today' : 'Schedule a task'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary(context),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(
                            task: task,
                            onEditPressed: () => _showEditTaskDialog(task),
                            onDeletePressed: () => _deleteTask(task.id!),
                            onCompletionToggled: (isCompleted) => 
                                _toggleTaskCompletion(task, isCompleted),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Task option
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showAddTaskDialog();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primary(context).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.task_alt,
                                color: AppColors.primary(context),
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Task'),
                          ],
                        ),
                      ),
                      
                      // Activity option
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ActivitiesScreen(),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primary(context).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.repeat,
                                color: AppColors.primary(context),
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Activity'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create'),
      ),
    );
  }
}
