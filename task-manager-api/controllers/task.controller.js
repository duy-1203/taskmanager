const Task = require('../models/task.model');
const { v4: uuidv4 } = require('uuid');

// Lấy tất cả công việc (chỉ cho người dùng hiện tại)
exports.getAllTasks = async (req, res) => {
  try {
    const userId = req.userId;
    console.log('getAllTasks - req.userId:', userId); // Thêm dòng này
    const isAdmin = req.user ? req.user.isAdmin : false;

    let query = {};
    if (!isAdmin) {
      query = {
        $or: [
          { assignedTo: userId },
          { createdBy: userId }
        ]
      };
    }
    console.log('getAllTasks - query:', query); // Thêm dòng này

    const tasks = await Task.find(query)
      .populate('createdBy', 'username email')
      .populate('assignedTo', 'username email')
      .populate('comments.createdBy', 'username email');

    res.json(tasks);
  } catch (error) {
    console.error('Lỗi khi lấy danh sách task:', error);
    res.status(500).json({ message: 'Đã xảy ra lỗi khi lấy danh sách công việc.' });
  }
};

// Lấy một công việc theo ID (sửa đổi để tìm theo trường 'id' - UUID)
exports.getTaskById = async (req, res) => {
  try {
    const task = await Task.findOne({ id: req.params.id })
      .populate('createdBy', 'username email')
      .populate('assignedTo', 'username email')
      .populate('comments.createdBy', 'username email');
    if (!task) {
      return res.status(404).json({ message: 'Không tìm thấy công việc.' });
    }
    res.status(200).json(task);
  } catch (error) {
    console.error('Lỗi khi lấy công việc theo ID:', error);
    res.status(500).json({ message: 'Không thể lấy công việc.', error: error.message });
  }
};

// Tạo một công việc mới
exports.createTask = async (req, res) => {
  const { title, description, status, priority, dueDate, assignedTo } = req.body;
  const createdBy = req.userId; // Lấy ID người dùng từ middleware xác thực

  try {
    const newTask = new Task({
      id: uuidv4(),
      title: req.body.title,
      description: req.body.description,
      createdBy: req.userId,
      status,
      priority,
      dueDate,
      assignedTo,
    });
    const savedTask = await newTask.save();
    res.status(201).json(savedTask);
  } catch (error) {
    console.error('Lỗi khi tạo công việc:', error);
    res.status(500).json({ message: 'Không thể tạo công việc.', error: error.message });
  }
};

// Cập nhật một công việc theo ID (sửa đổi để tìm và cập nhật theo trường 'id' - UUID)
exports.updateTask = async (req, res) => {
  try {
    const task = await Task.findOneAndUpdate({ id: req.params.id }, req.body, { new: true })
      .populate('createdBy', 'username email')
      .populate('assignedTo', 'username email')
      .populate('comments.createdBy', 'username email');
    if (!task) {
      return res.status(404).json({ message: 'Không tìm thấy công việc.' });
    }
    res.status(200).json(task);
  } catch (error) {
    console.error('Lỗi khi cập nhật công việc:', error);
    res.status(500).json({ message: 'Không thể cập nhật công việc.', error: error.message });
  }
};

// Xóa một công việc theo ID (sửa đổi để tìm và xóa theo trường 'id' - UUID)
exports.deleteTask = async (req, res) => {
  try {
    const task = await Task.findOneAndDelete({ id: req.params.id });
    if (!task) {
      return res.status(404).json({ message: 'Không tìm thấy công việc.' });
    }
    res.status(200).json({ message: 'Công việc đã được xóa thành công.' });
  } catch (error) {
    console.error('Lỗi khi xóa công việc:', error);
    res.status(500).json({ message: 'Không thể xóa công việc.', error: error.message });
  }
};

// Cập nhật trạng thái của một công việc (sửa đổi để tìm và cập nhật theo trường 'id' - UUID)
exports.updateTaskStatus = async (req, res) => {
  try {
    const task = await Task.findOneAndUpdate(
      { id: req.params.id },
      { status: req.body.status, updatedAt: Date.now() },
      { new: true }
    )
      .populate('createdBy', 'username email')
      .populate('assignedTo', 'username email')
      .populate('comments.createdBy', 'username email');

    if (!task) {
      return res.status(404).json({ message: 'Không tìm thấy công việc.' });
    }
    res.status(200).json(task);
  } catch (error) {
    console.error('Lỗi khi cập nhật trạng thái công việc:', error);
    res.status(500).json({ message: 'Không thể cập nhật trạng thái công việc.', error: error.message });
  }
};

