const express = require('express');
const taskController = require('../controllers/task.controller');
const authMiddleware = require('../middleware/auth.middleware'); // Middleware xác thực
const router = express.Router();



// Tất cả các route liên quan đến công việc đều cần xác thực
router.use(authMiddleware.authenticate);

// Route để lấy tất cả công việc (có thể có phân trang, lọc)
router.get('/', taskController.getAllTasks);

// Route để lấy một công việc theo ID
router.get('/:id', taskController.getTaskById);

// Route để tạo một công việc mới
router.post('/', taskController.createTask);

// Route để cập nhật một công việc theo ID
router.put('/:id', taskController.updateTask);

// Route để xóa một công việc theo ID
router.delete('/:id', taskController.deleteTask);

// Route để cập nhật trạng thái của một công việc
router.patch('/:id/status', taskController.updateTaskStatus);



module.exports = router;