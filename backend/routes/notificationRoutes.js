const express = require('express');
const router = express.Router();
const {
  getMyNotifications,
  markNotificationRead,
  markAllNotificationsRead,
  deleteNotification
} = require('../controllers/notificationController');
const { protect } = require('../middleware/authMiddleware');

router.route('/')
  .get(protect, getMyNotifications);

router.route('/read-all')
  .put(protect, markAllNotificationsRead);

router.route('/:id/read')
  .put(protect, markNotificationRead);

router.route('/:id')
  .delete(protect, deleteNotification);

module.exports = router;
