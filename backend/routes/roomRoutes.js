const express = require('express');
const router = express.Router();
const { 
  getRooms, 
  createRoom, 
  updateRoom, 
  deleteRoom 
} = require('../controllers/roomController');
const { protect, restrictTo } = require('../middleware/authMiddleware');

// /api/rooms
router.route('/')
  .get(getRooms) // Koi bhi (guests samet) rooms search ya dekh sakta hai
  .post(protect, restrictTo('admin', 'staff'), createRoom); // Sirf admin/staff hi rooms add kar sakte hain

// /api/rooms/:id
router.route('/:id')
  .put(protect, restrictTo('admin', 'staff'), updateRoom) // Sirf admin/staff hi update kar sakte hain
  .delete(protect, restrictTo('admin'), deleteRoom); // Sirf admin hi delete kar sakta hai

module.exports = router;
