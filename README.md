# 🔐 RFID-Based Smart Security Box Management System for RapidKL

A comprehensive Flutter-based locker management system with RFID access control, Firebase backend, and IoT hardware integration. Developed as a final year project for RapidKL's security box management needs, demonstrating full-stack mobile development and IoT integration skills.

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
- RESTful API integration with Arduino

## 🏗️ System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Firebase      │    │   ESP8266       │
│   (Mobile/Web)  │◄──►│   Backend       │◄──►│   Hardware      │
│                 │    │                 │    │                 │
│ • User Auth     │    │ • Authentication│    │ • RFID Scanner  │
│ • Admin Panel   │    │ • Firestore DB  │    │ • Servo Control │
│ • Real-time UI  │    │ • Cloud Storage │    │ • WiFi Connect  │
│ • Notifications │    │ • Security Rules│    │ • Access Logs   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Data Flow
1. **User Authentication** → Firebase Auth validates users
2. **RFID Scan** → ESP8266 reads card and sends to Firestore
3. **Access Validation** → Firebase checks user permissions
4. **Locker Control** → Servo motor opens/closes locker
5. **Logging** → All events logged to Firestore
6. **Real-time Updates** → Flutter app shows live status

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

### Software Requirements
- **Windows 10/11** (recommended)
- **Flutter SDK** (3.0+) with Dart SDK
- **Visual Studio Code** with Flutter/Dart extensions
- **Arduino IDE** for hardware programming
- **Chrome Browser** (for web testing)
- **Android Studio** (optional, for Android development)

### Hardware Requirements
- **NodeMCU ESP8266** (ESP-12E Module)
- **MFRC522 RFID Module**
- **Servo Motor** (for locker mechanism)
- **LED indicators** and **Buzzer**
- **Android device** (for mobile testing)
- Stable internet connection

### Firebase Setup
- Firebase project with Authentication and Firestore enabled
- `google-services.json` for Android
- Firebase web configuration

## 🚀 Quick Start Guide

### For Web Development (Fastest Setup)
```bash
# 1. Clone the repository
git clone https://github.com/afifothaman/rfid-locker-system.git
cd rfid-locker-system

# 2. Install dependencies
flutter pub get

# 3. Add localhost to Firebase Auth domains
# Go to Firebase Console > Auth > Settings > Authorized domains
# Add: localhost, 127.0.0.1

# 4. Run on Chrome
flutter run -d chrome
```

### For Android Development
```bash
# 1. Ensure Android SDK is installed
flutter doctor

# 2. Connect Android device or start emulator
flutter devices

# 3. Run on Android
flutter run
```

### Complete Setup Process

### 1. Configure Firebase

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

### 2. Enable Firebase Authentication Methods

In the Firebase Console, enable the following authentication methods:
- Email/Password
- Google Sign-In (optional)

### 3. Set up Firestore Database

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

### 4. Set up Firebase Storage

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

## �️H Database Structure

The system uses Firestore with the following collections:

### Collections Overview
- **`users`** - User profiles and authentication data
- **`lockers`** - Physical locker information and status
- **`lockerAssignments`** - Active locker-user assignments
- **`access_logs`** - All access attempts and results
- **`security_events`** - Security-related events and alerts

### Key Fields
```javascript
// users collection
{
  id: "user_uid",
  role: "user" | "admin",
  status: "pending" | "active" | "rejected",
  rfidUid: "rfid_card_uid",
  name: "User Name",
  email: "user@example.com"
}

// lockerAssignments collection
{
  id: "assignment_id",
  lockerId: "locker_id",
  userId: "user_id",
  rfidUid: "rfid_uid",
  expiresAt: timestamp,
  status: "active" | "expired"
}
```

For complete database schema, see `database_structure.md`.

## 🔧 Hardware Setup

### Arduino Components
- **NodeMCU ESP8266** (ESP-12E Module)
- **MFRC522 RFID Module**
- **Servo Motor** for locker mechanism
- **LED indicators** and **Buzzer**

### Wiring Diagram
```
MFRC522 Connections:
- RST → D3
- SS/SDA → D4  
- MOSI → D7
- MISO → D6
- SCK → D5
- 3.3V and GND

Servo Motor:
- Signal → D8
- +5V and GND
```

### Arduino Libraries Required
Install via Arduino IDE Library Manager:
- ESP8266WiFi
- ESP8266HTTPClient
- WiFiClientSecure
- ArduinoJson
- MFRC522 by GithubCommunity
- Servo

### Arduino Configuration
Before uploading, configure these variables in the Arduino code:
```cpp
const char* ssid = "your_wifi_ssid";
const char* password = "your_wifi_password";
const String PROJECT_ID = "your-firebase-project-id";
const String API_KEY = "your-firebase-api-key";
const String LOCKER_ID = "your-locker-id";
```

### Upload Process
1. Connect ESP8266 via USB
2. Select Board: "NodeMCU 1.0 (ESP-12E Module)"
3. Select correct COM port
4. Upload the code
5. Open Serial Monitor (115200 baud) to view logs

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

## 🔧 Troubleshooting

### Flutter App Issues
- **Firebase connection errors**: Check `google-services.json` and internet connection
- **Permission errors**: Ensure Firestore security rules are correctly set
- **Build errors**: Run `flutter clean` then `flutter pub get`

### Arduino Issues
- **WiFi connection failed**: Verify SSID and password
- **RFID not detected**: Check wiring and 3.3V power supply
- **Firestore API errors**: Verify PROJECT_ID and API_KEY
- **Time sync issues**: Ensure internet access for NTP

### Firebase Issues
- **Authentication errors**: Check authorized domains in Firebase Console
- **Firestore permission denied**: Verify security rules and user document creation
- **Missing collections**: Manually create collections if auto-creation fails

### Development Tips
- Use `flutter doctor` to check Flutter installation
- Monitor Arduino Serial output at 115200 baud
- Test web version first for faster development
- Use Firebase Console to monitor database changes

## 📚 Documentation

- **`manual.txt`** - Complete installation and setup guide
- **`database_structure.md`** - Detailed database schema
- **`IoT_Hardware_Documentation.md`** - Hardware integration guide
- **`ESP8266_INTEGRATION_GUIDE.md`** - Arduino setup instructions

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
