const pool = require('../config/db');

// Users se mutaliq database queries rakhne ke liye User Model object bana rahe hain
const User = {
  // Sab users ko dhundhna
  findAll: async () => {
    const [rows] = await pool.query('SELECT id, full_name, email, phone, role FROM users');
    return rows;
  },

  // Email se user dhundhna (duplicates check karne aur login ke liye mufeed)
  findByEmail: async (email) => {
    const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    return rows[0];
  },

  // ID se user dhundhna
  findById: async (id) => {
    const [rows] = await pool.query('SELECT id, full_name, email, phone, role FROM users WHERE id = ?', [id]);
    return rows[0];
  },

  // Naya user banana
  create: async (userData) => {
    const { full_name, email, password, phone, role } = userData;
    // SQL Injection se bachne ke liye parameterized queries istemal hui hain
    const [result] = await pool.query(
      'INSERT INTO users (full_name, email, password, phone, role) VALUES (?, ?, ?, ?, ?)',
      [full_name, email, password, phone || null, role || 'user']
    );
    return result.insertId;
  },

  // Maujooda user ko update karna
  update: async (id, userData) => {
    const { full_name, email, phone, role } = userData;
    const [result] = await pool.query(
      'UPDATE users SET full_name = ?, email = ?, phone = ?, role = ? WHERE id = ?',
      [full_name, email, phone, role, id]
    );
    return result.affectedRows;
  },

  // Nakaam login koshishon ko update karna
  updateFailedAttempts: async (id, attempts) => {
    const [result] = await pool.query(
      'UPDATE users SET failed_login_attempts = ? WHERE id = ?',
      [attempts, id]
    );
    return result.affectedRows;
  },

  // User account ko lock karna
  lockAccount: async (id, lockUntil) => {
    const [result] = await pool.query(
      'UPDATE users SET lock_until = ? WHERE id = ?',
      [lockUntil, id]
    );
    return result.affectedRows;
  },

  // Nakaam login koshishon aur lock status ko reset karna
  resetFailedAttempts: async (id) => {
    const [result] = await pool.query(
      'UPDATE users SET failed_login_attempts = 0, lock_until = NULL WHERE id = ?',
      [id]
    );
    return result.affectedRows;
  },

  // OTP details ko update karna
  updateOTP: async (email, otp, expiry) => {
    const [result] = await pool.query(
      'UPDATE users SET reset_otp = ?, reset_otp_expiry = ? WHERE email = ?',
      [otp, expiry, email]
    );
    return result.affectedRows;
  },

  // User ka password update karna
  updatePassword: async (email, hashedPassword) => {
    const [result] = await pool.query(
      'UPDATE users SET password = ?, reset_otp = NULL, reset_otp_expiry = NULL WHERE email = ?',
      [hashedPassword, email]
    );
    return result.affectedRows;
  },

  // User ko delete karna
  delete: async (id) => {
    const [result] = await pool.query('DELETE FROM users WHERE id = ?', [id]);
    return result.affectedRows;
  },

  // Khaas role wale sab users ko dhundhna
  findByRole: async (role) => {
    const [rows] = await pool.query('SELECT id, full_name, email, phone, role, created_at FROM users WHERE role = ?', [role]);
    return rows;
  },

  // Sab staff aur admin users ko dhundhna
  findAllStaff: async () => {
    const [rows] = await pool.query('SELECT id, full_name, email, phone, role, created_at FROM users WHERE role IN (?, ?)', ['staff', 'admin']);
    return rows;
  }
};

module.exports = User;
