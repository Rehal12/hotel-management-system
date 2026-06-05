const express = require('express');
const router = express.Router();
const { processPayment, getMyPayments, getAllPayments } = require('../controllers/paymentController');
const { protect, restrictTo } = require('../middleware/authMiddleware');

router.route('/')
  .post(protect, processPayment) // Reservation ki payment karna
  .get(protect, restrictTo('admin'), getAllPayments); // Admin ka sab transactions lana

router.route('/my-payments')
  .get(protect, getMyPayments); // User ka apni transactions dekhna

module.exports = router;
