const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
require('dotenv').config();

const dbHost = process.env.DB_HOST || 'localhost';
const dbUser = process.env.DB_USER || 'root';
const dbPassword = process.env.DB_PASSWORD || '';
const dbName = process.env.DB_NAME || 'sarte_app_db';

// Database ke liye connection pool banana
const pool = mysql.createPool({
  host: dbHost,
  user: dbUser,
  password: dbPassword,
  database: dbName,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Database, tables aur seed data ko asynchronously initialize karna
async function initializeDatabase() {
  let connection;
  try {
    // 1. Database name diye bina connect karna taake check ho ke database mojood hai
    connection = await mysql.createConnection({
      host: dbHost,
      user: dbUser,
      password: dbPassword
    });

    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\`;`);
    await connection.end();

    console.log(`Database '${dbName}' verified/created.`);

    // 2. Roles Table ko verify aur create karna
    await pool.query(`
      CREATE TABLE IF NOT EXISTS roles (
        role_id INT AUTO_INCREMENT PRIMARY KEY,
        role_name VARCHAR(50) NOT NULL UNIQUE
      )
    `);
    console.log("Roles table verified.");

    // Roles ko seed karna
    const [existingRoles] = await pool.query('SELECT * FROM roles LIMIT 1');
    if (existingRoles.length === 0) {
      await pool.query(`
        INSERT INTO roles (role_name) VALUES ('admin'), ('staff'), ('user'), ('guest')
      `);
      console.log("Seeded roles.");
    }

    // 3. Permissions Table ko verify aur create karna
    await pool.query(`
      CREATE TABLE IF NOT EXISTS permissions (
        permission_id INT AUTO_INCREMENT PRIMARY KEY,
        role_id INT NOT NULL,
        resource VARCHAR(50) NOT NULL,
        action VARCHAR(50) NOT NULL,
        FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
      )
    `);
    console.log("Permissions table verified.");

    // 4. Users Table ko verify aur create karna
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        full_name VARCHAR(100) NOT NULL,
        email VARCHAR(100) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        phone VARCHAR(20) NULL,
        role ENUM('user', 'staff', 'admin', 'guest') DEFAULT 'user',
        failed_login_attempts INT DEFAULT 0,
        lock_until TIMESTAMP NULL,
        reset_otp VARCHAR(6) NULL,
        reset_otp_expiry TIMESTAMP NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log("Users table verified.");

    // Users table ke liye safety checks alter karna
    const userColumnsToVerify = [
      { name: 'phone', type: 'VARCHAR(20) NULL' },
      { name: 'failed_login_attempts', type: 'INT DEFAULT 0' },
      { name: 'lock_until', type: 'TIMESTAMP NULL' },
      { name: 'reset_otp', type: 'VARCHAR(6) NULL' },
      { name: 'reset_otp_expiry', type: 'TIMESTAMP NULL' }
    ];

    for (const col of userColumnsToVerify) {
      try {
        await pool.query(`ALTER TABLE users ADD COLUMN ${col.name} ${col.type}`);
        console.log(`Users ${col.name} column verified/added.`);
      } catch (_) {}
    }

    try {
      await pool.query(`ALTER TABLE users MODIFY COLUMN role ENUM('user', 'staff', 'admin', 'guest') DEFAULT 'user'`);
    } catch (_) {}

    // 5. Staff Table ko verify aur create karna
    await pool.query(`
      CREATE TABLE IF NOT EXISTS staff (
        staff_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL UNIQUE,
        department VARCHAR(100) NULL,
        permissions TEXT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);
    console.log("Staff table verified.");

    // 6. Rooms Table ko verify aur create karna
    await pool.query(`
      CREATE TABLE IF NOT EXISTS rooms (
        room_id INT AUTO_INCREMENT PRIMARY KEY,
        room_name VARCHAR(100) NOT NULL,
        room_type VARCHAR(50) NOT NULL,
        room_price DECIMAL(10, 2) NOT NULL,
        room_status ENUM('available', 'booked', 'maintenance') DEFAULT 'available',
        room_description TEXT,
        image_url VARCHAR(255) NULL,
        amenities JSON NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log("Rooms table verified.");

    // Rooms table ke liye safety checks alter karna
    try {
      await pool.query(`ALTER TABLE rooms ADD COLUMN image_url VARCHAR(255) NULL`);
    } catch (_) {}
    try {
      await pool.query(`ALTER TABLE rooms ADD COLUMN amenities JSON NULL`);
    } catch (_) {}

    // 7. Bookings Table ko verify aur create karna
    await pool.query(`
      CREATE TABLE IF NOT EXISTS bookings (
        booking_id VARCHAR(50) PRIMARY KEY,
        user_id INT NOT NULL,
        room_id INT NOT NULL,
        guest_name VARCHAR(100) NOT NULL,
        guest_email VARCHAR(100) NOT NULL,
        check_in DATE NOT NULL,
        check_out DATE NOT NULL,
        guest_count INT NOT NULL,
        total_price DECIMAL(10, 2) NOT NULL,
        booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        payment_method VARCHAR(50) NOT NULL,
        status ENUM('upcoming', 'completed', 'cancelled') DEFAULT 'upcoming',
        booking_status ENUM('pending', 'approved', 'rejected', 'cancelled') DEFAULT 'pending',
        payment_status ENUM('Pending', 'Paid (Demo)') DEFAULT 'Pending',
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (room_id) REFERENCES rooms(room_id) ON DELETE CASCADE
      )
    `);
    console.log("Bookings table verified.");

    // Bookings table ke liye safety checks alter karna
    try {
      await pool.query(`ALTER TABLE bookings ADD COLUMN booking_status ENUM('pending', 'approved', 'rejected', 'cancelled') DEFAULT 'pending'`);
    } catch (_) {}
    try {
      await pool.query(`ALTER TABLE bookings ADD COLUMN payment_method VARCHAR(50) NOT NULL DEFAULT 'Cash on Arrival'`);
    } catch (_) {}
    try {
      await pool.query(`ALTER TABLE bookings ADD COLUMN payment_status ENUM('Pending', 'Paid (Demo)') DEFAULT 'Pending'`);
    } catch (_) {}

    // 8. Booking History Table ko verify aur create karna
    await pool.query(`
      CREATE TABLE IF NOT EXISTS booking_history (
        history_id INT AUTO_INCREMENT PRIMARY KEY,
        booking_id VARCHAR(50) NOT NULL,
        user_id INT NOT NULL,
        room_id INT NOT NULL,
        room_name VARCHAR(100) NOT NULL,
        room_type VARCHAR(50) NOT NULL,
        check_in DATE NOT NULL,
        check_out DATE NOT NULL,
        total_price DECIMAL(10, 2) NOT NULL,
        payment_method VARCHAR(50) NOT NULL,
        status VARCHAR(50) NOT NULL,
        action_by INT NULL,
        action VARCHAR(100) NOT NULL,
        action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
      )
    `);
    console.log("Booking History table verified.");

    // 9. Payments Table ko verify aur create karna
    await pool.query(`
      CREATE TABLE IF NOT EXISTS payments (
        payment_id INT AUTO_INCREMENT PRIMARY KEY,
        booking_id VARCHAR(50) NOT NULL,
        user_id INT NOT NULL,
        amount DECIMAL(10, 2) NOT NULL,
        payment_method VARCHAR(50) NOT NULL,
        payment_status VARCHAR(50) NOT NULL,
        payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);
    console.log("Payments table verified.");

    // 10. Audit Logs Table ko verify aur create karna
    await pool.query(`
      CREATE TABLE IF NOT EXISTS audit_logs (
        log_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NULL,
        action VARCHAR(100) NOT NULL,
        description TEXT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log("Audit logs table verified.");

    // 11. Refresh Tokens Table ko verify aur create karna
    await pool.query(`
      CREATE TABLE IF NOT EXISTS refresh_tokens (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        token VARCHAR(255) NOT NULL UNIQUE,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);
    console.log("Refresh tokens table verified.");

    // 12. Notifications Table ko verify aur create karna
    await pool.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        notification_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);
    console.log("Notifications table verified.");

    // 13. Agar koi admin ya staff nahi hai to default users ko seed karna
    const [existingAdmin] = await pool.query('SELECT * FROM users WHERE role = "admin" LIMIT 1');
    if (existingAdmin.length === 0) {
      const salt = await bcrypt.genSalt(10);
      const adminHash = await bcrypt.hash('adminpassword', salt);
      const staffHash = await bcrypt.hash('staffpassword', salt);

      await pool.query(
        'INSERT INTO users (full_name, email, password, role) VALUES (?, ?, ?, ?), (?, ?, ?, ?)',
        [
          'SARTE Admin', 'admin@sarte.com', adminHash, 'admin',
          'Staff Elena', 'staff@sarte.com', staffHash, 'staff'
        ]
      );
      console.log('Seeded default Admin and Staff accounts.');
      
      // Staff ko staff table mein bhi register karna
      const [insertedStaff] = await pool.query('SELECT id FROM users WHERE email = "staff@sarte.com" LIMIT 1');
      if (insertedStaff.length > 0) {
        await pool.query(
          'INSERT INTO staff (user_id, department, permissions) VALUES (?, ?, ?)',
          [insertedStaff[0].id, 'Reception', 'read:bookings,write:bookings']
        );
      }
    }

    // 14. Agar rooms table khali hai to default rooms ko categories, amenities, aur image paths ke sath seed karna
    const [existingRooms] = await pool.query('SELECT * FROM rooms LIMIT 1');
    if (existingRooms.length === 0) {
      const defaultRooms = [
        [
          'The Monarch Executive Suite', 
          'suite', 
          380.00, 
          'available', 
          'SARTE\'s ultimate masterpiece. The Monarch Executive Suite offers a breathtaking lakeside panorama, equipped with customized premium wood furniture, full OLED lighting automation, a private jacuzzi, and round-the-clock professional butler service.',
          'uploads/monarch_suite.jpg',
          JSON.stringify(['Jacuzzi', 'OLED Lighting', 'Butler Service', 'Lakeside View', 'Mini Bar'])
        ],
        [
          'Sanctuary Grand Family Suite', 
          'family', 
          280.00, 
          'available', 
          'Crafted specifically for families and group travelers, the Sanctuary Grand Family Suite includes two queen-size beds, an elegant private lounge partition, a mini kitchenette, and child-safe automation setups.',
          'uploads/family_suite.jpg',
          JSON.stringify(['Kitchenette', 'Two Queen Beds', 'Lounge Partition', 'Wi-Fi', 'Smart TV'])
        ],
        [
          'The Imperial Deluxe Room', 
          'deluxe', 
          195.00, 
          'available', 
          'A flawless combination of luxury and function. Designed for business executives and distinguished travelers, the Imperial Deluxe Room features an ergonomic workspace with high-speed internet ports, an imported Italian espresso capsule machine, and a gorgeous glass-partition rain shower.',
          'uploads/imperial_deluxe.jpg',
          JSON.stringify(['Rain Shower', 'Espresso Machine', 'Ergonomic Workspace', 'High-speed Internet'])
        ],
        [
          'Aura Premium Double Room', 
          'double', 
          140.00, 
          'available', 
          'Comfort meets value in the Aura Premium Double. With dual luxury double beds, a beautifully aligned garden view, and premium glass acoustics, this room is the ideal sanctuary for couples and travel companions seeking a refined retreat.',
          'uploads/aura_double.jpg',
          JSON.stringify(['Double Bed', 'Garden View', 'Acoustic Insulation', 'Wi-Fi'])
        ],
        [
          'Solitude Classic Single Room', 
          'single', 
          90.00, 
          'available', 
          'Specifically designed for solo travelers and business professionals seeking focus and tranquility. The Solitude Single Room offers a quiet, acoustically insulated environment equipped with a curated bookshelf, ergonomic seating, and lightning-fast fiber-optic internet connection.',
          'uploads/solitude_single.jpg',
          JSON.stringify(['Single Bed', 'Acoustic Insulation', 'Bookshelf', 'Ergonomic Seating', 'Fiber Internet'])
        ]
      ];

      for (const room of defaultRooms) {
        await pool.query(
          'INSERT INTO rooms (room_name, room_type, room_price, room_status, room_description, image_url, amenities) VALUES (?, ?, ?, ?, ?, ?, ?)',
          room
        );
      }
      console.log('Seeded 5 default hotel rooms with categories and amenities.');
    }

    console.log('Successfully initialized database and seeded tables.');
  } catch (err) {
    console.error('Database setup failed:', err.message);
  }
}

// Initialization ko call karna
initializeDatabase();

module.exports = pool;
