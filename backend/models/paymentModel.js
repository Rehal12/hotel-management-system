const pool = require('../config/db');

const Payment = {
  // Payment record mehfooz karna
  create: async (paymentData) => {
    const { booking_id, user_id, amount, payment_method, payment_status } = paymentData;
    const [result] = await pool.query(
      `INSERT INTO payments (booking_id, user_id, amount, payment_method, payment_status)
       VALUES (?, ?, ?, ?, ?)`,
      [booking_id, user_id, amount, payment_method, payment_status]
    );
    return result.insertId;
  },

  // Khaas customer ki payments lana
  findByUserId: async (userId) => {
    const [rows] = await pool.query(
      `SELECT p.*, b.guest_name, r.room_name 
       FROM payments p
       JOIN bookings b ON p.booking_id = b.booking_id
       JOIN rooms r ON b.room_id = r.room_id
       WHERE p.user_id = ?
       ORDER BY p.payment_date DESC`,
      [userId]
    );
    return rows;
  },

  // Sab payments lana (Admin ke dekhne ke liye)
  findAll: async () => {
    const [rows] = await pool.query(
      `SELECT p.*, b.guest_name, u.full_name as user_name 
       FROM payments p
       JOIN bookings b ON p.booking_id = b.booking_id
       JOIN users u ON p.user_id = u.id
       ORDER BY p.payment_date DESC`
    );
    return rows;
  }
};

module.exports = Payment;
