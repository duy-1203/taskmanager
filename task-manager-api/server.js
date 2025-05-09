const express = require('express');
const connectDB = require('./config/database.config');
const cors = require('cors');
const authController = require('./controllers/auth.controller'); // Import controller

const app = express();
const port = process.env.PORT || 3000;

require('dotenv').config();

// Cấu hình CORS để chấp nhận các yêu cầu từ frontend
const corsOptions = {
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'], // Đã thêm 'PATCH' vào đây
  allowedHeaders: ['Content-Type', 'Authorization'],
};

connectDB()
  .then(() => {
    console.log('MongoDB connected!');
    console.log('Đang cố gắng tạo tài khoản admin...');
    return authController.createAdmin(); // Gọi createAdmin sau khi DB kết nối thành công
  })
  .then(() => {
    console.log('Hoàn thành việc tạo tài khoản admin (nếu cần).');

    // Sử dụng CORS với cấu hình đã cập nhật
    app.use(cors(corsOptions));

    app.use(express.json());
    const authRoutes = require('./routes/auth.routes');
    app.use('/api/users', authRoutes);

    const taskRoutes = require('./routes/task.routes');
    app.use('/api/tasks', taskRoutes);

    app.get('/', (req, res) => {
      res.send('Task Manager Backend is running!');
    });

    app.listen(port, () => {
      console.log(`Server listening at http://localhost:${port}`);
    });
  })
  .catch((err) => {
    console.error('Failed to connect to MongoDB:', err);
    process.exit(1); // Thoát nếu không kết nối được DB
  });