import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Task {
  String? id;
  String name;
  String? description;
  DateTime date;
  TimeOfDay time;
  bool isCompleted;
  
  Task({
    this.id,
    required this.name,
    this.description,
    required this.date,
    required this.time,
    this.isCompleted = false,
  });
    // Convert Task to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'date': Timestamp.fromDate(date),
      'time': {
        'hour': time.hour,
        'minute': time.minute
      },
      'isCompleted': isCompleted,
    };
  }
  
  // Create a Task from a Firestore document
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
      time: TimeOfDay(
        hour: data['time']['hour'], 
        minute: data['time']['minute']
      ),
      isCompleted: data['isCompleted'] ?? false,
    );
  }
  
  // Create a copy of the task with updated fields
  Task copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
