const pool = require('../config/db');

const Booking = {
  // Nayi booking banana
  create: async (bookingData) => {
    const {
      booking_id,
      user_id,
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
    } = bookingData;

    const [result] = await pool.query(
      `INSERT INTO bookings (
        booking_id, user_id, room_id, guest_name, guest_email, 
        check_in, check_out, guest_count, total_price, payment_method, booking_status, payment_status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        booking_id,
        user_id,
        room_id,
        guest_name,
        guest_email,
        check_in,
        check_out,
        guest_count,
        total_price,
        payment_method,
        booking_status || 'pending',
        payment_status || 'Pending'
      ]
    );
    return booking_id;
  },

  // Check karna ke room pehle se overlapping dates ke liye booked to nahi hai
  checkOverlap: async (roomId, checkIn, checkOut, excludeBookingId = null) => {
    let query = `
      SELECT COUNT(*) as count 
      FROM bookings 
      WHERE room_id = ? 
      AND booking_status NOT IN ('cancelled', 'rejected')
      AND check_in < ? 
      AND check_out > ?
    `;
    const params = [roomId, checkOut, checkIn];
    
    if (excludeBookingId) {
      query += ` AND booking_id != ?`;
      params.push(excludeBookingId);
    }
    
    const [rows] = await pool.query(query, params);
    return rows[0].count > 0;
  },

  // Khaas customer/user ki bookings lana
  findByUserId: async (userId) => {
    const [rows] = await pool.query(
      `SELECT b.*, r.room_name, r.room_type, r.room_price, r.room_status, r.room_description 
       FROM bookings b 
       JOIN rooms r ON b.room_id = r.room_id 
       WHERE b.user_id = ? 
       ORDER BY b.booking_date DESC`,
      [userId]
    );
    return rows;
  },

  // Hotel ki sab bookings lana (staff/admin ke dekhne ke liye)
  findAll: async () => {
    const [rows] = await pool.query(
      `SELECT b.*, r.room_name, r.room_type, r.room_price, r.room_status, r.room_description, u.full_name as user_name 
       FROM bookings b 
       JOIN rooms r ON b.room_id = r.room_id 
       JOIN users u ON b.user_id = u.id 
       ORDER BY b.booking_date DESC`
    );
    return rows;
  },

  // ID se booking ki details lana
  findById: async (id) => {
    const [rows] = await pool.query(
      `SELECT b.*, r.room_name, r.room_type, r.room_price, r.room_status, r.room_description 
       FROM bookings b 
       JOIN rooms r ON b.room_id = r.room_id 
       WHERE b.booking_id = ?`,
      [id]
    );
    return rows[0];
  },

  // Booking ka status update karna
  updateStatus: async (id, status) => {
    const [result] = await pool.query(
      'UPDATE bookings SET booking_status = ? WHERE booking_id = ?',
      [status, id]
    );
    return result.affectedRows;
  },

  // Payment ka status update karna
  updatePaymentStatus: async (id, paymentStatus) => {
    const [result] = await pool.query(
      'UPDATE bookings SET payment_status = ? WHERE booking_id = ?',
      [paymentStatus, id]
    );
    return result.affectedRows;
  },

  // Booking ko delete karna
  delete: async (id) => {
    const [result] = await pool.query('DELETE FROM bookings WHERE booking_id = ?', [id]);
    return result.affectedRows;
  }
};

module.exports = Booking;
