const jwt = require('jsonwebtoken');

// Routes ko mehfooz karne aur JWT tokens verify karne ka middleware
const protect = async (req, res, next) => {
  let token;

  // Check karna ke token Authorization header mein hai ya nahi
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      // Header se token nikalna
      token = req.headers.authorization.split(' ')[1];

      // Token verify karna
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'sartesecretkey');

      // User payload ko request object mein set karna
      req.user = decoded;
      next();
    } catch (error) {
      console.error('JWT Verification Error:', error.message);
      res.status(401);
      return next(new Error('Not authorized, token failed'));
    }
  }

  if (!token) {
    res.status(401);
    return next(new Error('Not authorized, no token provided'));
  }
};

// Specific roles (jaise admin, staff) ke liye routes ko mehdood karne ka middleware
const restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      res.status(403);
      return next(new Error('Forbidden: You do not have permission to perform this action'));
    }
    next();
  };
};

module.exports = { protect, restrictTo };
