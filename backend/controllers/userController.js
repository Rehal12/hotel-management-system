const User = require('../models/userModel');
const RefreshToken = require('../models/refreshTokenModel');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// JWT token banane ke madadgar functions
const generateToken = (id, email, role) => {
  return jwt.sign(
    { id, email, role },
    process.env.JWT_SECRET || 'sartesecretkey',
    { expiresIn: '30d' }
  );
};

const generateAccessToken = (id, email, role) => {
  return jwt.sign(
    { id, email, role },
    process.env.JWT_SECRET || 'sartesecretkey',
    { expiresIn: '1h' }
  );
};

const generateRefreshToken = (id, email, role) => {
  return jwt.sign(
    { id, email, role },
    process.env.JWT_REFRESH_SECRET || 'sarterefreshsecretkey',
    { expiresIn: '30d' }
  );
};

// @desc    Sab users ko lana (sirf Admin ke liye)
// @route   GET /api/users
const getUsers = async (req, res, next) => {
  try {
    const users = await User.findAll();
    res.status(200).json({ success: true, count: users.length, data: users });
  } catch (error) {
    next(error);
  }
};

// @desc    Naya user banana/register karna (Customer signup)
// @route   POST /api/users
const createUser = async (req, res, next) => {
  try {
    const { full_name, email, password, phone } = req.body;

    // Inputs ki tasdeeq karna
    if (!full_name || !email || !password) {
      res.status(400);
      throw new Error('Please provide full_name, email, and password');
    }

    // Check karna ke user pehle se mojood hai ya nahi
    const userExists = await User.findByEmail(email);
    if (userExists) {
      res.status(400);
      throw new Error('User already exists with this email');
    }

    // Security ke liye bcrypt se password hash karna
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Database mein user banana. Public registration HAMESHA 'user' role hogi security ke liye
    const assignedRole = 'user';
    const userId = await User.create({
      full_name,
      email,
      password: hashedPassword,
      phone: phone || null,
      role: assignedRole
    });

    // Access aur refresh tokens generate karna
    const token = generateAccessToken(userId, email, assignedRole);
    const refreshToken = generateRefreshToken(userId, email, assignedRole);

    // Refresh token ko DB mein save karna
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 din
    await RefreshToken.create(userId, refreshToken, expiresAt);

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      token,
      refresh_token: refreshToken,
      data: { id: userId, full_name, email, phone: phone || null, role: assignedRole }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    User login karna aur token hasil karna
// @route   POST /api/users/login
const loginUser = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Inputs ki tasdeeq karna
    if (!email || !password) {
      res.status(400);
      throw new Error('Please provide email and password');
    }

    // Check karna ke user DB mein mojood hai ya nahi
    const user = await User.findByEmail(email);
    if (!user) {
      res.status(401);
      throw new Error('Invalid email or password');
    }

    // Lockout ki haalat check karna
    if (user.lock_until && new Date(user.lock_until) > new Date()) {
      res.status(403);
      const remainingMin = Math.ceil((new Date(user.lock_until) - new Date()) / (60 * 1000));
      throw new Error(`Account locked due to consecutive failed attempts. Try again in ${remainingMin} minutes.`);
    }

    // Encrypted passwords ka muqaabla karna
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      const attempts = (user.failed_login_attempts || 0) + 1;
      if (attempts >= 5) {
        const lockUntil = new Date(Date.now() + 15 * 60 * 1000); // 15 minute ka lock
        await User.lockAccount(user.id, lockUntil);
        await User.updateFailedAttempts(user.id, attempts);
        res.status(403);
        throw new Error('Account locked due to 5 consecutive failed login attempts. Try again in 15 minutes.');
      } else {
        await User.updateFailedAttempts(user.id, attempts);
        res.status(401);
        throw new Error(`Invalid email or password. Attempt ${attempts} of 5.`);
      }
    }

    // Kaamyaab login par koshishein reset karna
    await User.resetFailedAttempts(user.id);

    // Tokens generate karna
    const token = generateAccessToken(user.id, user.email, user.role);
    const refreshToken = generateRefreshToken(user.id, user.email, user.role);

    // Puraane tokens saaf karna aur naya store karna
    await RefreshToken.deleteByUserId(user.id);
    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    await RefreshToken.create(user.id, refreshToken, expiresAt);

    res.status(200).json({
      success: true,
      message: 'Logged in successfully',
      token,
      refresh_token: refreshToken,
      data: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        phone: user.phone,
        role: user.role
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Maujooda user ki profile ki tafseel lana
// @route   GET /api/users/profile
const getUserProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      res.status(404);
      throw new Error('User profile not found');
    }

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    next(error);
  }
};

