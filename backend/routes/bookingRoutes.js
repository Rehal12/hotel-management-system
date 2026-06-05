const express = require('express');
const router = express.Router();
const {
  createBooking,
  getUserBookings,
  getAllBookings,
  updateBookingStatus
} = require('../controllers/bookingController');
const { protect, restrictTo } = require('../middleware/authMiddleware');

// JWT auth protection ke sath routes lagana
router.route('/')
  .post(protect, createBooking) // Customer ka reservation karna
  .get(protect, restrictTo('staff', 'admin'), getAllBookings); // Staff/Admin ka sab bookings dekhna

router.route('/my')
  .get(protect, getUserBookings); // Customer ka apni logs dekhna

router.route('/:id/status')
  .put(protect, updateBookingStatus); // Status update karna (ownership controller mein check hoti hai)

module.exports = router;
