# 🍽️ Campus Canteen Management System

> A modern, full-stack web application for managing campus canteen operations with real-time order processing, seat booking, and advanced business analytics.

![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)
![Express.js](https://img.shields.io/badge/Express.js-404D59?style=for-the-badge)
![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)
![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Screenshots](#-screenshots)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [API Endpoints](#-api-endpoints)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### 🎓 Student Features
- **User Authentication**
  - Secure registration with email OTP verification
  - JWT-based authentication
  - Profile management with image upload
  
- **Menu & Ordering**
  - Browse menu with real-time availability
  - Add items to cart with quantity selection
  - Multiple payment options (Card, UPI, Cash)
  - Order history tracking
  
- **Seat Booking**
  - Book seats for specific time slots
  - Automatic seat number assignment
  - Auto-release after time slot expires
  - Real-time availability status
  
- **Complaint Management**
  - Submit and track complaints
  - Real-time status updates
  - Response from admin
  
- **Email Notifications**
  - Welcome email with OTP verification
  - Order receipt with itemized details
  - Professional HTML email templates

### 👨‍💼 Admin Features
- **Dashboard Analytics**
  - Real-time business metrics
  - Revenue tracking (Today, Week, Month, Year)
  - Order and booking statistics
  
- **Advanced Analytics**
  - Category-wise revenue analysis
  - Top-selling items with rankings
  - Hourly sales patterns
  - Customer spending analysis with real names
  - Performance metrics
  
- **Menu Management**
  - Add, edit, delete menu items
  - Set availability and pricing
  - Categorize items (Breakfast, Lunch, Snacks, Beverages, Desserts)
  
- **Booking Management**
  - View all seat bookings
  - Time slot management
  - Automatic cleanup of expired bookings
  
- **Complaint Resolution**
  - View and respond to student complaints
  - Track complaint status
  - Resolution tracking
  
- **Notice Board**
  - Create and manage notices
  - Set urgency levels
  - Schedule expiry dates

### 🔐 Security Features
- Password hashing with bcryptjs
- JWT token authentication
- Email verification
- Protected API routes
- Input validation

### 📧 Email Integration
- Nodemailer integration
- Gmail SMTP support
- Professional HTML templates
- OTP verification emails
- Order receipt emails

---

## 🛠️ Tech Stack

### Backend
- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM
- **JWT** - Authentication
- **bcryptjs** - Password hashing
- **Nodemailer** - Email service
- **dotenv** - Environment variables

### Frontend
- **HTML5** - Markup
- **CSS3** - Styling
- **JavaScript (ES6+)** - Logic
- **Tailwind CSS** - Utility-first CSS framework
- **Font Awesome** - Icons

### Database
- **MongoDB** - NoSQL database
- **Aggregation Pipeline** - Advanced analytics

---

## 📸 Screenshots

### Student Dashboard
![Student Dashboard](screenshots/student-dashboard.png)

### Admin Analytics
![Admin Analytics](screenshots/admin-analytics.png)

### Order Receipt Email
![Order Receipt](screenshots/email-receipt.png)

---

## 🚀 Installation

### Prerequisites
- Node.js (v14 or higher)
- MongoDB (v4.4 or higher)
- Gmail account (for email features)

### Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/campus-canteen.git
cd campus-canteen
```

2. **Install backend dependencies**
```bash
cd backend
npm install
```

3. **Set up environment variables**
Create a `.env` file in the `backend` folder:
```env
MONGODB_URI=mongodb://localhost:27017/campus_canteen
JWT_SECRET=your_secret_key_here
PORT=5000

# Email Configuration
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password-here
```

4. **Start MongoDB**
```bash
mongod
```

5. **Start the backend server**
```bash
cd backend
node server.js
```

6. **Open the frontend**
Open `frontend/index.html` in your browser or use a local server:
```bash
# Using Python
cd frontend
python -m http.server 8000

# Using Node.js http-server
npx http-server frontend -p 8000
```

7. **Access the application**
```
Frontend: http://localhost:8000
Backend API: http://localhost:5000
```

---

## ⚙️ Configuration

### Gmail App Password Setup

1. Enable 2-Step Verification on your Google Account
2. Go to [Google App Passwords](https://myaccount.google.com/apppasswords)
3. Create a new app password for "Mail"
4. Copy the 16-character password
5. Add to `.env` file:
```env
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=xxxx-xxxx-xxxx-xxxx
```

### MongoDB Configuration

Default connection string:
```
mongodb://localhost:27017/campus_canteen
```

For MongoDB Atlas (cloud):
```
mongodb+srv://username:password@cluster.mongodb.net/campus_canteen
```

---

## 📖 Usage

### Student Account
1. **Register** with email, username, and password
2. **Verify email** using OTP sent to your inbox
3. **Login** to access dashboard
4. **Browse menu** and add items to cart
5. **Complete payment** and receive order receipt via email
6. **Book seats** for dining
7. **Submit complaints** if needed

### Admin Account
1. **Login** with owner credentials
2. **View analytics** on dashboard
3. **Manage menu** items
4. **Monitor bookings** and orders
5. **Respond** to complaints
6. **Create notices** for students

### Default Admin Credentials
```
Username: admin
Password: admin123
```
⚠️ **Change these credentials after first login!**

---

## 🌐 API Endpoints

### Authentication
```
POST   /api/register        - Register new user with OTP
POST   /api/send-otp        - Send OTP to email
POST   /api/login           - User login
GET    /api/profile         - Get user profile
PUT    /api/profile         - Update user profile
```

### Menu
```
GET    /api/menu            - Get all menu items
POST   /api/menu            - Add menu item (Admin)
PUT    /api/menu/:id        - Update menu item (Admin)
DELETE /api/menu/:id        - Delete menu item (Admin)
```

### Orders
```
GET    /api/orders          - Get user orders
POST   /api/orders          - Create new order
GET    /api/admin/orders    - Get all orders (Admin)
PATCH  /api/orders/:id      - Update order status (Admin)
```

### Bookings
```
GET    /api/bookings        - Get user bookings
POST   /api/bookings        - Create booking
GET    /api/admin/bookings  - Get all bookings (Admin)
PATCH  /api/bookings/:id/cancel   - Cancel booking
PATCH  /api/bookings/:id/complete - Complete booking
```

### Analytics
```
GET    /api/admin/advanced-analytics    - Get business analytics
GET    /api/admin/inventory-alerts      - Get inventory alerts
GET    /api/admin/performance-metrics   - Get performance metrics
```

### Complaints
```
GET    /api/complaints         - Get user complaints
POST   /api/complaints         - Submit complaint
GET    /api/admin/complaints   - Get all complaints (Admin)
PATCH  /api/complaints/:id     - Respond to complaint (Admin)
```

### Notices
```
GET    /api/notices            - Get all notices
POST   /api/notices            - Create notice (Admin)
PUT    /api/notices/:id        - Update notice (Admin)
DELETE /api/notices/:id        - Delete notice (Admin)
```

---

## 📁 Project Structure

```
campus-canteen/
├── backend/
│   ├── node_modules/
│   ├── config/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── .env
│   ├── server.js
│   └── package.json
│
├── frontend/
│   ├── assets/
│   ├── css/
│   ├── js/
│   ├── index.html
│   └── payment.html
│
└── README.md
```

---

## 🔄 Key Workflows

### Order Processing
1. Student adds items to cart
2. Proceeds to payment page
3. Selects payment method
4. Order created in database
5. Email receipt sent automatically
6. Order appears in history

### Seat Booking
1. Student selects time slot
2. System assigns seat number
3. Booking confirmed with expiry time
4. Auto-cleanup runs every 5 minutes
5. Expired bookings released automatically

### Email OTP Verification
1. User enters email during registration
2. OTP sent to email
3. Email field locked after sending OTP
4. User enters 6-digit OTP
5. Registration completes after verification

---

## 🎨 Features Highlights

### MongoDB Aggregation Pipeline
```javascript
// Category-wise revenue analysis
$group: {
  _id: '$category',
  totalRevenue: { $sum: '$total' },
  totalOrders: { $sum: 1 },
  avgOrderValue: { $avg: '$total' }
}
```

### Automatic Seat Cleanup
```javascript
// Runs every 5 minutes
setInterval(cleanupExpiredBookings, 5 * 60 * 1000);
```

### Email Templates
- Professional HTML design
- Gradient headers
- Responsive layout
- Order itemization
- Dynamic content

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Aryan Shivatare**
- GitHub: [@aryanshivatare](https://github.com/aryanshivatare)
- Email: aryan.shivatare24@vit.edu

---

## 🙏 Acknowledgments

- Thanks to all contributors
- Inspired by modern campus management systems
- Built with ❤️ for students

---

## 📞 Support

For support, email aryan.shivatare24@vit.edu or create an issue in the repository.

---

## 🔮 Future Enhancements

- [ ] Mobile app (React Native)
- [ ] Real-time notifications (Socket.io)
- [ ] Payment gateway integration (Razorpay)
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Advanced reporting (PDF export)
- [ ] Loyalty points system
- [ ] Menu recommendations (ML)

---

**⭐ Star this repository if you found it helpful!**

---

*Made with 💖 by Campus Canteen Team*
