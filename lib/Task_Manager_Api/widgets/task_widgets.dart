import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';
import '../app/routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../view_models/task_view_model.dart';

class TaskOverviewItem extends StatelessWidget {
  final Task task;

  const TaskOverviewItem({Key? key, required this.task}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'mới':
        return Colors.blue.shade200;
      case 'đang thực hiện':
        return Colors.orange.shade200;
      case 'hoàn thành':
        return Colors.green.shade300;
      case 'đã hủy':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green.shade200;
      case 2:
        return Colors.orange.shade200;
      case 3:
        return Colors.red.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              task.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.indigo.shade700,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              task.description.length > 70 ? '${task.description.substring(0, 70)}...' : task.description,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildStatusChip(task.status, theme),
                _buildPriorityChip(task.priority, theme),
                if (task.dueDate != null)
                  Text(
                    'Hạn: ${DateFormat('dd/MM/yyyy').format(task.dueDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                  ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.check_circle_outline, color: Colors.green),
                  tooltip: 'Đánh dấu hoàn thành',
                  onPressed: () {
                    Provider.of<TaskViewModel>(context, listen: false).updateTaskStatus(task.id, 'Hoàn thành', context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Sửa',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.taskForm, arguments: task);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Xóa',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Xác nhận xóa'),
                          content: Text('Bạn có chắc chắn muốn xóa công việc này?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                Provider.of<TaskViewModel>(context, listen: false).deleteTask(context, task.id);
                                Navigator.of(context).pop(true);
                              },
                              child: Text('Xóa', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.taskDetail, arguments: task.id);
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                ),
                child: Text('Xem chi tiết'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color backgroundColor;
    switch (status.toLowerCase()) {
      case 'mới':
        backgroundColor = Colors.blue.shade200;
        break;
      case 'đang thực hiện':
        backgroundColor = Colors.orange.shade200;
        break;
      case 'hoàn thành':
        backgroundColor = Colors.green.shade300;
        break;
      case 'đã hủy':
        backgroundColor = Colors.red.shade200;
        break;
      default:
        backgroundColor = Colors.grey.shade300;
    }
    return Chip(
      label: Text(status, style: TextStyle(color: Colors.white, fontSize: 12.0)),
      backgroundColor: backgroundColor,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildPriorityChip(int priority, ThemeData theme) {
    Color backgroundColor;
    switch (priority) {
      case 1:
        backgroundColor = Colors.green.shade200;
        break;
      case 2:
        backgroundColor = Colors.orange.shade200;
        break;
      case 3:
        backgroundColor = Colors.red.shade200;
        break;
      default:
        backgroundColor = Colors.grey.shade200;
    }
    return Chip(
      label: Text('Ưu tiên: $priority', style: TextStyle(fontSize: 12.0)),
      backgroundColor: backgroundColor,
      visualDensity: VisualDensity.compact,
    );
  }
}