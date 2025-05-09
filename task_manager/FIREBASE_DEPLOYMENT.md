# Firebase Rules Deployment Guide

This guide explains how to deploy the Firebase security rules for Firestore and Storage.

## Prerequisites

1. Make sure you have the Firebase CLI installed:
```bash
npm install -g firebase-tools
```

2. Make sure you're logged into Firebase:
```bash
firebase login
```

## Deploy the Rules

To deploy Firestore rules and indexes, run:

```bash
firebase deploy --only firestore
```

If you want to deploy them separately:

### Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Deploy Firestore Indexes
```bash
firebase deploy --only firestore:indexes
```

## Verify Deployment

After deployment, you can verify your rules in the Firebase Console:

1. Firestore Rules: Go to Firestore Database > Rules
2. Firestore Indexes: Go to Firestore Database > Indexes

## Testing the Rules

It's recommended to test your security rules with the Firebase Emulator Suite:

```bash
firebase emulators:start
```

This will start local emulators for Firestore and Storage, allowing you to test your rules without affecting your production data.
