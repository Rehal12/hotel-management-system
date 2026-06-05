const express = require('express');
const router = express.Router();
const { getDashboardMetrics } = require('../controllers/analyticsController');
const { protect, restrictTo } = require('../middleware/authMiddleware');

router.route('/')
  .get(protect, restrictTo('admin', 'staff'), getDashboardMetrics);

module.exports = router;
