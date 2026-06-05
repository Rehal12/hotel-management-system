const AuditLog = require('../models/auditLogModel');

// @desc    Sab audit logs lana (sirf Admin ke liye)
// @route   GET /api/audit-logs
const getAuditLogs = async (req, res, next) => {
  try {
    const logs = await AuditLog.findAll();
    res.status(200).json({ success: true, count: logs.length, data: logs });
  } catch (error) {
    next(error);
  }
};

module.exports = { getAuditLogs };
