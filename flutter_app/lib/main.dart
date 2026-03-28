import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'firebase_options.dart';

// ==================== CONFIGURATION ====================
class ApiConfig {
  // Override with --dart-define=API_BASE_URL=... when needed.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );
}

// ==================== MODELS ====================
class AppUser {
  final String id;
  final String name;
  final String email;
  final String username;
  final String userType;
  final String? studentId;
  final String? phone;
  final bool isVerified;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.userType,
    this.studentId,
    this.phone,
    required this.isVerified,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      userType: json['userType'] ?? 'student',
      studentId: json['studentId'],
      phone: json['phone'],
      isVerified: json['isVerified'] ?? false,
    );
  }
}

class MenuItem {
  final String id;
  final String name;
  final double price;
  final String category;
  final String description;
  final String emoji;
  final String? imageUrl;
  final bool available;
  final bool popular;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.emoji,
    this.imageUrl,
    required this.available,
    required this.popular,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '🍽️',
      imageUrl: json['imageUrl'],
      available: json['available'] ?? true,
      popular: json['popular'] ?? false,
    );
  }
}

class OrderItem {
  final String name;
  final double price;
  final int quantity;
  final String emoji;
  final String? imageUrl;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.emoji,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'emoji': emoji,
    };
  }
}

class Order {
  final String orderId;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final String status;
  final String createdAt;

  Order({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> orderItems = [];
    if (json['items'] != null) {
      orderItems = (json['items'] as List).map((item) {
        return OrderItem(
          name: item['name'] ?? '',
          price: (item['price'] ?? 0).toDouble(),
          quantity: item['quantity'] ?? 1,
          emoji: item['emoji'] ?? '🍽️',
          imageUrl: item['imageUrl'],
        );
      }).toList();
    }

    return Order(
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      items: orderItems,
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}

class Booking {
  final String bookingId;
  final String userId;
  final String timeSlot;
  final int seatNumber;
  final String date;
  final String status;
  final double fine;

  Booking({
    required this.bookingId,
    required this.userId,
    required this.timeSlot,
    required this.seatNumber,
    required this.date,
    required this.status,
    required this.fine,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      seatNumber: json['seatNumber'] ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? 'pending',
      fine: (json['fine'] ?? 0).toDouble(),
    );
  }
}

class TimeSlot {
  final String time;
  final String label;
  final int total;
  final int booked;

  TimeSlot({
    required this.time,
    required this.label,
    required this.total,
    required this.booked,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      time: json['time'] ?? '',
      label: json['label'] ?? '',
      total: json['total'] ?? 0,
      booked: json['booked'] ?? 0,
    );
  }
}

class Notice {
  final String noticeId;
  final String title;
  final String message;
  final String type;
  final bool urgent;
  final String createdAt;

  Notice({
    required this.noticeId,
    required this.title,
    required this.message,
    required this.type,
    required this.urgent,
    required this.createdAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      noticeId: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      urgent: json['urgent'] ?? false,
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}

class Complaint {
  final String complaintId;
  final String userId;
  final String subject;
  final String description;
  final String status;
  final String? response;
  final String createdAt;

  Complaint({
    required this.complaintId,
    required this.userId,
    required this.subject,
    required this.description,
    required this.status,
    this.response,
    required this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      complaintId: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      response: json['response'],
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}

// ==================== API SERVICE ====================
class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Map<String, String> getHeaders([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Send OTP
  static Future<Map<String, dynamic>> sendOTP(String email, String name) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/send-otp'),
        headers: getHeaders(),
        body: jsonEncode({'email': email, 'name': name}),
      ).timeout(const Duration(seconds: 120));
      return jsonDecode(response.body);
    } on TimeoutException catch (_) {
      return {'message': 'Request timed out after 2 minutes. Server may be sleeping. Wait 1 minute and try again!'};
    } catch (e) {
      return {'message': 'Connection failed: ${e.toString()}'};
    }
  }

  // Register (simplified without OTP)
  static Future<Map<String, dynamic>> register(
      String name, String email, String username, String password, String userType) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'username': username,
          'password': password,
          'userType': userType,
        }),
      ).timeout(const Duration(seconds: 120));
      final result = jsonDecode(response.body);
      if (result['token'] != null) {
        await saveToken(result['token']);
      }
      return result;
    } on TimeoutException catch (_) {
      return {'message': 'Request timed out after 2 minutes. Server may be sleeping. Wait 1 minute and try again!'};
    } catch (e) {
      return {'message': 'Connection failed: ${e.toString()}'};
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      print('Attempting login to: ${ApiConfig.baseUrl}/login');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
          'userType': 'student', // Required by backend
        }),
      ).timeout(const Duration(seconds: 120));
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final result = jsonDecode(response.body);
      if (result['token'] != null) {
        await saveToken(result['token']);
        print('Token saved successfully');
      }
      return result;
    } on TimeoutException catch (_) {
      print('Login timeout - server took too long');
      return {'message': 'Request timed out after 2 minutes. Server may be sleeping. Wait 1 minute and try again!'};
    } catch (e) {
      print('Login error: $e');
      return {'message': 'Connection failed: ${e.toString()}'};
    }
  }

  // Get Menu Items
  static Future<List<MenuItem>> getMenuItems() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/menu'),
        headers: getHeaders(token),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => MenuItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching menu: $e');
      return [];
    }
  }

  // Place Order
  static Future<Map<String, dynamic>> placeOrder(
      List<OrderItem> items, double total) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/orders'),
        headers: getHeaders(token),
        body: jsonEncode({
          'items': items.map((item) => item.toJson()).toList(),
          'total': total,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Error: $e'};
    }
  }

  // Get Orders
  static Future<List<Order>> getOrders() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders'),
        headers: getHeaders(token),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((order) => Order.fromJson(order)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  // Get Time Slots
  static Future<List<TimeSlot>> getTimeSlots() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bookings/time-slots'),
        headers: getHeaders(token),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((slot) => TimeSlot.fromJson(slot)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching time slots: $e');
      return [];
    }
  }

  // Book Seat
  static Future<Map<String, dynamic>> bookSeat(String timeSlot) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/bookings'),
        headers: getHeaders(token),
        body: jsonEncode({'timeSlot': timeSlot}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Error: $e'};
    }
  }

  // Get Bookings
  static Future<List<Booking>> getBookings() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bookings'),
        headers: getHeaders(token),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((booking) => Booking.fromJson(booking)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  // Cancel Booking
  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/bookings/$bookingId'),
        headers: getHeaders(token),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Error: $e'};
    }
  }

  // Get Notices
  static Future<List<Notice>> getNotices() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notices'),
        headers: getHeaders(token),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((notice) => Notice.fromJson(notice)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notices: $e');
      return [];
    }
  }

  // Submit Complaint
  static Future<Map<String, dynamic>> submitComplaint(
      String subject, String description) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/complaints'),
        headers: getHeaders(token),
        body: jsonEncode({
          'subject': subject,
          'description': description,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Error: $e'};
    }
  }

  // Get Complaints
  static Future<List<Complaint>> getComplaints() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/complaints'),
        headers: getHeaders(token),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((complaint) => Complaint.fromJson(complaint)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching complaints: $e');
      return [];
    }
  }

  // Get Current User
  static Future<AppUser?> getCurrentUser() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: getHeaders(token),
      );
      if (response.statusCode == 200) {
        return AppUser.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Update Profile
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: getHeaders(token),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Error: $e'};
    }
  }
}

