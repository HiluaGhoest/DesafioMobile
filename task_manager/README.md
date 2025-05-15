# Task Manager App

A comprehensive Flutter-based task and activity management application that helps users organize their daily routines, track habits, and monitor their productivity.

## Features

### User Authentication
- Email and password authentication
- Google Sign-In integration
- Password reset functionality
- Account creation with email verification

### Task Management
- Create one-time tasks with name, description, date, and time
- View tasks organized by date
- Mark tasks as completed
- Edit existing tasks
- Delete tasks
- Filter tasks by completion status
- Search tasks by name or description

### Activity Management (Recurring Habits)
- Create recurring activities with multiple recurrence options:
  - Daily activities
  - Weekly activities (select specific days of the week)
  - Monthly activities (select specific day of month)
  - Custom interval activities (every X days)
- Track activity completion over time
- View activity streaks and statistics
- Enable/disable activities without deleting them
- Filter activities by status (active/inactive)

### Statistics and Analytics
- View comprehensive statistics about your productivity
- Weekly completion charts for tasks and activities
- Monthly completion trends
- Task completion rate analysis
- Activity streak tracking
- Visual representations using charts and graphs

### User Profile Management
- Update profile information
- Upload and update profile picture
- Change password
- View account usage statistics
- Theme customization options

### UI Features
- Intuitive day selector for navigating dates
- Clean, organized interface with tab navigation
- Responsive design for various screen sizes
- Optimized for portrait orientation

### Technical Features
- Firebase authentication and data storage
- Firestore database integration
- Analytics tracking for user engagement
- Persistent login sessions
- Optimized for Flutter

## Technology Stack

- **Framework**: Flutter
- **Programming Language**: Dart
- **Backend Services**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Analytics
  - Firebase Storage
- **State Management**: Provider
- **Visualization**: FL Chart
- **Date/Time Handling**: Intl package
- **Image Handling**: Image Picker

## Getting Started

1. Ensure you have Flutter installed on your machine
2. Clone this repository
3. Install dependencies with `flutter pub get`
4. Set up Firebase:
   - Create a new Firebase project
   - Enable Authentication (Email/Password and Google Sign-In)
   - Set up Firestore Database
   - Configure Firebase Storage
   - Add the Firebase configuration files:
     - For Android: Add `google-services.json` to `/android/app/`
     - For iOS: Add `GoogleService-Info.plist` to `/ios/Runner/`
5. Run the app with `flutter run`

## Project Structure

- **/lib**: Main source code
  - **/authentication**: Authentication-related code
  - **/data_models**: Data models for tasks, activities, etc.
  - **/screens**: UI screens
  - **/services**: Backend service integrations
  - **/util**: Utility functions and theme settings
  - **/widgets**: Reusable UI components
- **/assets**: Asset files (images, etc.)

## Deployment & Documentation

Additional documentation is available in the project:

- **[FIREBASE_DEPLOYMENT.md](FIREBASE_DEPLOYMENT.md)**: Instructions for deploying Firebase rules and security configurations.
- **[LOCAL_PROFILE_IMAGES.md](LOCAL_PROFILE_IMAGES.md)**: Documentation on how profile images are handled locally instead of in Firebase Storage.

## Implementation Details

### Authentication System
- **Multi-provider authentication** with both email/password and Google Sign-In
- **Session management** with persistent login state
- **Password reset** functionality for forgotten passwords
- **Account deletion** with confirmation security
- **Profile management** with user information updates

### Task System
The task system is built to handle one-time events with:
- **Complete CRUD operations** (Create, Read, Update, Delete)
- **Date and time scheduling** with intuitive date picker
- **Task priority management**
- **Task completion tracking** with statistics generation
- **Daily task organization** with a smooth day selector interface

### Activity/Habit System
The activities system handles recurring tasks with sophisticated recurrence patterns:
- **Multiple recurrence types**:
  - Daily activities that repeat every day
  - Weekly activities that repeat on specific days of the week
  - Monthly activities that repeat on specific days of the month
  - Custom interval activities that repeat every X days
- **Streak tracking** to monitor habit consistency
- **Activity history** to view past completions
- **Completion statistics** for motivation and accountability

### Statistics System
The statistics engine provides comprehensive insights:
- **Visual charts** for task and activity completion rates
- **Trend analysis** for weekly and monthly patterns
- **Completion rate metrics** with percentage calculations
- **Progress tracking** for continuous improvement
- **Time-based comparisons** to track improvements over time

### Local Storage Feature
- **Local profile image storage** instead of cloud storage
- **Efficient file management** for user assets
- **Reduced dependency** on Firebase Storage

## Future Enhancements

- Calendar view for better task visualization
- Task categories and tags
- Team collaboration features
- Data export and import functionality
- Dark mode support
- Push notifications for task reminders
- Custom themes
- Offline synchronization improvements