// @desc    User ki profile ki tafseel update karna
// @route   PUT /api/users/:id
const updateUser = async (req, res, next) => {
  try {
    const { full_name, email, phone, role } = req.body;
    const userId = req.params.id;

    // Check karna ke user mojood hai ya nahi
    const user = await User.findById(userId);
    if (!user) {
      res.status(404);
      throw new Error('User not found');
    }

    // User ki fields update karna
    await User.update(userId, {
      full_name: full_name || user.full_name,
      email: email || user.email,
      phone: phone || user.phone,
      role: role || user.role
    });

    res.status(200).json({
      success: true,
      message: 'User updated successfully'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    User ko delete karna
// @route   DELETE /api/users/:id
const deleteUser = async (req, res, next) => {
  try {
    const userId = req.params.id;

    // Check karna ke user mojood hai ya nahi
    const user = await User.findById(userId);
    if (!user) {
      res.status(404);
      throw new Error('User not found');
    }

    // User ko delete karna
    await User.delete(userId);

    res.status(200).json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Admin: Staff ka account banana
// @route   POST /api/users/staff
const createStaffUser = async (req, res, next) => {
  try {
    const { full_name, email, password, phone, role } = req.body;

    // Inputs ki tasdeeq karna
    if (!full_name || !email || !password) {
      res.status(400);
      throw new Error('Please provide full_name, email, and password');
    }

    // Sirf 'staff' ya 'admin' roles ki ijazat dena
    const allowedRoles = ['staff', 'admin'];
    const assignedRole = allowedRoles.includes(role) ? role : 'staff';

    // Check karna ke user pehle se mojood hai ya nahi
    const userExists = await User.findByEmail(email);
    if (userExists) {
      res.status(400);
      throw new Error('User already exists with this email');
    }

    // Password hash karna
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const userId = await User.create({
      full_name,
      email,
      password: hashedPassword,
      phone: phone || null,
      role: assignedRole
    });

    res.status(201).json({
      success: true,
      message: `${assignedRole.charAt(0).toUpperCase() + assignedRole.slice(1)} account created successfully`,
      data: { id: userId, full_name, email, phone: phone || null, role: assignedRole }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Admin: Sab staff aur admin users ko lana
// @route   GET /api/users/staff
const getStaffUsers = async (req, res, next) => {
  try {
    const staffUsers = await User.findAllStaff();
    res.status(200).json({ success: true, count: staffUsers.length, data: staffUsers });
  } catch (error) {
    next(error);
  }
};

// @desc    Password bhool gaye - Demo OTP bhejna
// @route   POST /api/users/forgot-password
const forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;
    if (!email) {
      res.status(400);
      throw new Error('Please provide email address');
    }

    const user = await User.findByEmail(email);
    if (!user) {
      res.status(404);
      throw new Error('No user found with this email');
    }

    // 6-digit OTP code generate karna
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minute mein expire hoga

    await User.updateOTP(email, otp, expiry);

    res.status(200).json({
      success: true,
      message: 'Password reset OTP generated successfully (Demo Mode)',
      otp, // Testing ki aasani ke liye OTP bhej rahe hain
      email
    });
  } catch (error) {
    next(error);
  }
};

// @desc    OTP istemal karke password reset karna
// @route   POST /api/users/reset-password
const resetPassword = async (req, res, next) => {
  try {
    const { email, otp, password } = req.body;
    if (!email || !otp || !password) {
      res.status(400);
      throw new Error('Please provide email, OTP, and new password');
    }

    const user = await User.findByEmail(email);
    if (!user) {
      res.status(404);
      throw new Error('User not found');
    }

    // OTP aur expiry ki tasdeeq karna
    if (!user.reset_otp || user.reset_otp !== otp) {
      res.status(400);
      throw new Error('Invalid OTP code');
    }

    if (new Date(user.reset_otp_expiry) < new Date()) {
      res.status(400);
      throw new Error('OTP has expired');
    }

    // Naya password hash karna
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // DB mein password update karna
    await User.updatePassword(email, hashedPassword);

    res.status(200).json({
      success: true,
      message: 'Password reset successfully'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    JWT Token refresh karna
// @route   POST /api/users/refresh-token
const refreshAccessToken = async (req, res, next) => {
  try {
    const { refresh_token } = req.body;
    if (!refresh_token) {
      res.status(400);
      throw new Error('Refresh token is required');
    }

    const tokenRecord = await RefreshToken.findByToken(refresh_token);
    if (!tokenRecord) {
      res.status(401);
      throw new Error('Invalid refresh token');
    }

    if (new Date(tokenRecord.expires_at) < new Date()) {
      await RefreshToken.deleteByToken(refresh_token);
      res.status(401);
      throw new Error('Refresh token has expired. Please log in again.');
    }

    // Token ki signature verify karna
    const decoded = jwt.verify(refresh_token, process.env.JWT_REFRESH_SECRET || 'sarterefreshsecretkey');

    // Naye tokens generate karna (token rotation)
    const newAccessToken = generateAccessToken(decoded.id, decoded.email, decoded.role);
    const newRefreshToken = generateRefreshToken(decoded.id, decoded.email, decoded.role);

    // Purana refresh token record delete karna aur naya banana
    await RefreshToken.deleteByToken(refresh_token);
    const expiry = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
    await RefreshToken.create(decoded.id, newRefreshToken, expiry);

    res.status(200).json({
      success: true,
      token: newAccessToken,
      refresh_token: newRefreshToken
    });
  } catch (error) {
    res.status(401);
    next(error);
  }
};

module.exports = {
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
};