// ==================== FIREBASE SERVICE ====================
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Register with Firebase Auth + Store user data in Realtime Database
  static Future<Map<String, dynamic>> register(
      String name, String email, String username, String password, String userType) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final userId = credential.user!.uid;
      
      // Store additional user data in Realtime Database
      await _db.child('users').child(userId).set({
        'name': name,
        'email': email,
        'username': username,
        'userType': userType,
        'studentId': userType == 'student' ? 'STU${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}' : null,
        'phone': null,
        'isVerified': true,
        'createdAt': ServerValue.timestamp,
      });
      
      return {
        'message': 'Registration successful!',
        'userId': userId,
        'user': {
          '_id': userId,
          'name': name,
          'email': email,
          'username': username,
          'userType': userType,
          'isVerified': true,
        }
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return {'message': 'Password is too weak'};
      } else if (e.code == 'email-already-in-use') {
        return {'message': 'Email already registered'};
      } else {
        return {'message': e.message ?? 'Registration failed'};
      }
    } catch (e) {
      return {'message': 'Error: ${e.toString()}'};
    }
  }

  // Login with Firebase Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final userId = credential.user!.uid;
      
      // Get user data from Realtime Database
      final snapshot = await _db.child('users').child(userId).get();
      
      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        return {
          'message': 'Login successful',
          'userId': userId,
          'user': {
            '_id': userId,
            'name': userData['name'],
            'email': userData['email'],
            'username': userData['username'],
            'userType': userData['userType'],
            'studentId': userData['studentId'],
            'phone': userData['phone'],
            'isVerified': userData['isVerified'] ?? true,
          }
        };
      } else {
        return {'message': 'User data not found'};
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return {'message': 'No user found with this email'};
      } else if (e.code == 'wrong-password') {
        return {'message': 'Incorrect password'};
      } else {
        return {'message': e.message ?? 'Login failed'};
      }
    } catch (e) {
      return {'message': 'Error: ${e.toString()}'};
    }
  }

  // Logout
  static Future<void> logout() async {
    await _auth.signOut();
    await ApiService.clearToken(); // Also clear old token
  }

  // Save user ID for later use
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // ========== MENU ITEMS ==========
  static Future<List<MenuItem>> getMenuItems() async {
    try {
      final snapshot = await _db.child('menuItems').get();
      
      if (snapshot.exists) {
        final menuData = Map<String, dynamic>.from(snapshot.value as Map);
        return menuData.entries.map((entry) {
          final item = Map<String, dynamic>.from(entry.value as Map);
          return MenuItem.fromJson({
            '_id': entry.key,
            ...item,
          });
        }).toList();
      }
      
      // If no menu items, create sample data
      await _initializeSampleMenu();
      return getMenuItems(); // Recursive call to fetch newly created data
    } catch (e) {
      print('Error fetching menu: $e');
      return [];
    }
  }

  static Future<void> _initializeSampleMenu() async {
    // Create sample menu items in menuItems path
    final sampleMenu = {
      'item1': {
        'name': 'Veg Thali',
        'price': 80.0,
        'category': 'main',
        'description': 'Complete vegetarian meal with roti, rice, dal, sabzi',
        'emoji': '🍛',
        'imageUrl': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400',
        'available': true,
        'popular': true,
      },
      'item2': {
        'name': 'Paneer Butter Masala',
        'price': 120.0,
        'category': 'main',
        'description': 'Rich and creamy paneer curry',
        'emoji': '🧀',
        'imageUrl': 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400',
        'available': true,
        'popular': true,
      },
      'item3': {
        'name': 'Masala Dosa',
        'price': 60.0,
        'category': 'breakfast',
        'description': 'Crispy dosa with potato filling',
        'emoji': '🥞',
        'imageUrl': 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=400',
        'available': true,
        'popular': false,
      },
      'item4': {
        'name': 'Chai',
        'price': 15.0,
        'category': 'beverage',
        'description': 'Hot Indian tea',
        'emoji': '☕',
        'imageUrl': 'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?w=400',
        'available': true,
        'popular': true,
      },
      'item5': {
        'name': 'Samosa',
        'price': 20.0,
        'category': 'snacks',
        'description': 'Crispy fried pastry with potato filling',
        'emoji': '🥟',
        'imageUrl': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400',
        'available': true,
        'popular': true,
      },
    };
    
    await _db.child('menuItems').set(sampleMenu);
  }

  // ========== ORDERS ==========
  static Future<Map<String, dynamic>> placeOrder(List<OrderItem> items, double total) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {'message': 'Please login first'};

      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      await _db.child('orders').child(orderId).set({
        'orderId': orderId,
        'userId': userId,
        'items': items.map((item) => item.toJson()).toList(),
        'total': total,
        'status': 'pending',
        'createdAt': ServerValue.timestamp,
      });

      return {'message': 'Order placed successfully!', 'orderId': orderId};
    } catch (e) {
      return {'message': 'Error: ${e.toString()}'};
    }
  }

  static Future<List<Order>> getOrders() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _db.child('orders').get();
      if (!snapshot.exists) return [];

      final ordersData = Map<String, dynamic>.from(snapshot.value as Map);
      return ordersData.entries
          .where((entry) {
            final order = Map<String, dynamic>.from(entry.value as Map);
            return order['userId'] == userId;
          })
          .map((entry) {
            final order = Map<String, dynamic>.from(entry.value as Map);
            return Order.fromJson(order);
          })
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  // ========== PROFILE ==========
  static Future<AppUser?> getCurrentUser() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final snapshot = await _db.child('users').child(userId).get();
      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        return AppUser.fromJson({
          '_id': userId,
          ...userData,
        });
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {'message': 'Please login first'};

      await _db.child('users').child(userId).update(data);
      return {'message': 'Profile updated successfully!'};
    } catch (e) {
      return {'message': 'Error: ${e.toString()}'};
    }
  }

  // ========== BOOKINGS ==========
  static Future<Map<String, dynamic>> bookSeat(String timeSlot) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {'message': 'Please login first'};

      final bookingId = 'BK${DateTime.now().millisecondsSinceEpoch}';
      await _db.child('bookings').child(bookingId).set({
        'bookingId': bookingId,
        'userId': userId,
        'timeSlot': timeSlot,
        'status': 'confirmed',
        'createdAt': ServerValue.timestamp,
      });

      return {'message': 'Seat booked successfully!', 'bookingId': bookingId};
    } catch (e) {
      return {'message': 'Error: ${e.toString()}'};
    }
  }

  static Future<List<Booking>> getBookings() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _db.child('bookings').get();
      if (!snapshot.exists) return [];

      final bookingsData = Map<String, dynamic>.from(snapshot.value as Map);
      return bookingsData.entries
          .where((entry) {
            final booking = Map<String, dynamic>.from(entry.value as Map);
            return booking['userId'] == userId;
          })
          .map((entry) {
            final booking = Map<String, dynamic>.from(entry.value as Map);
            return Booking.fromJson(booking);
          })
          .toList();
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    try {
      await _db.child('bookings').child(bookingId).remove();
      return {'message': 'Booking cancelled successfully!'};
    } catch (e) {
      return {'message': 'Error: ${e.toString()}'};
    }
  }

  // ========== NOTICES ==========
  static Future<List<Notice>> getNotices() async {
    try {
      final snapshot = await _db.child('notices').get();
      
      if (snapshot.exists) {
        final noticesData = Map<String, dynamic>.from(snapshot.value as Map);
        return noticesData.entries.map((entry) {
          final notice = Map<String, dynamic>.from(entry.value as Map);
          return Notice.fromJson({
            '_id': entry.key,
            ...notice,
          });
        }).toList();
      }
      
      // If no notices, create sample data
      await _initializeSampleNotices();
      return getNotices();
    } catch (e) {
      print('Error fetching notices: $e');
      return [];
    }
  }

  static Future<void> _initializeSampleNotices() async {
    final sampleNotices = {
      'notice1': {
        'title': 'Welcome to Campus Canteen!',
        'message': 'Enjoy delicious meals at affordable prices',
        'priority': 'normal',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      'notice2': {
        'title': 'Special Offer',
        'message': 'Get 10% off on all meals this week!',
        'priority': 'high',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
    };
    
    await _db.child('notices').set(sampleNotices);
  }

  // ========== COMPLAINTS ==========
  static Future<Map<String, dynamic>> submitComplaint(String subject, String description) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {'message': 'Please login first'};

      final complaintId = 'CMP${DateTime.now().millisecondsSinceEpoch}';
      await _db.child('complaints').child(complaintId).set({
        'complaintId': complaintId,
        'userId': userId,
        'subject': subject,
        'description': description,
        'status': 'pending',
        'createdAt': ServerValue.timestamp,
      });

      return {'message': 'Complaint submitted successfully!', 'complaintId': complaintId};
    } catch (e) {
      return {'message': 'Error: ${e.toString()}'};
    }
  }

  static Future<List<Complaint>> getComplaints() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _db.child('complaints').get();
      if (!snapshot.exists) return [];

      final complaintsData = Map<String, dynamic>.from(snapshot.value as Map);
      return complaintsData.entries
          .where((entry) {
            final complaint = Map<String, dynamic>.from(entry.value as Map);
            return complaint['userId'] == userId;
          })
          .map((entry) {
            final complaint = Map<String, dynamic>.from(entry.value as Map);
            return Complaint.fromJson(complaint);
          })
          .toList();
    } catch (e) {
      print('Error fetching complaints: $e');
      return [];
    }
  }

  // ========== TIME SLOTS ==========
  static Future<List<TimeSlot>> getTimeSlots() async {
    try {
      final snapshot = await _db.child('timeSlots').get();
      
      if (snapshot.exists) {
        final slotsData = Map<String, dynamic>.from(snapshot.value as Map);
        return slotsData.entries.map((entry) {
          final slot = Map<String, dynamic>.from(entry.value as Map);
          return TimeSlot.fromJson({
            '_id': entry.key,
            ...slot,
          });
        }).toList();
      }
      
      // If no time slots, create sample data
      await _initializeSampleTimeSlots();
      return getTimeSlots();
    } catch (e) {
      print('Error fetching time slots: $e');
      return [];
    }
  }

  static Future<void> _initializeSampleTimeSlots() async {
    final sampleSlots = {
      'slot1': {
        'label': '8:00 AM - 9:00 AM (Breakfast)',
        'available': true,
        'capacity': 50,
      },
      'slot2': {
        'label': '9:00 AM - 10:00 AM (Breakfast)',
        'available': true,
        'capacity': 50,
      },
      'slot3': {
        'label': '12:00 PM - 1:00 PM (Lunch)',
        'available': true,
        'capacity': 100,
      },
      'slot4': {
        'label': '1:00 PM - 2:00 PM (Lunch)',
        'available': true,
        'capacity': 100,
      },
      'slot5': {
        'label': '7:00 PM - 8:00 PM (Dinner)',
        'available': true,
        'capacity': 80,
      },
      'slot6': {
        'label': '8:00 PM - 9:00 PM (Dinner)',
        'available': true,
        'capacity': 80,
      },
    };
    
    await _db.child('timeSlots').set(sampleSlots);
  }

  // ========== ADMIN OPERATIONS ==========
  
  // Add menu item (Admin only)
  static Future<bool> addMenuItem(MenuItem item) async {
    try {
      final itemId = DateTime.now().millisecondsSinceEpoch.toString();
      print('Adding menu item: ${item.name}, imageUrl: ${item.imageUrl}');
      await _db.child('menuItems').child(itemId).set({
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'category': item.category,
        'available': item.available,
        'emoji': item.emoji,
        'popular': item.popular,
        'imageUrl': item.imageUrl,
        'createdAt': ServerValue.timestamp,
      });
      print('Menu item added successfully with ID: $itemId');
      return true;
    } catch (e) {
      print('Error adding menu item: $e');
      return false;
    }
  }

  // Update menu item (Admin only)
  static Future<bool> updateMenuItem(String itemId, MenuItem item) async {
    try {
      await _db.child('menuItems').child(itemId).update({
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'category': item.category,
        'available': item.available,
        'emoji': item.emoji,
        'popular': item.popular,
        'imageUrl': item.imageUrl,
      });
      return true;
    } catch (e) {
      print('Error updating menu item: $e');
      return false;
    }
  }

  // Delete menu item (Admin only)
  static Future<bool> deleteMenuItem(String itemId) async {
    try {
      print('Deleting menu item with ID: $itemId');
      await _db.child('menuItems').child(itemId).remove();
      print('Menu item deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting menu item: $e');
      return false;
    }
  }

  // Update order status (Admin only)
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _db.child('orders').child(orderId).update({'status': status});
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Post notice (Admin only)
  static Future<bool> postNotice(String title, String message, String type, bool urgent) async {
    try {
      final noticeId = DateTime.now().millisecondsSinceEpoch.toString();
      await _db.child('notices').child(noticeId).set({
        'title': title,
        'message': message,
        'type': type,
        'urgent': urgent,
        'createdAt': ServerValue.timestamp,
      });
      return true;
    } catch (e) {
      print('Error posting notice: $e');
      return false;
    }
  }

  // Update complaint status (Admin only)
  static Future<bool> updateComplaintStatus(String complaintId, String status, String? response) async {
    try {
      final Map<String, dynamic> updates = {
        'status': status,
      };
      if (response != null) {
        updates['adminResponse'] = response;
        updates['respondedAt'] = ServerValue.timestamp;
      }
      await _db.child('complaints').child(complaintId).update(updates);
      return true;
    } catch (e) {
      print('Error updating complaint: $e');
      return false;
    }
  }

  // Update seat capacity (Admin only)
  static Future<bool> updateSeatCapacity(String slotId, int capacity) async {
    try {
      await _db.child('timeSlots').child(slotId).update({'capacity': capacity});
      return true;
    } catch (e) {
      print('Error updating seat capacity: $e');
      return false;
    }
  }

  // Get all orders (Admin only)
  static Future<List<Order>> getAllOrders() async {
    try {
      final snapshot = await _db.child('orders').get();
      
      if (snapshot.exists) {
        final ordersData = Map<String, dynamic>.from(snapshot.value as Map);
        return ordersData.entries.map((entry) {
          final order = Map<String, dynamic>.from(entry.value as Map);
          return Order.fromJson({
            'orderId': entry.key,
            ...order,
          });
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Latest first
      }
      return [];
    } catch (e) {
      print('Error fetching all orders: $e');
      return [];
    }
  }
}

// ==================== MAIN APP ====================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue anyway - Firebase is optional for basic functionality
  }
  
  runApp(const CampusCanteenApp());
}

