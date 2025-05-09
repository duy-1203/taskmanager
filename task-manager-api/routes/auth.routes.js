const express = require('express');
const authController = require('../controllers/auth.controller');
const authMiddleware = require('../middleware/auth.middleware'); // Import module

const router = express.Router();

router.post('/register', authController.register);
router.post('/login', authController.login);

// Sử dụng middleware thông qua object đã import
router.get('/', authMiddleware.authenticate, authController.getAllUsers);


module.exports = router;