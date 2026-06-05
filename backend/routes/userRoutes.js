const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const { 
  getUsers, 
  createUser, 
  loginUser,
  getUserProfile,
  updateUser,
  deleteUser,
  createStaffUser,
  getStaffUsers,
  forgotPassword,
  resetPassword,
  refreshAccessToken
} = require('../controllers/userController');
const { protect, restrictTo } = require('../middleware/authMiddleware');

// Validation mein madad karne wala middleware
const validateInputs = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(400);
    return next(new Error(errors.array().map(err => err.msg).join(', ')));
  }
  next();
};

// Validations ki list
const registerValidation = [
  body('full_name').trim().notEmpty().withMessage('Full name is required'),
  body('email').isEmail().withMessage('Please enter a valid email address'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),
  validateInputs
];

const loginValidation = [
  body('email').isEmail().withMessage('Please enter a valid email address'),
  body('password').notEmpty().withMessage('Password is required'),
  validateInputs
];

const forgotPasswordValidation = [
  body('email').isEmail().withMessage('Please enter a valid email address'),
  validateInputs
];

const resetPasswordValidation = [
  body('email').isEmail().withMessage('Please enter a valid email address'),
  body('otp').isLength({ min: 6, max: 6 }).withMessage('OTP must be exactly 6 digits'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),
  validateInputs
];

// Public endpoints
router.post('/', registerValidation, createUser); // Registration karna
router.post('/login', loginValidation, loginUser); // Login karna
router.post('/forgot-password', forgotPasswordValidation, forgotPassword); // Password bhool jane par
router.post('/reset-password', resetPasswordValidation, resetPassword); // Password naya lagana
router.post('/refresh-token', refreshAccessToken); // Refresh Token ka badalna

// Protected profile ka endpoint
router.get('/profile', protect, getUserProfile);

// Sirf Admin ke liye staff management ke endpoints
router.route('/staff')
  .get(protect, restrictTo('admin'), getStaffUsers) // Admin ka sab staff ko lana
  .post(protect, restrictTo('admin'), createStaffUser); // Admin ka naya staff account banana

// Sirf Admin ke endpoints ya mehfooz aam CRUD
router.route('/')
  .get(protect, restrictTo('admin'), getUsers); // Admin ka sab users ko lana

router.route('/:id')
  .put(protect, updateUser) // User profile update karna
  .delete(protect, restrictTo('admin'), deleteUser); // Admin ka user delete karna

module.exports = router;
