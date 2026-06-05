const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const errorHandler = require('./middleware/errorHandler');

// .env file se environment variables load karna
dotenv.config();

// Route files import karna
const userRoutes = require('./routes/userRoutes');
const roomRoutes = require('./routes/roomRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const paymentRoutes = require('./routes/paymentRoutes');
const auditLogRoutes = require('./routes/auditLogRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const analyticsRoutes = require('./routes/analyticsRoutes');

// Express app initialize karna
const app = express();

// Security headers lagana
app.use(helmet());

// General API rate limiter configure karna
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: 'Too many requests from this IP. Please try again after 15 minutes.'
  }
});
app.use('/api', apiLimiter);

// Aane wali JSON requests ko handle karne ke liye Body parser middleware
app.use(express.json());

// Frontend requests ke liye CORS enable karna
app.use(cors());

// Static image uploads ko serve karna
app.use('/uploads', express.static('uploads'));

// Testing ke liye basic route
app.get('/', (req, res) => {
  res.send('SARTE App Backend API is running');
});

// Routers ko mount karna
app.use('/api/users', userRoutes);
app.use('/api/rooms', roomRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/audit-logs', auditLogRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/analytics', analyticsRoutes);

// Custom error handler middleware istemal karna (sab routes ke baad hona chahiye)
app.use(errorHandler);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
