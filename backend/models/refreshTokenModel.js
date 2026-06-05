const pool = require('../config/db');

const RefreshToken = {
  create: async (userId, token, expiresAt) => {
    const [result] = await pool.query(
      'INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES (?, ?, ?)',
      [userId, token, expiresAt]
    );
    return result.insertId;
  },

  findByToken: async (token) => {
    const [rows] = await pool.query(
      'SELECT * FROM refresh_tokens WHERE token = ?',
      [token]
    );
    return rows[0];
  },

  deleteByToken: async (token) => {
    const [result] = await pool.query(
      'DELETE FROM refresh_tokens WHERE token = ?',
      [token]
    );
    return result.affectedRows;
  },

  deleteByUserId: async (userId) => {
    const [result] = await pool.query(
      'DELETE FROM refresh_tokens WHERE user_id = ?',
      [userId]
    );
    return result.affectedRows;
  }
};

module.exports = RefreshToken;
