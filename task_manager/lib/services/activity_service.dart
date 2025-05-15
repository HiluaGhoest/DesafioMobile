import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:task_manager/data_models/activity.dart';
import 'package:flutter/material.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;
  
  // Collection reference
  CollectionReference<Map<String, dynamic>> get _activitiesCollection => 
      _firestore.collection('users').doc(_userId).collection('activities');
      
  // Get all activities for the current user
  Stream<List<Activity>> getActivities() {
    if (_userId == null) return Stream.value([]);
    
    return _activitiesCollection
      .orderBy('startDate')
      .orderBy('time.hour')
      .orderBy('time.minute')
      .snapshots()
      .map((snapshot) => 
        snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList()
      );
  }
  
  // Get activities that are active and due today
  Stream<List<Activity>> getActivitiesDueToday() {
    if (_userId == null) return Stream.value([]);
    
    // First fetch all active activities
    return _activitiesCollection
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        final activities = snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
        // Then filter for those due today based on their recurrence pattern
        return activities.where((activity) => activity.isDueToday()).toList();
      });
  }
  
  // Add a new activity
  Future<void> addActivity(Activity activity) async {
    if (_userId == null) return;
    
    try {
      // Add activity to Firestore
      await _activitiesCollection.add(activity.toMap());
      
      // Log event to analytics
      await _analytics.logEvent(
        name: 'activity_created',
        parameters: {
          'activity_name': activity.name,
          'recurrence_type': activity.recurrenceType.toString().split('.').last,
          'has_description': (activity.description != null && activity.description!.isNotEmpty) ? '1' : '0',
        },
      );
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'activity_creation_error',
        parameters: {
          'error_message': e.toString(),
        },
      );
      rethrow;
    }
  }
  
  // Update an existing activity
  Future<void> updateActivity(Activity activity) async {
    if (_userId == null || activity.id == null) return;
    
    try {
      // Update activity in Firestore
      await _activitiesCollection.doc(activity.id).update(activity.toMap());
      
      // Log event to analytics
      await _analytics.logEvent(
        name: 'activity_updated',
        parameters: {
          'activity_id': activity.id ?? 'unknown',
          'activity_name': activity.name,
        },
      );
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'activity_update_error',
        parameters: {
          'error_message': e.toString(),
          'activity_id': activity.id ?? 'unknown',
        },
      );
      rethrow;
    }
  }
  
  // Delete an activity
  Future<void> deleteActivity(String activityId) async {
    if (_userId == null) return;
    
    try {
      // Delete activity from Firestore
      await _activitiesCollection.doc(activityId).delete();
      
      // Log event to analytics
      await _analytics.logEvent(
        name: 'activity_deleted',
        parameters: {
          'activity_id': activityId,
        },
      );
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'activity_deletion_error',
        parameters: {
          'error_message': e.toString(),
          'activity_id': activityId,
        },
      );
      rethrow;
    }
  }
  
  // Toggle activity active status
  Future<void> toggleActivityStatus(String activityId, bool isActive) async {
    if (_userId == null) return;
    
    try {
      // Update activity status in Firestore
      await _activitiesCollection.doc(activityId).update({'isActive': isActive});
      
      // Log event to analytics
      await _analytics.logEvent(
        name: 'activity_status_toggled',
        parameters: {
          'activity_id': activityId,
          'is_active': isActive ? '1' : '0',
        },
      );
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'activity_status_toggle_error',
        parameters: {
          'error_message': e.toString(),
          'activity_id': activityId,
        },
      );
      rethrow;
    }
  }
  
  // Mark an activity as completed for today
  Future<void> markActivityCompleted(String activityId) async {
    if (_userId == null) return;
    
    try {
      // Get the current activity
      final activityDoc = await _activitiesCollection.doc(activityId).get();
      if (!activityDoc.exists) {
        throw Exception('Activity not found');
      }
      
      final activity = Activity.fromFirestore(activityDoc);
      
      // Update completion info
      final updatedActivity = activity.copyWith(
        completionCount: activity.completionCount + 1,
        lastCompletionDate: DateTime.now(),
      );
      
      // Update in Firestore
      await _activitiesCollection.doc(activityId).update({
        'completionCount': updatedActivity.completionCount,
        'lastCompletionDate': Timestamp.fromDate(updatedActivity.lastCompletionDate!),
      });
      
      // Log event to analytics
      await _analytics.logEvent(
        name: 'activity_completed',
        parameters: {
          'activity_id': activityId,
          'completion_count': updatedActivity.completionCount.toString(),
        },
      );
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'activity_completion_error',
        parameters: {
          'error_message': e.toString(),
          'activity_id': activityId,
        },
      );
      rethrow;
    }
  }
  
  // Get activity statistics
  Future<Map<String, dynamic>> getActivityStatistics() async {
    if (_userId == null) return {};
    
    try {
      // Get all activities
      final activitiesSnapshot = await _activitiesCollection.get();
      final activities = activitiesSnapshot.docs
          .map((doc) => Activity.fromFirestore(doc))
          .toList();
      
      // Calculate statistics
      int totalActivities = activities.length;
      int activeActivities = activities.where((activity) => activity.isActive).length;
      int totalCompletions = activities
          .fold(0, (sum, activity) => sum + activity.completionCount);
      
      // Activities due today
      int activitiesDueToday = activities
          .where((activity) => activity.isActive && activity.isDueToday())
          .length;
      
      // Activities completed today
      int activitiesCompletedToday = activities
          .where((activity) {
            if (activity.lastCompletionDate == null) return false;
            final now = DateTime.now();
            final completionDate = activity.lastCompletionDate!;
            return completionDate.year == now.year && 
                  completionDate.month == now.month && 
                  completionDate.day == now.day;
          })
          .length;
      
      // Log statistics viewing to analytics
      await _analytics.logEvent(
        name: 'activity_statistics_viewed',
        parameters: {
          'total_activities': totalActivities.toString(),
          'active_activities': activeActivities.toString(),
          'total_completions': totalCompletions.toString(),
        },
      );
      
      // Return statistics
      return {
        'totalActivities': totalActivities,
        'activeActivities': activeActivities,
        'totalCompletions': totalCompletions,
        'activitiesDueToday': activitiesDueToday,
        'activitiesCompletedToday': activitiesCompletedToday,
        'completionRate': activitiesDueToday > 0 
            ? activitiesCompletedToday / activitiesDueToday 
            : 0.0,
      };
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'activity_statistics_error',
        parameters: {
          'error_message': e.toString(),
        },
      );
      rethrow;
    }
  }
  
  // Get number of activity completions for a specific date
  Future<int> getCompletionsForDate(DateTime date) async {
    if (_userId == null) return 0;
    
    try {
      // Get all activities first
      final activitiesSnapshot = await _activitiesCollection.get();
      final activities = activitiesSnapshot.docs
          .map((doc) => Activity.fromFirestore(doc))
          .toList();
      
      // Count activities completed on the specified date
      int completions = activities.where((activity) {
        if (activity.lastCompletionDate == null) return false;
        final completionDate = activity.lastCompletionDate!;
        return completionDate.year == date.year && 
               completionDate.month == date.month && 
               completionDate.day == date.day;
      }).length;
      
      return completions;
    } catch (e) {
      // Log error to analytics
      await _analytics.logEvent(
        name: 'activity_completion_count_error',
        parameters: {
          'error_message': e.toString(),
          'date': date.toString(),
        },
      );
      return 0; // Return 0 on error
    }
  }
}
