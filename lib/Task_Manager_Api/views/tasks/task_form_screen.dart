import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/task_view_model.dart';
import '../../models/task.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../view_models/auth_view_model.dart';
import '../../models/user.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? initialTask;

  const TaskFormScreen({Key? key, this.initialTask}) : super(key: key);

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _status;
  int? _priority;
  DateTime? _dueDate;
  String? _selectedAssigneeId; // Thêm biến để theo dõi người được giao
  TextEditingController _dueDateController = TextEditingController(); // Controller cho trường hiển thị ngày

  @override
  void initState() {
    super.initState();
    if (widget.initialTask != null) {
      _titleController.text = widget.initialTask!.title;
      _descriptionController.text = widget.initialTask!.description;
      _status = widget.initialTask!.status;
      _priority = widget.initialTask!.priority;
      _dueDate = widget.initialTask!.dueDate;
      _selectedAssigneeId = widget.initialTask!.assignedTo;
      _dueDateController.text = widget.initialTask!.dueDate != null ? DateFormat('dd/MM/yyyy').format(widget.initialTask!.dueDate!) : '';
    } else {
      _dueDateController.text = ''; // Khởi tạo controller cho trường ngày mới
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
        _dueDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskViewModel = Provider.of<TaskViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isAdmin = authViewModel.isAdmin();

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text('Không được phép')),
        body: Center(
          child: Text('Bạn không có quyền tạo hoặc chỉnh sửa công việc.', style: TextStyle(fontSize: 18.0)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.initialTask == null ? 'Thêm Công Việc' : 'Sửa Công Việc')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Tiêu đề công việc
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              SizedBox(height: 16.0),

              // Mô tả công việc
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập mô tả' : null,
              ),
              SizedBox(height: 16.0),

              // Trạng thái công việc
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Trạng thái', border: OutlineInputBorder()),
                value: _status,
                items: <String>['Mới', 'Đang làm', 'Hoàn thành', 'Đã hủy']
                    .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
              ),
              SizedBox(height: 16.0),

              // Độ ưu tiên công việc
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Độ ưu tiên', border: OutlineInputBorder()),
                value: _priority,
                items: <int>[1, 2, 3]
                    .map((int value) => DropdownMenuItem<int>(
                  value: value,
                  child: Text('Ưu tiên $value'),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _priority = value;
                  });
                },
              ),
              SizedBox(height: 16.0),

              // Chọn ngày hoàn thành
              InkWell(
                onTap: () => _selectDueDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hạn hoàn thành',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today), // Thêm icon lịch
                  ),
                  child: Text(_dueDateController.text.isEmpty ? 'Chọn ngày' : _dueDateController.text),
                ),
              ),
              SizedBox(height: 16.0),

              // Giao công việc cho người khác
              FutureBuilder<List<User>>(
                future: authViewModel.fetchUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Lỗi tải danh sách người dùng: ${snapshot.error}', style: TextStyle(color: Colors.red));
                  } else if (snapshot.hasData) {
                    final users = snapshot.data!.where((user) => !user.isAdmin).toList();
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Giao cho (tùy chọn)', border: OutlineInputBorder()),
                      value: _selectedAssigneeId,
                      items: users.map((user) => DropdownMenuItem<String>(
                        value: user.id,
                        child: Text(user.username),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAssigneeId = value;
                        });
                      },
                    );
                  } else {
                    return Text('Không có dữ liệu người dùng.');
                  }
                },
              ),
              SizedBox(height: 24.0),

              // Nút lưu công việc
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                    final userId = authViewModel.loggedInUser?.id ?? 'unknown';
                    final newTask = Task(
                      id: widget.initialTask?.id ?? Uuid().v4(),
                      title: _titleController.text,
                      description: _descriptionController.text,
                      status: _status ?? 'Mới',
                      priority: _priority ?? 1,
                      dueDate: _dueDate,
                      createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      createdBy: widget.initialTask?.createdBy ?? userId,
                      assignedTo: _selectedAssigneeId,
                    );

                    print('TaskFormScreen - ID người dùng hiện tại (loggedInUser?.id): $userId'); // LOG
                    print('TaskFormScreen - ID người được giao (_selectedAssigneeId): $_selectedAssigneeId'); // LOG
                    print('TaskFormScreen - Dữ liệu công việc gửi đi (newTask.toJson()): ${newTask.toJson()}'); // LOG

                    if (widget.initialTask == null) {
                      await Provider.of<TaskViewModel>(context, listen: false).addTask(context, newTask);
                    } else {
                      await Provider.of<TaskViewModel>(context, listen: false).updateTask(context, newTask);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.initialTask == null ? 'Thêm Công Việc' : 'Lưu Thay Đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}