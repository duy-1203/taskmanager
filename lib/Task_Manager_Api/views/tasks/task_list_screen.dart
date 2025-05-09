import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/task_view_model.dart';
import '../../app/routes/app_routes.dart';
import '../../models/task.dart';
import '../../view_models/auth_view_model.dart';
import 'package:intl/intl.dart';
import '../../widgets/task_widgets.dart'; // Import TaskOverviewItem

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _selectedCategory = 'Tất cả'; // Giữ lại bộ lọc trạng thái

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<TaskViewModel>(context, listen: false).fetchTasks(context);
  }

  // Hàm lọc công việc dựa trên trạng thái (chỉ còn lọc theo trạng thái)
  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((task) =>
    _selectedCategory == 'Tất cả' || task.status.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final taskViewModel = Provider.of<TaskViewModel>(context);
    final theme = Theme.of(context);

    // Lấy danh sách các trạng thái duy nhất từ danh sách công việc
    final List<String> uniqueStatuses = [
      'Tất cả',
      ...taskViewModel.tasks.map((task) => task.status).toSet().toList()
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh Sách Công Việc',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade400, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 2.0,
        shadowColor: Colors.indigo.withOpacity(0.4),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authViewModel.logout();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight), // Giảm chiều cao
          child: SingleChildScrollView( // Chỉ còn SingleChildScrollView cho bộ lọc
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: uniqueStatuses
                    .map((status) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: _selectedCategory == status,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? status : 'Tất cả';
                      });
                    },
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.all(12.0),
        child: Consumer<TaskViewModel>(
          builder: (context, taskViewModel, child) {
            if (taskViewModel.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: theme.colorScheme.primary),
              );
            } else if (taskViewModel.errorMessage.isNotEmpty) {
              return Center(
                child: Text(
                  taskViewModel.errorMessage,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              );
            } else if (taskViewModel.tasks.isEmpty) {
              return Center(
                child: Text('Không có công việc nào.', style: TextStyle(fontSize: 16)),
              );
            } else {
              return ListView.builder(
                itemCount: _filterTasks(taskViewModel.tasks).length,
                itemBuilder: (context, index) {
                  final task = _filterTasks(taskViewModel.tasks)[index];
                  return TaskOverviewItem(task: task); // Sử dụng TaskOverviewItem ở đây
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: authViewModel.isAdmin()
          ? FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.taskForm);
        },
        child: Icon(Icons.add),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.white,
        elevation: 4.0,
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}