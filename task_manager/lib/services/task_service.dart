import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:task_manager/data_models/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;
  
  // Collection reference
  CollectionReference<Map<String, dynamic>> get _tasksCollection => 
      _firestore.collection('users').doc(_userId).collection('tasks');
      
  // Get all tasks for the current user
  Stream<List<Task>> getTasks() {
    if (_userId == null) return Stream.value([]);
    
    return _tasksCollection
      .orderBy('date')
      .orderBy('time.hour')
      .orderBy('time.minute')
      .snapshots()
      .map((snapshot) => 
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList()
      );
  }
  
  // Get tasks for a specific date
  Stream<List<Task>> getTasksForDate(DateTime date) {
    if (_userId == null) return Stream.value([]);
    
    // Start of the day
    DateTime startDate = DateTime(date.year, date.month, date.day);
    // End of the day
    DateTime endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _tasksCollection
      .where('date', isGreaterThanOrEqualTo: startDate)
      .where('date', isLessThanOrEqualTo: endDate)
      .orderBy('date')
      .orderBy('time.hour')
      .orderBy('time.minute')
      .snapshots()
      .map((snapshot) => 
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList()
      );
  }
    
  // Add a new task
  Future<void> addTask(Task task) async {
    if (_userId == null) return;
    
    try {
      // Add task to Firestore
      await _tasksCollection.add(task.toMap());
        // Log event to analytics
      await _analytics.logEvent(
        name: 'task_created',
        parameters: {
          'task_name': task.name,
          'task_date': task.date.toString(),
          'has_description': (task.description != null && task.description!.isNotEmpty) ? '1' : '0', // Convert boolean to string
        },
      );
      
      // Return with success
      return;
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'task_creation_error',
        parameters: {
          'error_message': e.toString(),
        },
      );
      rethrow; // Rethrow to let UI handle the error
    }
  }
    
  // Update an existing task
  Future<void> updateTask(Task task) async {
    if (_userId == null || task.id == null) return;
    
    try {
      // Update task in Firestore
      await _tasksCollection.doc(task.id).update(task.toMap());
      
      // Log event to analytics
      await _analytics.logEvent(
        name: 'task_updated',
        parameters: {
          'task_id': task.id ?? 'unknown',
          'task_name': task.name,
        },
      );
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'task_update_error',
        parameters: {
          'error_message': e.toString(),
          'task_id': task.id ?? 'unknown',
        },
      );
      rethrow;
    }
  }
    
  // Delete a task
  Future<void> deleteTask(String taskId) async {
    if (_userId == null) return;
    
    try {
      // Delete task from Firestore
      await _tasksCollection.doc(taskId).delete();
      
      // Log event to analytics
      await _analytics.logEvent(
        name: 'task_deleted',
        parameters: {
          'task_id': taskId,
        },
      );
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'task_deletion_error',
        parameters: {
          'error_message': e.toString(),
          'task_id': taskId,
        },
      );
      rethrow;
    }
  }
    
  // Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    if (_userId == null) return;
    
    try {
      // Update task completion status in Firestore
      await _tasksCollection.doc(taskId).update({'isCompleted': isCompleted});
        // Log event to analytics
      await _analytics.logEvent(
        name: 'task_completion_toggled',
        parameters: {
          'task_id': taskId,
          'is_completed': isCompleted ? '1' : '0', // Convert boolean to string
        },
      );
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'task_completion_toggle_error',
        parameters: {
          'error_message': e.toString(),
          'task_id': taskId,
        },
      );
      rethrow;
    }
  }
  
  // Get task statistics with optional days parameter
  Future<Map<String, dynamic>> getTaskStatistics([int daysToCheck = 30]) async {
    if (_userId == null) return {};
    
    try {
      // Get start date (n days ago)
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day - daysToCheck);
      
      // Query tasks created since startDate
      final tasksSnapshot = await _tasksCollection
          .where('date', isGreaterThanOrEqualTo: startDate)
          .get();
          
      final tasks = tasksSnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      
      // Calculate statistics
      int totalTasks = tasks.length;
      int completedTasks = tasks.where((task) => task.isCompleted).length;
      double completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0;
      
      // Get tasks due today
      final today = DateTime.now();
      final startOfToday = DateTime(today.year, today.month, today.day);
      final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);
      
      final tasksDueToday = tasks.where((task) => 
        task.date.isAfter(startOfToday.subtract(const Duration(milliseconds: 1))) && 
        task.date.isBefore(endOfToday.add(const Duration(milliseconds: 1)))
      ).length;
      
      // Get tasks completed today
      final tasksCompletedToday = tasks.where((task) => 
        task.isCompleted && 
        task.date.isAfter(startOfToday.subtract(const Duration(milliseconds: 1))) && 
        task.date.isBefore(endOfToday.add(const Duration(milliseconds: 1)))
      ).length;
      
      // Log statistics viewing to analytics
      await _analytics.logEvent(
        name: 'task_statistics_viewed',
        parameters: {
          'days_analyzed': daysToCheck,
          'total_tasks': totalTasks,
          'completion_rate': completionRate.toString(), // Convert double to string
        },
      );
      
      // Return statistics
      return {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'pendingTasks': totalTasks - completedTasks,
        'completionRate': completionRate,
        'period': daysToCheck,
        'tasksDueToday': tasksDueToday,
        'tasksCompletedToday': tasksCompletedToday,
      };
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'statistics_calculation_error',
        parameters: {
          'error_message': e.toString(),
          'days_to_check': daysToCheck,
        },
      );
      rethrow;
    }
  }
  
  // Get number of completed tasks for a specific date
  Future<int> getCompletedTasksForDate(DateTime date) async {
    if (_userId == null) return 0;
    
    try {
      // Start of the day
      DateTime startDate = DateTime(date.year, date.month, date.day);
      // End of the day
      DateTime endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      // Query tasks for the specific date and that are completed
      final tasksSnapshot = await _tasksCollection
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .where('isCompleted', isEqualTo: true)
        .get();
        
      // Return count of completed tasks
      return tasksSnapshot.docs.length;
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'task_completion_count_error',
        parameters: {
          'error_message': e.toString(),
          'date': date.toString(),
        },
      );
      return 0; // Return 0 on error
    }
  }
}
