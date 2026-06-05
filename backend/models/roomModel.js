const pool = require('../config/db');

const Room = {
  // Sab rooms ko lana
  findAll: async () => {
    const [rows] = await pool.query('SELECT * FROM rooms');
    return rows;
  },

  // ID se room ko lana
  findById: async (id) => {
    const [rows] = await pool.query('SELECT * FROM rooms WHERE room_id = ?', [id]);
    return rows[0];
  },

  // Filters ke sath rooms dhundhna
  findFiltered: async (filters) => {
    const { search, room_type, min_price, max_price, room_status } = filters;

    let query = 'SELECT * FROM rooms WHERE 1=1';
    const queryParams = [];

    if (search) {
      query += ' AND (room_name LIKE ? OR room_description LIKE ?)';
      queryParams.push(`%${search}%`, `%${search}%`);
    }

    if (room_type && room_type !== 'all') {
      query += ' AND room_type = ?';
      queryParams.push(room_type);
    }

    if (min_price) {
      query += ' AND room_price >= ?';
      queryParams.push(parseFloat(min_price));
    }

    if (max_price) {
      query += ' AND room_price <= ?';
      queryParams.push(parseFloat(max_price));
    }

    if (room_status) {
      query += ' AND room_status = ?';
      queryParams.push(room_status);
    }

    const [rows] = await pool.query(query, queryParams);
    return rows;
  },

  // Naya room shamil karna
  create: async (roomData) => {
    const { room_name, room_type, room_price, room_status, room_description, image_url, amenities } = roomData;
    
    // MySQL storage ke liye amenities ko JSON string mein tabdeel karna
    const amenitiesJson = amenities ? (typeof amenities === 'string' ? amenities : JSON.stringify(amenities)) : null;

    const [result] = await pool.query(
      'INSERT INTO rooms (room_name, room_type, room_price, room_status, room_description, image_url, amenities) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        room_name, 
        room_type, 
        room_price, 
        room_status || 'available', 
        room_description || null,
        image_url || null,
        amenitiesJson
      ]
    );
    return result.insertId;
  },

  // Room ko update karna
  update: async (id, roomData) => {
    const { room_name, room_type, room_price, room_status, room_description, image_url, amenities } = roomData;
    
    const amenitiesJson = amenities ? (typeof amenities === 'string' ? amenities : JSON.stringify(amenities)) : null;

    const [result] = await pool.query(
      'UPDATE rooms SET room_name = ?, room_type = ?, room_price = ?, room_status = ?, room_description = ?, image_url = ?, amenities = ? WHERE room_id = ?',
      [
        room_name, 
        room_type, 
        room_price, 
        room_status, 
        room_description,
        image_url,
        amenitiesJson,
        id
      ]
    );
    return result.affectedRows;
  },

  // Room ko delete karna
  delete: async (id) => {
    const [result] = await pool.query('DELETE FROM rooms WHERE room_id = ?', [id]);
    return result.affectedRows;
  }
};

module.exports = Room;
