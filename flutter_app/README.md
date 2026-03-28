# Campus Canteen Flutter App

A Flutter mobile application for the Campus Canteen food ordering system.

## Features

✅ **User Authentication**
- Register with OTP verification
- Login with JWT tokens
- Persistent authentication

✅ **Menu Browsing**
- View all menu items
- Filter by category (Breakfast, Lunch, Snacks, Beverages)
- Add items to cart

✅ **Order Management**
- Place orders
- View order history
- Track order status (Pending → Preparing → Ready → Completed)

✅ **Profile Management**
- View profile
- Logout

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Your backend server running

### 2. Configure Backend URL

Open `lib/main.dart` and update the API base URL on line 11:

```dart
class ApiConfig {
  static const String baseUrl = 'YOUR_BACKEND_URL/api';
}
```

**Important:**
- For Android Emulator: `http://10.0.2.2:3000/api`
- For iOS Simulator: `http://localhost:3000/api`
- For Real Device: `http://YOUR_COMPUTER_IP:3000/api` (e.g., `http://192.168.1.100:3000/api`)

### 3. Install Dependencies

```bash
cd flutter_app
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

Or open in Android Studio:
1. Open Android Studio
2. File → Open → Select the `flutter_app` folder
3. Wait for dependencies to install
4. Click the Run button (green play icon)

## Project Structure

```
flutter_app/
├── lib/
│   └── main.dart          # Main application file (all code)
├── pubspec.yaml           # Dependencies
└── README.md              # This file
```

## Code Structure in main.dart

1. **Configuration** (Lines 1-15)
   - API base URL configuration

2. **Models** (Lines 17-145)
   - User, MenuItem, Order, OrderItem classes

3. **API Service** (Lines 147-270)
   - All backend API calls
   - Token management
   - HTTP requests

4. **UI Screens** (Lines 272-end)
   - SplashScreen: Auto-login check
   - LoginScreen: User login
   - RegisterScreen: Registration with OTP
   - HomeScreen: Main navigation
   - MenuScreen: Browse menu & add to cart
   - OrdersScreen: View order history
   - ProfileScreen: User profile & logout

## Features to Add (Your Task)

You can extend this app with:
- [ ] Table booking functionality
- [ ] Notices/announcements view
- [ ] Complaints submission
- [ ] Payment integration
- [ ] Push notifications
- [ ] User profile editing
- [ ] Favorites/wishlist
- [ ] Order ratings & reviews

## Backend API Endpoints Used

- `POST /api/send-otp` - Send OTP for registration
- `POST /api/register` - Register new user
- `POST /api/login` - Login user
- `GET /api/menu` - Get menu items
- `POST /api/orders` - Place order
- `GET /api/orders` - Get user orders

## Dependencies

- **http** (^1.1.0): HTTP requests to backend
- **shared_preferences** (^2.2.2): Local storage for JWT tokens

## Tips for Development

1. **Enable Hot Reload**: Save file to see changes instantly without restarting
2. **Debug Console**: Check for errors in Android Studio's Run tab
3. **Network Issues**: Ensure backend is running and URL is correct
4. **Token Issues**: Clear app data if authentication fails

## Common Issues

### "Connection refused" error
- Check if backend server is running
- Verify the API URL in `ApiConfig`
- For Android emulator, use `10.0.2.2` instead of `localhost`

### "No token" error
- Login again to get fresh token
- Check if token is being saved in SharedPreferences

### UI not updating
- Use `setState(() {...})` when changing data
- Restart app if hot reload doesn't work

## Next Steps

1. Open the project in Android Studio
2. Update the backend URL
3. Run `flutter pub get`
4. Run the app on emulator or device
5. Start coding your additional features!

Happy Coding! 🚀
