# 🔐 Smart RFID Locker Management System

A comprehensive Flutter-based locker management system with RFID access control, Firebase backend, and real-time monitoring capabilities. Built as a final year project demonstrating full-stack mobile development skills.

## 🚀 Live Demo
[Add your deployed app link here when available]

## 📱 Screenshots
[Add screenshots of your app here]

## ✨ Key Features

### 🔐 Authentication & Security
- Secure user authentication with Firebase Auth
- Role-based access control (Admin/User roles)
- Password reset functionality
- Session management

### 📱 User Experience
- Cross-platform Flutter app (Android, iOS, Web)
- Responsive design for all screen sizes
- Light/Dark theme support
- Multi-language support (English/Malay)
- Intuitive user interface

### 🔑 RFID Integration
- Hardware integration with ESP8266/Arduino
- Real-time RFID card scanning
- Locker assignment and management
- Access control automation

### 📊 Admin Dashboard
- Real-time access logs and monitoring
- User management system
- Locker status tracking
- Analytics and reporting
- Extension request management

### 🔔 Smart Notifications
- Push notifications for access events
- Email notifications for important updates
- Real-time status updates

### 💾 Data Management
- Cloud Firestore for real-time data
- Offline support and data synchronization
- Secure data storage and backup

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **Material Design** - UI components

### Backend
- **Firebase Authentication** - User management
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage
- **Firebase Cloud Messaging** - Push notifications

### Hardware
- **ESP8266** - WiFi microcontroller
- **Arduino IDE** - Hardware programming
- **RFID RC522** - Card reader module

### Development Tools
- **VS Code** - IDE
- **Firebase CLI** - Deployment
- **Git** - Version control

## 📋 Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (2.17+)
- Firebase project setup
- Arduino IDE (for hardware)
- ESP8266 board and RFID module

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/smart-locker-system.git
cd smart-locker-system
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add a new web app to your Firebase project
3. Copy the Firebase configuration from the web app settings
4. Create a `.env` file in the root directory and add your Firebase configuration:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key_here
FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
FIREBASE_APP_ID=your_app_id
FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX

# App Configuration
APP_NAME=Smart Locker System
APP_VERSION=1.0.0
APP_ENV=development
```

### 4. Enable Firebase Authentication Methods

In the Firebase Console, enable the following authentication methods:
- Email/Password
- Google Sign-In (optional)

### 5. Set up Firestore Database

1. Go to Firestore Database in Firebase Console
2. Create a new database in production mode
3. Set up the following security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && (request.auth.uid == userId || isAdmin());
    }
    
    match /access_logs/{logId} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }
    
    function isAdmin() {
      return request.auth.token.admin == true;
    }
  }
}
```

### 6. Set up Firebase Storage

1. Go to Storage in Firebase Console
2. Set up security rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Running the App

### For Web

```bash
flutter run -d chrome --web-renderer html
```

### For Android

```bash
flutter run -d <device_id>
```

### For iOS

```bash
cd ios
pod install
cd ..
flutter run -d <device_id>
```

## 🔧 Hardware Setup

This project includes Arduino code for ESP8266 integration:

- `arduino_locker_code.ino` - Main Arduino sketch
- `RapidKL_ESP8266_Simple.ino` - Simplified ESP8266 code
- Hardware documentation in `IoT_Hardware_Documentation.md`

### Hardware Components
- ESP8266 WiFi Module
- RFID RC522 Reader
- Servo motors for locker mechanism
- LED indicators
- Buzzer for audio feedback

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                  # Data models
│   ├── user_model.dart
│   └── access_log_model.dart
├── screens/                 # UI screens
│   ├── auth/                # Authentication screens
│   ├── user/                # User screens
│   └── admin/               # Admin screens
├── services/                # Business logic
│   └── firebase_service.dart
├── utils/                   # Utilities
│   ├── constants.dart
│   └── theme.dart
└── widgets/                 # Reusable widgets
```

## Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key_here
FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
FIREBASE_APP_ID=your_app_id
FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX

# App Configuration
APP_NAME=Smart Locker System
APP_VERSION=1.0.0
APP_ENV=development
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Google Fonts](https://fonts.google.com/)
- [Flutter Community](https://github.com/fluttercommunity)
