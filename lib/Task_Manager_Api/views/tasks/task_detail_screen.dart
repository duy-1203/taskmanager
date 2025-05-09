import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/task_view_model.dart';
import '../../models/task.dart';
import 'package:intl/intl.dart';
import '../../app/routes/app_routes.dart';
import '../../view_models/auth_view_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskViewModel>(context, listen: false).fetchTaskDetail(context, widget.taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskViewModel = Provider.of<TaskViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isAdmin = authViewModel.isAdmin();

    if (taskViewModel.isLoading) {
      return _buildLoadingIndicator();
    }

    if (taskViewModel.errorMessage.isNotEmpty) {
      return _buildErrorScreen(taskViewModel.errorMessage);
    }

    if (taskViewModel.selectedTask == null) {
      return _buildNotFoundScreen();
    }

    final Task task = taskViewModel.selectedTask!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Công Việc', style: TextStyle(color: Colors.black87)), // Màu chữ tiêu đề AppBar
        backgroundColor: Colors.grey[200], // Màu nền AppBar nhạt
        iconTheme: IconThemeData(color: Colors.black87), // Màu icon AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Tiêu đề
            _buildSectionTitle(task.title, size: 20.0, color: Colors.blueGrey[800]!), // Giảm kích thước, đổi màu
            SizedBox(height: 12.0),

            // Mô tả
            _buildDetailRow('Mô tả', task.description, valueColor: Colors.black87, fontSize: 16.0), // Thêm fontSize
            SizedBox(height: 12.0),

            // Trạng thái và Độ ưu tiên
            Row(
              children: [
                Expanded(child: _buildDetailRow('Trạng thái', task.status, valueColor: Colors.black87, fontSize: 16.0)),
                SizedBox(width: 16.0),
                Expanded(child: _buildDetailRow('Độ ưu tiên', task.priority.toString(), valueColor: Colors.black87, fontSize: 16.0)),
              ],
            ),
            SizedBox(height: 10.0),

            // Hạn hoàn thành, Ngày tạo, Ngày cập nhật
            if (task.dueDate != null)
              _buildDetailRow('Hạn hoàn thành', DateFormat('dd/MM/yyyy HH:mm').format(task.dueDate!), valueColor: Colors.black87, fontSize: 16.0),
            _buildDetailRow('Ngày tạo', DateFormat('dd/MM/yyyy HH:mm').format(task.createdAt), valueColor: Colors.black87, fontSize: 16.0),
            if (task.updatedAt != null)
              _buildDetailRow('Ngày cập nhật', DateFormat('dd/MM/yyyy HH:mm').format(task.updatedAt!), valueColor: Colors.black87, fontSize: 16.0),

            SizedBox(height: 10.0),

            // Người được giao và Người tạo
            _buildDetailRow('Người được giao', task.assignedTo ?? 'Không có', valueColor: Colors.black87, fontSize: 16.0),
            _buildDetailRow('Người tạo', task.createdBy, valueColor: Colors.black87, fontSize: 16.0),

            SizedBox(height: 10.0),

            // Phân loại
            if (task.category != null)
              _buildDetailRow('Phân loại', task.category!, valueColor: Colors.black87, fontSize: 16.0),

            // Tệp đính kèm
            if (task.attachments != null && task.attachments!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  _buildSectionTitle('Tệp đính kèm', size: 18.0, color: Colors.blueGrey[700]!),
                  SizedBox(height: 8.0),
                  for (var attachment in task.attachments!)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('- $attachment', style: TextStyle(fontSize: 16.0, color: Colors.black87)),
                    ),
                ],
              ),

            SizedBox(height: 24.0),

            // Hành động của Admin
            if (isAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.taskForm,
                        arguments: task,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400], // Màu nút Chỉnh sửa
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Điều chỉnh padding nút
                      textStyle: TextStyle(fontSize: 16.0), // Kích thước chữ nút
                    ),
                    child: Text('Chỉnh sửa'),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, task.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400], // Màu nút Xóa
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Điều chỉnh padding nút
                      textStyle: TextStyle(fontSize: 16.0), // Kích thước chữ nút
                    ),
                    child: Text('Xóa'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {double size = 18.0, required Color color}) {
    return Text(
      title,
      style: TextStyle(fontSize: size, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, double fontSize = 14.0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: fontSize, color: Colors.black54),
          children: <TextSpan>[
            TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: TextStyle(color: valueColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Công Việc'),
      ),
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Công Việc'),
      ),
      body: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildNotFoundScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Công Việc'),
      ),
      body: Center(child: Text('Không tìm thấy công việc.')),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String taskId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: SingleChildScrollView(
            child: const ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa công việc này?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
              onPressed: () {
                Provider.of<TaskViewModel>(context, listen: false).deleteTask(context, taskId);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}