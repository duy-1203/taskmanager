import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/task_view_model.dart';
import '../../app/routes/app_routes.dart';
import '../../widgets/task_widgets.dart';
import '../../view_models/auth_view_model.dart';
import '../../models/task.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = '';
  String _viewMode = 'list'; // Mặc định là list
  String _sortBy = 'status'; // Mặc định phân loại theo trạng thái

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskViewModel>(context, listen: false).fetchTasks(context);
    });
  }

  // Hàm lọc công việc dựa trên tiêu đề hoặc mô tả
  List<Task> _filterTasks(List<Task> tasks) {
    if (_searchQuery.isEmpty) {
      return tasks;
    }
    return tasks.where((task) =>
    task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        task.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  // Hàm sắp xếp công việc
  List<Task> _sortTasks(List<Task> tasks) {
    if (_sortBy == 'status') {
      // Sắp xếp theo trạng thái (bạn có thể tùy chỉnh thứ tự trạng thái)
      tasks.sort((a, b) {
        final statusOrder = {'Mới': 1, 'Đang thực hiện': 2, 'Hoàn thành': 3, 'Đã hủy': 4};
        return (statusOrder[a.status] ?? 0).compareTo(statusOrder[b.status] ?? 0);
      });
    } else if (_sortBy == 'category' && tasks.isNotEmpty && tasks[0].category != null) {
      // Sắp xếp theo danh mục (nếu có và không null)
      tasks.sort((a, b) => (a.category ?? '').compareTo(b.category ?? ''));
    }
    return tasks;
  }

  // Hàm xây dựng các cột Kanban dựa trên trạng thái
  List<Widget> _buildKanbanColumns(List<Task> tasks) {
    final Map<String, List<Task>> groupedTasks = {};
    for (var task in tasks) {
      groupedTasks.putIfAbsent(task.status, () => <Task>[]).add(task);
    }

    return groupedTasks.keys.map((status) {
      return Container(
        width: 300.0,
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: groupedTasks[status]?.length ?? 0,
              itemBuilder: (context, index) {
                final task = groupedTasks[status]![index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(task.title), // Hiển thị tiêu đề công việc trong Kanban card
                  ),
                );
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final taskViewModel = Provider.of<TaskViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final filteredTasks = _filterTasks(taskViewModel.tasks);
    final sortedTasks = _sortTasks(filteredTasks);

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách công việc'),
        actions: <Widget>[
          // Nút chuyển đổi chế độ xem
          IconButton(
            icon: Icon(_viewMode == 'list' ? Icons.view_list : Icons.view_column),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == 'list' ? 'kanban' : 'list';
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authViewModel.logout();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 48.0), // Tăng chiều cao cho dropdown
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm công việc...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ),
              // Dropdown chọn tiêu chí phân loại
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Phân loại theo',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  value: _sortBy,
                  items: <String>['status', 'category'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'status' ? 'Trạng thái' : 'Danh mục'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _sortBy = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (taskViewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (taskViewModel.errorMessage.isNotEmpty) {
            return Center(child: Text(taskViewModel.errorMessage, style: TextStyle(color: Colors.red)));
          } else if (sortedTasks.isEmpty) {
            return Center(child: Text('Không có công việc nào.'));
          } else {
            if (_viewMode == 'list') {
              return ListView.builder(
                itemCount: sortedTasks.length,
                itemBuilder: (context, index) {
                  final task = sortedTasks[index];
                  return TaskOverviewItem(task: task);
                },
              );
            } else {
              // Hiển thị dạng Kanban
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildKanbanColumns(sortedTasks),
                ),
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.taskForm);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}