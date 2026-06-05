const Booking = require('../models/bookingModel');
const Room = require('../models/roomModel');
const AuditLog = require('../models/auditLogModel');
const Notification = require('../models/notificationModel');

// @desc    Nayi booking reservation banana
// @route   POST /api/bookings
const createBooking = async (req, res, next) => {
  try {
    const {
      room_id,
      guest_name,
      guest_email,
      check_in,
      check_out,
      guest_count,
      total_price,
      payment_method
    } = req.body;

    // Inputs ki tasdeeq karna
    if (!room_id || !guest_name || !guest_email || !check_in || !check_out || !guest_count || total_price === undefined || !payment_method) {
      res.status(400);
      throw new Error('Please provide all required booking parameters');
    }

    // Room ki mojoodgi verify karna
    const room = await Room.findById(room_id);
    if (!room) {
      res.status(404);
      throw new Error('Room not found');
    }

    // Reservation ki taareekh mein overlap check karna
    const hasOverlap = await Booking.checkOverlap(room_id, check_in, check_out);
    if (hasOverlap) {
      res.status(400);
      throw new Error('The selected room is already booked for these dates.');
    }

    // Unique Booking ID generate karna (jaise bk-1025)
    const booking_id = `bk-${Math.floor(1000 + Math.random() * 9000)}`;

    // Payment method ke hisaab se statuses set karna
    let booking_status = 'pending';
    let payment_status = 'Pending';

    // Prepaid methods se booking aur payment foran approve hoti hai
    const prepaidMethods = ['Credit Card', 'SARTE Wallet', 'UPI / Net Banking', 'Wallet', 'Card', 'UPI'];
    const isPrepaid = prepaidMethods.some(method => payment_method.toLowerCase().includes(method.toLowerCase()));

    if (isPrepaid) {
      booking_status = 'approved';
      payment_status = 'Paid (Demo)';
    }

    const bookingData = {
      booking_id,
      user_id: req.user.id, // JWT verification payload se set hua hai
      room_id,
      guest_name,
      guest_email,
      check_in,
      check_out,
      guest_count,
      total_price,
      payment_method,
      booking_status,
      payment_status
    };

    await Booking.create(bookingData);

    // Audit log likhna
    await AuditLog.log(
      req.user.id,
      'Booking Created',
      `Created booking ID ${booking_id} for Room "${room.room_name}" (${check_in} to ${check_out}) via ${payment_method}`
    );

    // Notifications bhejna
    await Notification.create(
      req.user.id,
      'Reservation Confirmed',
      `Your reservation ${booking_id} for "${room.room_name}" has been successfully registered. Status: ${booking_status.toUpperCase()}`
    );

    res.status(201).json({
      success: true,
      message: 'Booking created successfully',
      booking_id,
      data: bookingData
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Active logged-in customer ki booking history lana
// @route   GET /api/bookings/my
const getUserBookings = async (req, res, next) => {
  try {
    const bookings = await Booking.findByUserId(req.user.id);
    res.status(200).json({
      success: true,
      count: bookings.length,
      data: bookings
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Sab bookings lana (sirf Staff/Admin ke liye)
// @route   GET /api/bookings
const getAllBookings = async (req, res, next) => {
  try {
    const bookings = await Booking.findAll();
    res.status(200).json({
      success: true,
      count: bookings.length,
      data: bookings
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Booking reservation ka status update karna (Staff/Admin function)
// @route   PUT /api/bookings/:id/status
const updateBookingStatus = async (req, res, next) => {
  try {
    const bookingId = req.params.id;
    const { status } = req.body;

    if (!status) {
      res.status(400);
      throw new Error('Please provide status');
    }

    const booking = await Booking.findById(bookingId);
    if (!booking) {
      res.status(404);
      throw new Error('Booking record not found');
    }

    // Role-based verification: Aam users sirf apni bookings cancel kar sakte hain
    if (req.user.role !== 'admin' && req.user.role !== 'staff') {
      if (status !== 'cancelled') {
        res.status(403);
        throw new Error('Forbidden: Regular users can only cancel reservations');
      }
      if (booking.user_id !== req.user.id) {
        res.status(403);
        throw new Error('Forbidden: You can only cancel your own reservations');
      }
    }

    await Booking.updateStatus(bookingId, status);

    // Audit log likhna
    await AuditLog.log(
      req.user.id,
      'Booking Status Changed',
      `Booking ID ${bookingId} status updated to ${status} by user ID ${req.user.id}`
    );

    // User ko notification bhejna
    await Notification.create(
      booking.user_id,
      'Booking Status Update',
      `Your reservation ${bookingId} status has been updated to: ${status.toUpperCase()}`
    );

    res.status(200).json({
      success: true,
      message: `Booking status updated to ${status} successfully`
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createBooking,
  getUserBookings,
  getAllBookings,
  updateBookingStatus
};
