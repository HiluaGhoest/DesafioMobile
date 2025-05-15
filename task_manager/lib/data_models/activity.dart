import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum RecurrenceType {
  daily,
  weekly,
  monthly,
  custom
}

class Activity {
  String? id;
  String name;
  String? description;
  DateTime startDate;
  TimeOfDay time;
  RecurrenceType recurrenceType;
  int? customIntervalDays; // Used when recurrenceType is custom
  List<int>? selectedDaysOfWeek; // Used for weekly recurrence (1-7 for Monday-Sunday)
  int? selectedDayOfMonth; // Used for monthly recurrence
  bool isActive;
  int completionCount; // Number of times the activity has been completed
  DateTime? lastCompletionDate;
  
  Activity({
    this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.time,
    required this.recurrenceType,
    this.customIntervalDays,
    this.selectedDaysOfWeek,
    this.selectedDayOfMonth,
    this.isActive = true,
    this.completionCount = 0,
    this.lastCompletionDate,
  });
  
  // Convert Activity to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'time': {
        'hour': time.hour,
        'minute': time.minute
      },
      'recurrenceType': recurrenceType.toString().split('.').last,
      'customIntervalDays': customIntervalDays,
      'selectedDaysOfWeek': selectedDaysOfWeek,
      'selectedDayOfMonth': selectedDayOfMonth,
      'isActive': isActive,
      'completionCount': completionCount,
      'lastCompletionDate': lastCompletionDate != null 
          ? Timestamp.fromDate(lastCompletionDate!) 
          : null,
    };
  }
  
  // Create an Activity from a Firestore document
  factory Activity.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Parse recurrence type
    RecurrenceType recurrenceType = RecurrenceType.daily;
    try {
      recurrenceType = RecurrenceType.values.firstWhere(
        (e) => e.toString().split('.').last == data['recurrenceType'],
        orElse: () => RecurrenceType.daily,
      );
    } catch (e) {
      // Default to daily if there's an error
      recurrenceType = RecurrenceType.daily;
    }
    
    // Parse days of week if exists
    List<int>? daysOfWeek;
    if (data['selectedDaysOfWeek'] != null) {
      daysOfWeek = List<int>.from(data['selectedDaysOfWeek']);
    }
    
    // Parse last completion date if exists
    DateTime? lastCompletionDate;
    if (data['lastCompletionDate'] != null) {
      lastCompletionDate = (data['lastCompletionDate'] as Timestamp).toDate();
    }
    
    return Activity(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      time: TimeOfDay(
        hour: data['time']['hour'] ?? 0, 
        minute: data['time']['minute'] ?? 0
      ),
      recurrenceType: recurrenceType,
      customIntervalDays: data['customIntervalDays'],
      selectedDaysOfWeek: daysOfWeek,
      selectedDayOfMonth: data['selectedDayOfMonth'],
      isActive: data['isActive'] ?? true,
      completionCount: data['completionCount'] ?? 0,
      lastCompletionDate: lastCompletionDate,
    );
  }
  
  // Check if the activity is due today based on its recurrence pattern
  bool isDueToday() {
    final today = DateTime.now();
    
    // If it's not active, it's not due
    if (!isActive) return false;
    
    // If it hasn't started yet, it's not due
    if (startDate.isAfter(DateTime(today.year, today.month, today.day))) {
      return false;
    }
    
    // Check based on recurrence type
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return true;
      
      case RecurrenceType.weekly:
        // Check if today's day of week is in the selected days
        if (selectedDaysOfWeek == null || selectedDaysOfWeek!.isEmpty) {
          // If no specific days set, use the day of week from start date
          return today.weekday == startDate.weekday;
        } else {
          return selectedDaysOfWeek!.contains(today.weekday);
        }
      
      case RecurrenceType.monthly:
        // Check if today's day of month matches the selected day
        if (selectedDayOfMonth == null) {
          // If no specific day set, use the day of month from start date
          return today.day == startDate.day;
        } else {
          return today.day == selectedDayOfMonth;
        }
      
      case RecurrenceType.custom:
        if (customIntervalDays == null || customIntervalDays! <= 0) {
          return false;
        }
        
        // Check if today is a multiple of the interval away from the start date
        final diffDays = today.difference(
          DateTime(startDate.year, startDate.month, startDate.day)
        ).inDays;
        
        return diffDays % customIntervalDays! == 0;
    }
  }
  
  // Create a copy of the activity with updated fields
  Activity copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    TimeOfDay? time,
    RecurrenceType? recurrenceType,
    int? customIntervalDays,
    List<int>? selectedDaysOfWeek,
    int? selectedDayOfMonth,
    bool? isActive,
    int? completionCount,
    DateTime? lastCompletionDate,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      time: time ?? this.time,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      selectedDaysOfWeek: selectedDaysOfWeek ?? this.selectedDaysOfWeek,
      selectedDayOfMonth: selectedDayOfMonth ?? this.selectedDayOfMonth,
      isActive: isActive ?? this.isActive,
      completionCount: completionCount ?? this.completionCount,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
    );
  }
  
  // Get a human-readable description of the recurrence pattern
  String getRecurrenceDescription() {
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return 'Daily';
      
      case RecurrenceType.weekly:
        if (selectedDaysOfWeek == null || selectedDaysOfWeek!.isEmpty) {
          return 'Weekly on ${_getDayName(startDate.weekday)}';
        } else {
          final daysText = selectedDaysOfWeek!
              .map((day) => _getDayName(day).substring(0, 3))
              .join(', ');
          return 'Weekly on $daysText';
        }
      
      case RecurrenceType.monthly:
        final day = selectedDayOfMonth ?? startDate.day;
        return 'Monthly on day $day';
      
      case RecurrenceType.custom:
        if (customIntervalDays == null || customIntervalDays! <= 0) {
          return 'Invalid recurrence';
        } else if (customIntervalDays == 1) {
          return 'Daily';
        } else {
          return 'Every $customIntervalDays days';
        }
    }
  }
  
  // Helper function to get day name from weekday number
  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (weekday >= 1 && weekday <= 7) {
      return days[weekday - 1];
    }
    return '';
  }
}
