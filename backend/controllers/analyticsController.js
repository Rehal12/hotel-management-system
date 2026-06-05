const pool = require('../config/db');

// @desc    Dashboard metrics lana (sirf Admin/Staff ke liye)
// @route   GET /api/analytics
const getDashboardMetrics = async (req, res, next) => {
  try {
    // 1. Kul Mehfooz Revenue
    const [revenueRow] = await pool.query(
      "SELECT SUM(total_price) as total FROM bookings WHERE booking_status IN ('approved', 'completed')"
    );
    const totalRevenue = parseFloat(revenueRow[0].total || 0);

    // 2. Room ki qabzagi (Occupancy)
    const [totalRoomsRow] = await pool.query("SELECT COUNT(*) as count FROM rooms");
    const [occupiedRoomsRow] = await pool.query(
      "SELECT COUNT(DISTINCT room_id) as count FROM bookings WHERE booking_status = 'approved'"
    );
    const totalRooms = totalRoomsRow[0].count || 0;
    const occupiedRooms = occupiedRoomsRow[0].count || 0;
    const occupancyRate = totalRooms > 0 ? Math.round((occupiedRooms / totalRooms) * 100) : 0;

    // 3. Bookings ki ginti
    const [bookingsCountRow] = await pool.query("SELECT COUNT(*) as count FROM bookings");
    const totalBookings = bookingsCountRow[0].count || 0;

    // 4. Staff members ki ginti
    const [staffCountRow] = await pool.query("SELECT COUNT(*) as count FROM users WHERE role = 'staff'");
    const totalStaff = staffCountRow[0].count || 0;

    // 5. Hafta-waar/Rozana revenue chart ka data
    const [weeklyRevenue] = await pool.query(
      `SELECT DATE_FORMAT(booking_date, '%Y-%m-%d') as date, SUM(total_price) as revenue 
       FROM bookings 
       WHERE booking_status IN ('approved', 'completed')
       GROUP BY DATE(booking_date) 
       ORDER BY date DESC 
       LIMIT 7`
    );

    res.status(200).json({
      success: true,
      data: {
        totalRevenue,
        occupancyRate,
        totalBookings,
        totalStaff,
        weeklyRevenue: weeklyRevenue.reverse()
      }
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getDashboardMetrics };
