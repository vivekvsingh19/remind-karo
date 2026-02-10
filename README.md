# RemindKaro - WhatsApp Reminder Automation App

A production-ready Flutter application for automating WhatsApp-based reminders for businesses and individuals.

## Features

- 📱 **Phone OTP Authentication** - WhatsApp-first login experience
- 📧 **Email Authentication** - Fallback login option
- 📊 **Dashboard** - View reminder stats and upcoming reminders
- ➕ **Add Reminders** - Step-based UI for creating reminders
  - Payment reminders
  - Product reminders
  - Meeting reminders
- 📋 **Manage Reminders** - Filter, search, and manage all reminders
- 🔔 **Notifications** - In-app notification center
- ⏰ **Alarms** - Local notifications for important reminders
- 👤 **Profile Management** - User settings and preferences

## Tech Stack

- **Flutter** - Latest stable version
- **State Management** - Riverpod
- **Backend** - Firebase (Auth + Firestore)
- **Notifications** - flutter_local_notifications
- **Architecture** - Clean Architecture (Presentation / Domain / Data layers)

## Project Structure

```
lib/
├── core/
│   ├── constants/         # App-wide constants
│   ├── errors/            # Failure and exception classes
│   ├── services/          # Notification and WhatsApp services
│   ├── theme/             # Material 3 theme configuration
│   ├── utils/             # Validators and date utilities
│   └── widgets/           # Reusable UI components
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/        # User model
│   │   │   └── repositories/  # Auth repository
│   │   └── presentation/
│   │       ├── providers/     # Auth Riverpod providers
│   │       └── screens/       # Login & Profile setup screens
│   ├── dashboard/
│   │   └── presentation/
│   │       └── screens/       # Main & Dashboard screens
│   ├── reminders/
│   │   ├── data/
│   │   │   ├── models/        # Reminder model
│   │   │   └── repositories/  # Reminder repository
│   │   └── presentation/
│   │       ├── providers/     # Reminder Riverpod providers
│   │       └── screens/       # Add & Manage reminder screens
│   ├── notifications/
│   │   ├── data/
│   │   │   ├── models/        # Notification model
│   │   │   └── repositories/  # Notification repository
│   │   └── presentation/
│   │       ├── providers/     # Notification providers
│   │       └── screens/       # Notifications screen
│   └── profile/
│       └── presentation/
│           └── screens/       # Profile screen
├── firebase_options.dart
└── main.dart
```

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Phone Authentication and Email/Password Authentication
3. Create a Firestore database
4. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
5. Configure Firebase:
   ```bash
   flutterfire configure
   ```

### 3. Firestore Security Rules

Add these rules in Firebase Console > Firestore > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Reminders collection
    match /reminders/{reminderId} {
      allow read, write: if request.auth != null
        && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
    }

    // Notifications collection
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null
        && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### 4. Firestore Indexes

Create these composite indexes in Firebase Console:

**Reminders Collection:**
- `userId` (Ascending) + `scheduledTime` (Ascending)
- `userId` (Ascending) + `category` (Ascending) + `scheduledTime` (Ascending)
- `userId` (Ascending) + `status` (Ascending) + `scheduledTime` (Ascending)
- `userId` (Ascending) + `createdAt` (Ascending)

**Notifications Collection:**
- `userId` (Ascending) + `createdAt` (Descending)
- `userId` (Ascending) + `isRead` (Ascending)

### 5. Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### 6. Run the App

```bash
flutter run
```

## WhatsApp Integration

> ⚠️ **Note**: WhatsApp Business API integration is mocked in this version.

The app currently:
- Opens WhatsApp with pre-filled messages using URL scheme
- Mocks automated sending for testing purposes

### TODO: WhatsApp Business API Integration

To integrate actual WhatsApp Business API:

1. Register for WhatsApp Business API access
2. Set up a WhatsApp Business Account
3. Replace the mock implementation in `lib/core/services/whatsapp_service.dart`
4. Implement webhook handlers for delivery status updates

## Key Files

| File | Description |
|------|-------------|
| `lib/main.dart` | App entry point with Firebase initialization |
| `lib/core/theme/app_theme.dart` | Material 3 theme configuration |
| `lib/features/reminders/data/models/reminder_model.dart` | Reminder data model |
| `lib/features/reminders/data/repositories/reminder_repository.dart` | Reminder CRUD operations |
| `lib/features/reminders/presentation/providers/reminder_provider.dart` | Riverpod state management |
| `lib/core/services/whatsapp_service.dart` | WhatsApp integration (mocked) |
| `lib/core/services/notification_service.dart` | Local notifications service |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE file for details.
# remind-karo
