# Quick Setup Guide

## Step 1: Update Backend URL

Open `lib/main.dart` and change line 11:

For Android Emulator:
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

For Real Phone (replace with your computer's IP):
```dart
static const String baseUrl = 'http://192.168.1.XXX:3000/api';
```

## Step 2: Open in Android Studio

1. Open Android Studio
2. Click "Open" 
3. Navigate to: `C:\Users\Aryan Shivatare\OneDrive\Desktop\db\flutter_app`
4. Click "OK"
5. Wait for Gradle sync and indexing to complete

## Step 3: Install Dependencies

In Android Studio terminal (bottom), run:
```bash
flutter pub get
```

## Step 4: Make Sure Backend is Running

In your backend folder terminal:
```bash
node server.js
```

Backend should show: "MongoDB Connected Successfully" and "Server running on port 3000"

## Step 5: Run the App

1. Start an Android Emulator OR connect your phone via USB
2. Click the green "Run" button in Android Studio
3. Wait for app to build and install

## Test Login

**Demo Credentials** (if you have demo users in backend):
- Username: demo_student
- Password: password123

OR **Register** a new account with your email!

---

## Quick Commands Reference

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Run on specific device
flutter devices           # List all devices
flutter run -d <device-id>

# Clean build (if issues)
flutter clean
flutter pub get
flutter run
```

## Troubleshooting

**Problem:** "Connection refused"
**Solution:** Check backend URL. For Android emulator use `10.0.2.2` not `localhost`

**Problem:** Build errors
**Solution:** Run `flutter clean` then `flutter pub get` then `flutter run`

**Problem:** Gradle errors
**Solution:** In Android Studio: File → Invalidate Caches → Invalidate and Restart
