const User = require('../models/user.model');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

// Hàm tạo tài khoản admin ban đầu (chạy một lần khi server khởi động)
exports.createAdmin = async () => {
  try {
      const adminExists = await User.findOne({ isAdmin: true });
      if (!adminExists) {
          const adminUser = new User({
              id: uuidv4(),
              username: process.env.ADMIN_USERNAME || 'adminduy',
              email: process.env.ADMIN_EMAIL || 'adminduy@gmail.com',
              password: process.env.ADMIN_PASSWORD || 'Pkd1203@',
              isAdmin: true,
          });

          

          await adminUser.save();
          console.log('Tài khoản admin ban đầu đã được tạo.');
      } else {
          console.log('Tài khoản admin đã tồn tại.');
      }
  } catch (error) {
      console.error('Lỗi khi tạo tài khoản admin ban đầu:', error);
  }
};

// Hàm đăng ký người dùng mới
exports.register = async (req, res) => {
  const { username, email, password } = req.body;

  try {
    // Kiểm tra xem người dùng đã tồn tại chưa
    const existingUser = await User.findOne({ $or: [{ username }, { email }] });
    if (existingUser) {
      return res.status(409).json({ message: 'Tên đăng nhập hoặc email đã tồn tại.' });
    }

    const newUser = new User({
      id: uuidv4(),
      username,
      email,
      password,
    });

    await newUser.save();
    res.status(201).json({ message: 'Người dùng đã được đăng ký thành công.' });
  } catch (error) {
    res.status(500).json({ message: 'Đã có lỗi xảy ra khi đăng ký người dùng.', error: error.message });
  }
};

// Hàm đăng nhập người dùng
exports.login = async (req, res) => {
  const { username, password } = req.body;
  console.log('Đang cố gắng đăng nhập với username:', username);
  console.log('Mật khẩu nhận được từ client:', password); // Thêm dòng này

  try {
    const user = await User.findOne({ username });
    console.log('Người dùng tìm thấy:', user);

    if (!user) {
      console.log('Không tìm thấy người dùng.');
      return res.status(401).json({ message: 'Tên đăng nhập hoặc mật khẩu không đúng.' });
    }
    console.log('Mật khẩu nhận được từ client (trước compare):', password);
    console.log('Mật khẩu hash từ database (trước compare):', user.password);

    const isPasswordValid = await user.comparePassword(password);
    console.log('Mật khẩu hợp lệ:', isPasswordValid);

    if (!isPasswordValid) {
      console.log('Mật khẩu không đúng.');
      return res.status(401).json({ message: 'Tên đăng nhập hoặc mật khẩu không đúng.' });
    }

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.status(200).json({ message: 'Đăng nhập thành công.', token, userId: user.id, isAdmin: user.isAdmin });
  } catch (error) {
    console.error('Lỗi khi đăng nhập:', error);
    res.status(500).json({ message: 'Đã có lỗi xảy ra khi đăng nhập.', error: error.message });
  }
};
exports.getAllUsers = async (req, res) => {
  try {
      const users = await User.find({}, '-password'); // không trả về mật khẩu
      res.status(200).json(users);
  } catch (error) {
      res.status(500).json({ message: 'Lỗi khi lấy danh sách người dùng', error: error.message });
  }
};
