# Local Profile Images Implementation

This document explains how the app handles profile images locally instead of using Firebase Storage.

## Overview

The app now saves profile photos to the device's local storage instead of using Firebase Storage. This was implemented to avoid the need for a Firebase Storage subscription.

## Implementation Details

1. **LocalStorageService**: A new service that handles saving, retrieving, and deleting profile images from local storage.
   - Uses the `path_provider` package to access the application's documents directory
   - Creates a dedicated folder for profile images
   - Images are saved with the user's ID as the filename

2. **UserProfileService**: Modified to work with local file paths instead of Firebase Storage URLs
   - Profile photos are now stored as file URIs (e.g., `file:///data/user/0/com.mycompany.task_manager/app_flutter/profile_images/user123.jpg`)
   - The Firestore `photoUrl` field still stores the path, but now it points to a local file

3. **UI Components**: Updated to handle both local files and remote URLs
   - `CircleAvatar` widgets check if the URL starts with "file://" and use `FileImage` or `NetworkImage` accordingly
   - This ensures backward compatibility with existing Google account profile photos

## How to Use

No changes are needed from the user's perspective. The app will automatically:
- Save uploaded profile photos to local storage
- Display profile photos from local storage
- Clean up local storage when photos are deleted or accounts are removed

## Benefits

- Reduced cloud storage costs
- Works offline
- Faster image loading
- Reduced network usage

## Limitations

- Profile photos are device-specific and won't sync across devices
- If the app is uninstalled, profile photos will be lost

## Technical Details

### File Structure

```
/app_documents/
  /profile_images/
    /{user_id}.jpg
```

### Image Formats

Profile images are stored as JPG files with the following specifications:
- Resolution: Limited to 800x800 maximum
- Quality: 85%
- Storage location: App documents directory
