// Run this script with: node clear_menu.js
// This will clear old menu items so the server can reinitialize with real image URLs

const mongoose = require('mongoose');

mongoose.connect('mongodb://localhost:27017/campus_canteen', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

const db = mongoose.connection;

db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', async function() {
  console.log('Connected to MongoDB');
  
  try {
    // Delete all menu items
    const result = await mongoose.connection.collection('menuitems').deleteMany({});
    console.log(`✅ Deleted ${result.deletedCount} old menu items`);
    
    // Also delete bookings and maybe other data if needed
    // Uncomment if you want to reset everything:
    // await mongoose.connection.collection('bookings').deleteMany({});
    // await mongoose.connection.collection('orders').deleteMany({});
    
    console.log('✅ Database cleared! Restart backend to add items with real images.');
    process.exit(0);
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
});
