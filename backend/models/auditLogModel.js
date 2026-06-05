const pool = require('../config/db');

const AuditLog = {
  // Audit log ki entry banana
  log: async (userId, action, description) => {
    try {
      const [result] = await pool.query(
        'INSERT INTO audit_logs (user_id, action, description) VALUES (?, ?, ?)',
        [userId || null, action, description || null]
      );
      return result.insertId;
    } catch (err) {
      console.error('Failed to write audit log:', err.message);
    }
  },

  // Sab audit logs lana
  findAll: async () => {
    const [rows] = await pool.query(
      `SELECT a.*, u.full_name as user_name, u.email as user_email 
       FROM audit_logs a 
       LEFT JOIN users u ON a.user_id = u.id 
       ORDER BY a.created_at DESC`
    );
    return rows;
  }
};

module.exports = AuditLog;
