const Notification = require('../models/notificationModel');

// @desc    User ki notifications lana
// @route   GET /api/notifications
const getMyNotifications = async (req, res, next) => {
  try {
    const notifications = await Notification.findByUserId(req.user.id);
    res.status(200).json({ success: true, count: notifications.length, data: notifications });
  } catch (error) {
    next(error);
  }
};

// @desc    Notification ko read mark karna
// @route   PUT /api/notifications/:id/read
const markNotificationRead = async (req, res, next) => {
  try {
    const notificationId = req.params.id;
    await Notification.markAsRead(notificationId, req.user.id);
    res.status(200).json({ success: true, message: 'Notification marked as read' });
  } catch (error) {
    next(error);
  }
};

// @desc    Sab notifications ko read mark karna
// @route   PUT /api/notifications/read-all
const markAllNotificationsRead = async (req, res, next) => {
  try {
    await Notification.markAllAsRead(req.user.id);
    res.status(200).json({ success: true, message: 'All notifications marked as read' });
  } catch (error) {
    next(error);
  }
};

// @desc    Notification ko delete karna
// @route   DELETE /api/notifications/:id
const deleteNotification = async (req, res, next) => {
  try {
    const notificationId = req.params.id;
    await Notification.delete(notificationId, req.user.id);
    res.status(200).json({ success: true, message: 'Notification deleted successfully' });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getMyNotifications,
  markNotificationRead,
  markAllNotificationsRead,
  deleteNotification
};
