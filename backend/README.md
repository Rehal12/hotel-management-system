# SARTE App Backend

This is the backend implementation for the SARTE App. It is a simple REST API built using Node.js, Express.js, and MySQL, with completely separate code from the Flutter frontend.

## 🛠 Required npm packages

The project uses the following packages (defined in `package.json`):
* `express` - Web framework for routing and middleware.
* `mysql2` - MySQL client (used with promises to avoid callback hell).
* `bcrypt` - Library for hashing passwords securely.
* `dotenv` - Module to load environment variables from a `.env` file.
* `cors` - Middleware to enable Cross-Origin Resource Sharing.
* `nodemon` (dev) - Automatically restarts the server during development.

## ⚙️ Installation Steps

1. **Navigate to the backend folder**:
   ```bash
   cd backend
   ```
2. **Install dependencies**:
   ```bash
   npm install
   ```
3. **Set up MySQL Database**:
   * Open XAMPP / MySQL Workbench / phpMyAdmin.
   * Run the SQL queries provided in `sarte_db_schema.sql` to create the database and tables.
4. **Configure Environment Variables**:
   * Ensure the `.env` file is present in the `backend/` folder with your MySQL database credentials (default is user `root` with no password).
5. **Run the server**:
   ```bash
   npm run dev
   ```
   *(Or `npm start` for production)*

---

## 💾 Complete MySQL Database Schema

The database relies on two tables: `users` and `rooms`.

### CREATE TABLE queries

```sql
CREATE DATABASE IF NOT EXISTS sarte_app_db;
USE sarte_app_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_name VARCHAR(100) NOT NULL,
    room_type VARCHAR(50) NOT NULL,
    room_price DECIMAL(10, 2) NOT NULL,
    room_status ENUM('available', 'booked', 'maintenance') DEFAULT 'available',
    room_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 📌 API Endpoint List

### User CRUD
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/users` | Get all users |
| `POST` | `/api/users` | Create a new user |
| `PUT` | `/api/users/:id` | Update an existing user |
| `DELETE` | `/api/users/:id` | Delete a user |

### Room CRUD
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/rooms` | Get all rooms |
| `POST` | `/api/rooms` | Add a new room |
| `PUT` | `/api/rooms/:id` | Update an existing room |
| `DELETE` | `/api/rooms/:id` | Delete a room |

---

## ✉️ Postman Testing Examples & Request/Response JSON

### 1. Create a User (POST `/api/users`)
**Request Body (JSON):**
```json
{
  "full_name": "John Doe",
  "email": "johndoe@example.com",
  "password": "secretpassword",
  "role": "user"
}
```
**Response (201 Created):**
```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "id": 1,
    "full_name": "John Doe",
    "email": "johndoe@example.com",
    "role": "user"
  }
}
```

### 2. Get All Users (GET `/api/users`)
**Response (200 OK):**
```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "id": 1,
      "full_name": "John Doe",
      "email": "johndoe@example.com",
      "role": "user"
    }
  ]
}
```

### 3. Update a User (PUT `/api/users/1`)
**Request Body (JSON):**
```json
{
  "full_name": "John Doe Updated",
  "role": "admin"
}
```
**Response (200 OK):**
```json
{
  "success": true,
  "message": "User updated successfully"
}
```

### 4. Delete a User (DELETE `/api/users/1`)
**Response (200 OK):**
```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

### 5. Add a Room (POST `/api/rooms`)
**Request Body (JSON):**
```json
{
  "room_name": "Deluxe Suite 101",
  "room_type": "Deluxe",
  "room_price": 150.00,
  "room_status": "available",
  "room_description": "A beautiful suite with sea view."
}
```
**Response (201 Created):**
```json
{
  "success": true,
  "message": "Room added successfully",
  "data": {
    "room_id": 1,
    "room_name": "Deluxe Suite 101",
    "room_type": "Deluxe",
    "room_price": 150.00,
    "room_status": "available"
  }
}
```

### 6. Get All Rooms (GET `/api/rooms`)
**Response (200 OK):**
```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "room_id": 1,
      "room_name": "Deluxe Suite 101",
      "room_type": "Deluxe",
      "room_price": "150.00",
      "room_status": "available",
      "room_description": "A beautiful suite with sea view.",
      "created_at": "2023-10-15T12:00:00.000Z"
    }
  ]
}
```
