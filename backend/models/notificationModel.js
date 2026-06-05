const pool = require('../config/db');

const Notification = {
  // Naya notification banana
  create: async (userId, title, message) => {
    const [result] = await pool.query(
      'INSERT INTO notifications (user_id, title, message) VALUES (?, ?, ?)',
      [userId, title, message]
    );
    return result.insertId;
  },

  // User ke liye notifications lana
  findByUserId: async (userId) => {
    const [rows] = await pool.query(
      'SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC',
      [userId]
    );
    return rows;
  },

  // Notification ko read mark karna
  markAsRead: async (notificationId, userId) => {
    const [result] = await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE notification_id = ? AND user_id = ?',
      [notificationId, userId]
    );
    return result.affectedRows;
  },

  // User ke sab notifications ko read mark karna
  markAllAsRead: async (userId) => {
    const [result] = await pool.query(
      'UPDATE notifications SET is_read = TRUE WHERE user_id = ?',
      [userId]
    );
    return result.affectedRows;
  },

  // Notification ko delete karna
  delete: async (notificationId, userId) => {
    const [result] = await pool.query(
      'DELETE FROM notifications WHERE notification_id = ? AND user_id = ?',
      [notificationId, userId]
    );
    return result.affectedRows;
  }
};

module.exports = Notification;
