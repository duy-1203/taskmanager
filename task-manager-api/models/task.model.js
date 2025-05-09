const mongoose = require('mongoose');

const CommentSchema = new mongoose.Schema({
  content: { type: String, required: true },
  createdBy: { type: String, required: true }, // Đã sửa lại thành String
  createdAt: { type: Date, default: Date.now },
});

const TaskSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  status: { type: String, default: 'Mới' },
  priority: { type: Number, default: 1 },
  dueDate: { type: Date },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
  createdBy: { type: String, required: true }, // Đã sửa lại thành String
  assignedTo: { type: String }, // Đã sửa lại thành String
  category: { type: String },
  attachments: [{ type: String }],
  comments: [CommentSchema],
});

const Task = mongoose.model('Task', TaskSchema);

module.exports = Task;