const express = require('express');
const router = express.Router();
const { getAuditLogs } = require('../controllers/auditLogController');
const { protect, restrictTo } = require('../middleware/authMiddleware');

router.route('/')
  .get(protect, restrictTo('admin'), getAuditLogs);

module.exports = router;