class CampusCanteenApp extends StatelessWidget {
  const CampusCanteenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Canteen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.orange.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange.shade600,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ==================== SPLASH SCREEN ====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // Short delay to show splash (shorter on web, longer on mobile)
      await Future.delayed(Duration(milliseconds: kIsWeb ? 500 : 1000));
      
      User? user;
      try {
        user = FirebaseAuth.instance.currentUser;
      } catch (e) {
        print('Firebase Auth error: $e');
        // If Firebase fails, just go to login
        user = null;
      }
      
      if (mounted) {
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      print('Splash screen error: $e');
      // If anything fails, go to login screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade600, Colors.orange.shade300],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🍽️',
                style: TextStyle(fontSize: 100),
              ),
              SizedBox(height: 20),
              Text(
                'Campus Canteen',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your Digital Food Court',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== LOGIN SCREEN ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic>? result;
    
    // Try Firebase login first (requires email)
    String email = _usernameController.text;
    bool triedFirebase = false;
    
    try {
      // Check if input is email or username
      if (!email.contains('@')) {
        // It's a username, need to find email from database
        try {
          final usersSnapshot = await FirebaseDatabase.instance.ref('users').get();
          if (usersSnapshot.exists) {
            final users = Map<String, dynamic>.from(usersSnapshot.value as Map);
            for (var entry in users.entries) {
              final userData = Map<String, dynamic>.from(entry.value as Map);
              if (userData['username'] == _usernameController.text) {
                email = userData['email'];
                break;
              }
            }
          }
        } catch (e) {
          print('Could not fetch users from Firebase: $e');
        }
      }
      
      // Try Firebase Auth if we have an email
      if (email.contains('@')) {
        triedFirebase = true;
        result = await FirebaseService.login(
          email,
          _passwordController.text,
        );
        
        if (result['userId'] != null) {
          await FirebaseService.saveUserId(result['userId']);
        }
      }
    } catch (e) {
      print('Firebase login failed: $e');
      result = null;
    }

    // Fallback to backend API if Firebase failed or wasn't tried
    if (result == null || result['userId'] == null) {
      print('Falling back to backend API login');
      try {
        result = await ApiService.login(
          _usernameController.text,
          _passwordController.text,
        );
      } catch (e) {
        print('API login failed: $e');
        result = {'message': 'Login failed: ${e.toString()}'};
      }
    }

    setState(() => _isLoading = false);

    // Check if login was successful (either Firebase or API)
    if (result != null && (result['userId'] != null || result['token'] != null)) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        // Show detailed error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Failed'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result?['message'] ?? 'Unknown error'),
                  const SizedBox(height: 12),
                  const Text('Tips:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('• Enter your email or username'),
                  const Text('• Check your password'),
                  const Text('• Make sure you have registered'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade400, Colors.orange.shade700],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🍽️',
                    style: TextStyle(fontSize: 70),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login to Campus Canteen',
                    style: TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Don't have an account? Register",
                              style: TextStyle(color: Colors.orange.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== REGISTER SCREEN ====================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _userType = 'student';
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    Map<String, dynamic>? result;
    
    // Try Firebase first
    try {
      result = await FirebaseService.register(
        _nameController.text,
        _emailController.text,
        _usernameController.text,
        _passwordController.text,
        _userType,
      );
      
      if (result['userId'] != null) {
        await FirebaseService.saveUserId(result['userId']);
      }
    } catch (e) {
      print('Firebase register failed: $e');
      result = null;
    }
    
    // Fallback to backend API if Firebase failed
    if (result == null || result['userId'] == null) {
      print('Falling back to backend API register');
      try {
        result = await ApiService.register(
          _nameController.text,
          _emailController.text,
          _usernameController.text,
          _passwordController.text,
          _userType,
        );
      } catch (e) {
        print('API register failed: $e');
        result = {'message': 'Registration failed: ${e.toString()}'};
      }
    }
    
    setState(() => _isLoading = false);

    if (result != null && (result['userId'] != null || result['token'] != null)) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result?['message'] ?? 'Registration failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 50),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.account_circle),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password (min 6 characters)',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _userType,
                        decoration: InputDecoration(
                          labelText: 'User Type',
                          prefixIcon: const Icon(Icons.people),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'student', child: Text('Student')),
                          DropdownMenuItem(
                              value: 'owner', child: Text('Owner')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _userType = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HOME SCREEN ====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final user = await FirebaseService.getCurrentUser();
    setState(() {
      _userType = user?.userType ?? 'student';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show different dashboard based on user type
    if (_userType == 'owner') {
      return const OwnerDashboard();
    } else {
      return const StudentDashboard();
    }
  }
}

// ==================== STUDENT DASHBOARD ====================
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MenuScreen(),
    const BookingScreen(),
    const OrdersScreen(),
    const ComplaintsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: Colors.orange.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_seat),
            label: 'Booking',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_problem),
            label: 'Complaints',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ==================== OWNER DASHBOARD ====================
class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({Key? key}) : super(key: key);

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const OwnerDashboardScreen(),
    const OwnerMenuManagementScreen(),
    const OwnerOrdersScreen(),
    const OwnerBookingsScreen(),
    const OwnerNoticesScreen(),
    const OwnerComplaintsViewScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: Colors.orange.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_seat),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign),
            label: 'Notices',
          ),
          NavigationDestination(
            icon: Icon(Icons.report),
            label: 'Complaints',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ==================== OWNER DASHBOARD SCREEN ====================
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _todayOrders = 0;
  int _todayBookings = 0;
  double _todayRevenue = 0.0;
  int _activeNotices = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final orders = await FirebaseService.getOrders();
    final bookings = await FirebaseService.getBookings();
    final notices = await FirebaseService.getNotices();
    
    setState(() {
      _todayOrders = orders.length;
      _todayBookings = bookings.length;
      _todayRevenue = orders.fold(0.0, (sum, order) => sum + order.total);
      _activeNotices = notices.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Dashboard Overview', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '💰',
                    'Revenue',
                    '₹${_todayRevenue.toStringAsFixed(0)}',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '📋',
                    'Orders',
                    '$_todayOrders',
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '🪑',
                    'Bookings',
                    '$_todayBookings',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '📢',
                    'Notices',
                    '$_activeNotices',
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildQuickAction('🍽️', 'Manage Menu', Colors.orange),
                        _buildQuickAction('📦', 'Process Orders', Colors.blue),
                        _buildQuickAction('🪑', 'View Bookings', Colors.green),
                        _buildQuickAction('📢', 'Post Notice', Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                Text(emoji, style: const TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String emoji, String label, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

// Placeholder screens for owner sections
// ==================== OWNER MENU MANAGEMENT ====================
class OwnerMenuManagementScreen extends StatefulWidget {
  const OwnerMenuManagementScreen({Key? key}) : super(key: key);

  @override
  State<OwnerMenuManagementScreen> createState() => _OwnerMenuManagementScreenState();
}

class _OwnerMenuManagementScreenState extends State<OwnerMenuManagementScreen> {
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    final items = await FirebaseService.getMenuItems();
    setState(() {
      _menuItems = items;
      _isLoading = false;
    });
  }

  void _showAddEditDialog({MenuItem? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final priceController = TextEditingController(text: item?.price.toString() ?? '');
    final categoryController = TextEditingController(text: item?.category ?? '');
    final emojiController = TextEditingController(text: item?.emoji ?? '🍽️');
    final imageUrlController = TextEditingController(text: item?.imageUrl ?? '');
    bool available = item?.available ?? true;
    bool popular = item?.popular ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Add Menu Item' : 'Edit Menu Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price (₹) *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category (meals/snacks/beverages)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emojiController,
                  decoration: const InputDecoration(labelText: 'Emoji', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Available'),
                  value: available,
                  onChanged: (val) => setDialogState(() => available = val),
                ),
                SwitchListTile(
                  title: const Text('Popular'),
                  value: popular,
                  onChanged: (val) => setDialogState(() => popular = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and Price are required')),
                  );
                  return;
                }

                final newItem = MenuItem(
                  id: item?.id ?? '',
                  name: nameController.text,
                  description: descController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  category: categoryController.text.isEmpty ? 'meals' : categoryController.text,
                  available: available,
                  emoji: emojiController.text.isEmpty ? '🍽️' : emojiController.text,
                  popular: popular,
                  imageUrl: imageUrlController.text.isEmpty ? null : imageUrlController.text,
                );

                bool success;
                if (item == null) {
                  success = await FirebaseService.addMenuItem(newItem);
                } else {
                  success = await FirebaseService.updateMenuItem(item.id, newItem);
                }

                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(item == null ? 'Item added successfully' : 'Item updated successfully')),
                  );
                  _loadMenu();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Operation failed')),
                  );
                }
              },
              child: Text(item == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteItem(MenuItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await FirebaseService.deleteMenuItem(item.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
        _loadMenu();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Menu Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.orange.shade600,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _menuItems.isEmpty
              ? const Center(child: Text('No menu items'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
                            ? (kIsWeb
                                ? Image.network(
                                    item.imageUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Text(item.emoji, style: const TextStyle(fontSize: 32)),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: item.imageUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Text(item.emoji, style: const TextStyle(fontSize: 32)),
                                  ))
                            : Text(item.emoji, style: const TextStyle(fontSize: 32)),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('₹${item.price} • ${item.category}\n${item.description}', maxLines: 2),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.popular) const Icon(Icons.star, color: Colors.orange, size: 20),
                            const SizedBox(width: 4),
                            Icon(
                              item.available ? Icons.check_circle : Icons.cancel,
                              color: item.available ? Colors.green : Colors.red,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddEditDialog(item: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteItem(item),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}

// ==================== OWNER ORDERS MANAGEMENT ====================
class OwnerOrdersScreen extends StatefulWidget {
  const OwnerOrdersScreen({Key? key}) : super(key: key);

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await FirebaseService.getAllOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    final success = await FirebaseService.updateOrderStatus(order.orderId, newStatus);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as $newStatus')),
      );
      _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Order Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: order.status == 'completed' ? Colors.green : Colors.orange,
                          child: Text(order.items.length.toString()),
                        ),
                        title: Text('Order #${order.orderId.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('₹${order.total} • ${order.status.toUpperCase()}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...order.items.map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(item.name),
                                          const Spacer(),
                                          Text('₹${item.price * item.quantity}'),
                                        ],
                                      ),
                                    )),
                                const Divider(height: 24),
                                if (order.status != 'completed')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _updateOrderStatus(order, 'completed'),
                                        icon: const Icon(Icons.check),
                                        label: const Text('Mark Completed'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      ),
                                    ],
                                  ),
                                if (order.status == 'completed')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Chip(
                                        label: const Text('Completed ✓', style: TextStyle(color: Colors.white)),
                                        backgroundColor: Colors.green,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// ==================== OWNER BOOKINGS MANAGEMENT ====================
class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({Key? key}) : super(key: key);

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  List<Booking> _bookings = [];
  List<TimeSlot> _timeSlots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final bookings = await FirebaseService.getBookings();
    final slots = await FirebaseService.getTimeSlots();
    setState(() {
      _bookings = bookings;
      _timeSlots = slots;
      _isLoading = false;
    });
  }

  void _showCapacityDialog(TimeSlot slot) {
    final controller = TextEditingController(text: slot.total.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Seat Capacity'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Capacity', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCapacity = int.tryParse(controller.text) ?? slot.total;
              final success = await FirebaseService.updateSeatCapacity(slot.time, newCapacity);
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Capacity updated')),
                );
                _loadData();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Booking Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Seat Capacity Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._timeSlots.map((slot) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(slot.label),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${slot.booked}/${slot.total} seats', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showCapacityDialog(slot),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),
                  const Text('Recent Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_bookings.isEmpty)
                    const Center(child: Text('No bookings yet'))
                  else
                    ..._bookings.map((booking) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.event_seat)),
                            title: Text('Seat ${booking.seatNumber}'),
                            subtitle: Text('${booking.timeSlot} • ${booking.date}'),
                            trailing: Chip(
                              label: Text(booking.status.toUpperCase()),
                              backgroundColor: booking.status == 'confirmed' ? Colors.green.shade100 : Colors.orange.shade100,
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

// ==================== OWNER NOTICES MANAGEMENT ====================
class OwnerNoticesScreen extends StatefulWidget {
  const OwnerNoticesScreen({Key? key}) : super(key: key);

  @override
  State<OwnerNoticesScreen> createState() => _OwnerNoticesScreenState();
}

class _OwnerNoticesScreenState extends State<OwnerNoticesScreen> {
  List<Notice> _notices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() => _isLoading = true);
    final notices = await FirebaseService.getNotices();
    setState(() {
      _notices = notices;
      _isLoading = false;
    });
  }

  void _showPostNoticeDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String noticeType = 'info';
    bool urgent = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Post Notice'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: 'Message *', border: OutlineInputBorder()),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: noticeType,
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'info', child: Text('Info')),
                    DropdownMenuItem(value: 'warning', child: Text('Warning')),
                    DropdownMenuItem(value: 'success', child: Text('Success')),
                  ],
                  onChanged: (val) => setDialogState(() => noticeType = val!),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Urgent'),
                  value: urgent,
                  onChanged: (val) => setDialogState(() => urgent = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || messageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title and Message are required')),
                  );
                  return;
                }

                final success = await FirebaseService.postNotice(
                  titleController.text,
                  messageController.text,
                  noticeType,
                  urgent,
                );

                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notice posted successfully')),
                  );
                  _loadNotices();
                }
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Notice Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPostNoticeDialog,
        backgroundColor: Colors.orange.shade600,
        icon: const Icon(Icons.add),
        label: const Text('Post Notice'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notices.isEmpty
              ? const Center(child: Text('No notices posted'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notices.length,
                  itemBuilder: (context, index) {
                    final notice = _notices[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: notice.urgent ? Colors.red.shade50 : Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: notice.urgent ? Colors.red : Colors.blue,
                          child: Icon(
                            notice.urgent ? Icons.warning : Icons.info,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(notice.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(notice.message),
                        trailing: Chip(
                          label: Text(notice.type.toUpperCase()),
                          backgroundColor: Colors.blue.shade100,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ==================== OWNER COMPLAINTS MANAGEMENT ====================
class OwnerComplaintsViewScreen extends StatefulWidget {
  const OwnerComplaintsViewScreen({Key? key}) : super(key: key);

  @override
  State<OwnerComplaintsViewScreen> createState() => _OwnerComplaintsViewScreenState();
}

class _OwnerComplaintsViewScreenState extends State<OwnerComplaintsViewScreen> {
  List<Complaint> _complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);
    final complaints = await FirebaseService.getComplaints();
    setState(() {
      _complaints = complaints;
      _isLoading = false;
    });
  }

  void _showResolveDialog(Complaint complaint) {
    final responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Complaint: ${complaint.description}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: responseController,
              decoration: const InputDecoration(
                labelText: 'Admin Response',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await FirebaseService.updateComplaintStatus(
                complaint.complaintId,
                'resolved',
                responseController.text,
              );

              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complaint resolved')),
                );
                _loadComplaints();
              }
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Complaint Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? const Center(child: Text('No complaints'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = _complaints[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: complaint.status == 'resolved' ? Colors.green : Colors.orange,
                          child: Icon(
                            complaint.status == 'resolved' ? Icons.check : Icons.pending,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(complaint.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(complaint.description),
                        trailing: complaint.status != 'resolved'
                            ? ElevatedButton(
                                onPressed: () => _showResolveDialog(complaint),
                                child: const Text('Resolve'),
                              )
                            : const Chip(
                                label: Text('Resolved'),
                                backgroundColor: Colors.green,
                              ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}

// ==================== MENU SCREEN (FOR STUDENTS) ====================
class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItem> _menuItems = [];
  List<OrderItem> _cart = [];
  List<Notice> _notices = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadMenu();
    _loadNotices();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    final items = await FirebaseService.getMenuItems();
    setState(() {
      _menuItems = items;
      _isLoading = false;
    });
  }

  Future<void> _loadNotices() async {
    final notices = await FirebaseService.getNotices();
    setState(() {
      _notices = notices;
    });
  }

  void _addToCart(MenuItem item) {
    setState(() {
      final existingIndex = _cart.indexWhere((i) => i.name == item.name);
      if (existingIndex >= 0) {
        _cart[existingIndex] = OrderItem(
          name: _cart[existingIndex].name,
          price: _cart[existingIndex].price,
          quantity: _cart[existingIndex].quantity + 1,
          emoji: _cart[existingIndex].emoji,
          imageUrl: _cart[existingIndex].imageUrl,
        );
      } else {
        _cart.add(OrderItem(
          name: item.name,
          price: item.price,
          quantity: 1,
          emoji: item.emoji,
          imageUrl: item.imageUrl,
        ));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} added to cart')),
    );
  }

  double get _cartTotal {
    return _cart.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await FirebaseService.placeOrder(_cart, _cartTotal);

    if (mounted) {
      Navigator.pop(context);
      if (result['order'] != null) {
        setState(() => _cart.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Order failed')),
        );
      }
    }
  }

  List<MenuItem> get _filteredItems {
    if (_selectedCategory == 'all') return _menuItems;
    return _menuItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  _showCart();
                },
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_notices.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.deepOrange.shade500
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade300.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.campaign,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Canteen Notices',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 110,
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, bottom: 12),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _notices.length,
                            itemBuilder: (context, index) {
                              final notice = _notices[index];
                              return Container(
                                width: 280,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: notice.urgent
                                            ? Colors.red.shade100
                                            : Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            notice.urgent ? '⚠️' : 'ℹ️',
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            notice.urgent ? 'URGENT' : 'INFO',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: notice.urgent
                                                  ? Colors.red.shade900
                                                  : Colors.blue.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      notice.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.grey.shade900,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Flexible(
                                      child: Text(
                                        notice.message,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _categoryChip('all', 'All'),
                      _categoryChip('breakfast', 'Breakfast'),
                      _categoryChip('lunch', 'Lunch'),
                      _categoryChip('snacks', 'Snacks'),
                      _categoryChip('beverages', 'Beverages'),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredItems.isEmpty
                      ? const Center(child: Text('No items available'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return _menuCard(item);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _categoryChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = value);
        },
        selectedColor: Colors.orange.shade600,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _menuCard(MenuItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.orange.shade300, Colors.orange.shade100],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? (kIsWeb
                            ? Image.network(
                                item.imageUrl!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Image load error for ${item.name}: $error');
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.emoji,
                                          style: const TextStyle(fontSize: 50),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.orange.shade600,
                                  ),
                                ),
                                errorWidget: (context, url, error) {
                                  print('Image load error for ${item.name}: $error');
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.emoji,
                                          style: const TextStyle(fontSize: 50),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'No image',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ))
                        : Center(
                            child: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                  ),
                ),
                if (item.popular)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_fire_department,
                              color: Colors.white, size: 12),
                          SizedBox(width: 2),
                          Text(
                            'Popular',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: item.available ? () => _addToCart(item) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Cart',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _cart.isEmpty
                          ? const Center(child: Text('Cart is empty'))
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: _cart.length,
                              itemBuilder: (context, index) {
                                final item = _cart[index];
                                return ListTile(
                                  leading: Text(
                                    item.emoji,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                  title: Text(item.name),
                                  subtitle: Text(
                                      '\$${item.price.toStringAsFixed(2)}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle),
                                        onPressed: () {
                                          setState(() {
                                            setModalState(() {
                                              if (item.quantity > 1) {
                                                _cart[index] = OrderItem(
                                                  name: item.name,
                                                  price: item.price,
                                                  quantity: item.quantity - 1,
                                                  emoji: item.emoji,
                                                );
                                              } else {
                                                _cart.removeAt(index);
                                              }
                                            });
                                          });
                                        },
                                      ),
                                      Text('${item.quantity}'),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle),
                                        onPressed: () {
                                          setState(() {
                                            setModalState(() {
                                              _cart[index] = OrderItem(
                                                name: item.name,
                                                price: item.price,
                                                quantity: item.quantity + 1,
                                                emoji: item.emoji,
                                              );
                                            });
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${_cartTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _cart.isEmpty
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _checkout();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Checkout',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

// ==================== ORDERS SCREEN ====================
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await FirebaseService.getOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  void _showReceipt(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🧾 Receipt',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          'Order #${order.orderId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order.createdAt,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(order.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Status:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Items:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  if (item.imageUrl != null &&
                                      item.imageUrl!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.imageUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                item.emoji,
                                                style: const TextStyle(
                                                    fontSize: 24),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item.emoji,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '\$${item.price.toStringAsFixed(2)} × ${item.quantity}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(thickness: 2),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${order.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '📦',
                        style: TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No orders yet',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _showReceipt(order),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${order.orderId.substring(0, 8)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order.status),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        order.status.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...order.items.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Text(item.emoji,
                                              style: const TextStyle(
                                                  fontSize: 24)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${item.name} x${item.quantity}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          Text(
                                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '\$${order.total.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: TextButton.icon(
                                    onPressed: () => _showReceipt(order),
                                    icon: const Icon(Icons.receipt_long),
                                    label: const Text('View Receipt'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ==================== BOOKING SCREEN ====================
class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<TimeSlot> _timeSlots = [];
  List<Booking> _myBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final slots = await FirebaseService.getTimeSlots();
    final bookings = await FirebaseService.getBookings();
    setState(() {
      _timeSlots = slots;
      _myBookings = bookings;
      _isLoading = false;
    });
  }

  Future<void> _bookSeat(String timeSlot) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await FirebaseService.bookSeat(timeSlot);

    if (mounted) {
      Navigator.pop(context);
      if (result['booking'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Seat booked successfully!')),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Booking failed')),
        );
      }
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text(
          'Cancellation within 10 minutes is free.\nAfter that, ₹100 fine will be charged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await FirebaseService.cancelBooking(bookingId);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Booking cancelled')),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Seat'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Available Time Slots',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._timeSlots.map((slot) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade600,
                            child:
                                const Icon(Icons.schedule, color: Colors.white),
                          ),
                          title: Text(slot.label),
                          subtitle: Text(
                            'Available: ${slot.total - slot.booked} / ${slot.total}',
                            style: TextStyle(
                              color: (slot.total - slot.booked) > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          trailing: (slot.total - slot.booked) > 0
                              ? ElevatedButton(
                                  onPressed: () => _bookSeat(slot.time),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade600,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Book'),
                                )
                              : const Text(
                                  'Full',
                                  style: TextStyle(color: Colors.red),
                                ),
                        ),
                      )),
                  const SizedBox(height: 32),
                  const Text(
                    'My Bookings',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_myBookings.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No bookings yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._myBookings.map((booking) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: booking.status == 'confirmed'
                                  ? Colors.green
                                  : booking.status == 'cancelled'
                                      ? Colors.red
                                      : Colors.grey,
                              child: Text(
                                '${booking.seatNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(booking.timeSlot),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(booking.date),
                                Text(
                                  'Status: ${booking.status.toUpperCase()}',
                                  style: TextStyle(
                                    color: booking.status == 'confirmed'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                if (booking.fine > 0)
                                  Text(
                                    'Fine: ₹${booking.fine.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                              ],
                            ),
                            trailing: booking.status == 'confirmed'
                                ? IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _cancelBooking(booking.bookingId),
                                  )
                                : null,
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

// ==================== COMPLAINTS SCREEN ====================
class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  List<Complaint> _complaints = [];
  bool _isLoading = true;
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);
    final complaints = await FirebaseService.getComplaints();
    setState(() {
      _complaints = complaints;
      _isLoading = false;
    });
  }

  Future<void> _submitComplaint() async {
    if (_subjectController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await FirebaseService.submitComplaint(
      _subjectController.text,
      _descriptionController.text,
    );

    if (mounted) {
      Navigator.pop(context);
      if (result['complaint'] != null) {
        _subjectController.clear();
        _descriptionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully!')),
        );
        _loadComplaints();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Submission failed')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in-progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComplaints,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadComplaints,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Submit a Complaint',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Complaint',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'My Complaints',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_complaints.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No complaints yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._complaints.map((complaint) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: Icon(
                              Icons.report_problem,
                              color: _getStatusColor(complaint.status),
                            ),
                            title: Text(complaint.subject),
                            subtitle: Text(
                              'Status: ${complaint.status.toUpperCase()}',
                              style: TextStyle(
                                color: _getStatusColor(complaint.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Description:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(complaint.description),
                                    if (complaint.response != null) ...[
                                      const SizedBox(height: 16),
                                      const Divider(),
                                      const Text(
                                        'Admin Response:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        complaint.response!,
                                        style: const TextStyle(
                                            color: Colors.green),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

// ==================== PROFILE SCREEN ====================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser? _user;
  bool _isLoading = true;
  bool _isEditMode = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final user = await FirebaseService.getCurrentUser();
    setState(() {
      _user = user;
      _nameController.text = user?.name ?? '';
      _phoneController.text = user?.phone ?? '';
      _studentIdController.text = user?.studentId ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await FirebaseService.updateProfile({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'studentId': _studentIdController.text,
    });

    if (mounted) {
      Navigator.pop(context);
      if (result['user'] != null) {
        setState(() {
          _isEditMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        _loadProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Update failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditMode = true);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                  _nameController.text = _user?.name ?? '';
                  _phoneController.text = _user?.phone ?? '';
                  _studentIdController.text = _user?.studentId ?? '';
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.orange.shade600,
                  child:
                      const Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 16),
                if (_isEditMode) ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _studentIdController,
                    decoration: InputDecoration(
                      labelText: 'Student ID',
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ] else ...[
                  Text(
                    _user?.name ?? 'Campus User',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user?.email ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _infoRow('Username', _user?.username ?? ''),
                        const Divider(),
                        _infoRow('Phone', _user?.phone ?? 'Not set'),
                        const Divider(),
                        _infoRow('Student ID', _user?.studentId ?? 'Not set'),
                        const Divider(),
                        _infoRow('User Type', _user?.userType ?? ''),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseService.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
