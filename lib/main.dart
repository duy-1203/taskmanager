import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_01/Task_Manager_Api/app/routes/app_routes.dart';
import 'package:app_01/Task_Manager_Api/views/login/login_screen.dart';
import 'package:app_01/Task_Manager_Api/views/dashboard/dashboard_screen.dart';
import 'package:app_01/Task_Manager_Api/views/tasks/task_list_screen.dart';
import 'package:app_01/Task_Manager_Api/views/tasks/task_detail_screen.dart';
import 'package:app_01/Task_Manager_Api/views/tasks/task_form_screen.dart';
import 'package:app_01/Task_Manager_Api/views/users/user_list_screen.dart';
import 'package:app_01/Task_Manager_Api/view_models/auth_view_model.dart';
import 'package:app_01/Task_Manager_Api/view_models/task_view_model.dart';
import 'package:app_01/Task_Manager_Api/app/theme/app_theme.dart';
import 'package:app_01/Task_Manager_Api/models/task.dart';
import 'package:app_01/Task_Manager_Api/views/login/registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authViewModel = AuthViewModel();
  await authViewModel.checkAuthStatus();

  runApp(MyApp(authViewModel: authViewModel));
}

class MyApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  const MyApp({Key? key, required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProvider(create: (context) => TaskViewModel()),
      ],
      child: MaterialApp(
        title: 'Task Manager',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.login:
              return MaterialPageRoute(builder: (_) => LoginScreen());
            case AppRoutes.registration:
              return MaterialPageRoute(builder: (_) => RegistrationScreen());
            case AppRoutes.dashboard:
              return MaterialPageRoute(builder: (_) => DashboardScreen());
            case AppRoutes.taskList:
              return MaterialPageRoute(builder: (_) => TaskListScreen());
            case AppRoutes.taskDetail:
              final taskId = settings.arguments as String? ?? '';
              return MaterialPageRoute(
                  builder: (_) => TaskDetailScreen(taskId: taskId));
            case AppRoutes.taskForm:
              final task = settings.arguments is Task
                  ? settings.arguments as Task
                  : null;
              return MaterialPageRoute(
                  builder: (_) => TaskFormScreen(initialTask: task));
            case AppRoutes.userList:
              return MaterialPageRoute(builder: (_) => UserListScreen());
            default:
              return MaterialPageRoute(builder: (_) => LoginScreen());
          }
        },
      ),
    );
  }
}
