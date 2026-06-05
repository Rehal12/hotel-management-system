const Payment = require('../models/paymentModel');
const Booking = require('../models/bookingModel');
const AuditLog = require('../models/auditLogModel');
const Notification = require('../models/notificationModel');

// @desc    Transaction record process karna
// @route   POST /api/payments
const processPayment = async (req, res, next) => {
  try {
    const { booking_id, amount, payment_method, card_number } = req.body;

    if (!booking_id || amount === undefined || !payment_method) {
      res.status(400);
      throw new Error('Please provide booking_id, amount, and payment_method');
    }

    const booking = await Booking.findById(booking_id);
    if (!booking) {
      res.status(404);
      throw new Error('Booking not found');
    }

    let payment_status = 'Paid (Demo)';
    // Card check ki nakal: agar card 4242 par khatam nahi hota to demo visuals ke liye warning log karna
    if (payment_method.toLowerCase().includes('card') && card_number) {
      const sanitized = card_number.replace(/\s/g, '');
      if (sanitized.length > 0 && !sanitized.endsWith('4242')) {
        // Locally log karna ya ijazat dena, lekin hum ise Paid (Demo) mark kar rahe hain
      }
    }

    // Payment ki entry banana
    const paymentId = await Payment.create({
      booking_id,
      user_id: req.user.id,
      amount,
      payment_method,
      payment_status
    });

    // Booking status ko Approved aur payment status ko Paid (Demo) update karna
    await Booking.updatePaymentStatus(booking_id, 'Paid (Demo)');
    await Booking.updateStatus(booking_id, 'approved');

    // Audit Log
    await AuditLog.log(
      req.user.id,
      'Payment Processed',
      `Processed payment ID ${paymentId} of $${amount} for Booking ID ${booking_id} via ${payment_method}`
    );

    // User ko Notification bhejna
    await Notification.create(
      booking.user_id,
      'Payment Received',
      `We have received your payment of $${amount} for reservation ${booking_id}. Your booking is now APPROVED.`
    );

    res.status(201).json({
      success: true,
      message: 'Payment processed successfully',
      data: {
        payment_id: paymentId,
        booking_id,
        amount,
        payment_method,
        payment_status
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    User ki transaction history lana
// @route   GET /api/payments/my-payments
const getMyPayments = async (req, res, next) => {
  try {
    const payments = await Payment.findByUserId(req.user.id);
    res.status(200).json({ success: true, count: payments.length, data: payments });
  } catch (error) {
    next(error);
  }
};

// @desc    Sab transactions lana (Admin view)
// @route   GET /api/payments
const getAllPayments = async (req, res, next) => {
  try {
    const payments = await Payment.findAll();
    res.status(200).json({ success: true, count: payments.length, data: payments });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  processPayment,
  getMyPayments,
  getAllPayments
};
