import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_01/Task_Manager_Api/models/task.dart';
import 'package:app_01/Task_Manager_Api/models/user.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:3000/api";

  // Fetch tasks from API
  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'));

    if (response.statusCode == 200) {
      // Parse JSON response and return a list of tasks
      final List<dynamic> data = json.decode(response.body);
      return data.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // Fetch users from API
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      // Parse JSON response and return a list of users
      final List<dynamic> data = json.decode(response.body);
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Create a task
  Future<void> createTask(Map<String, dynamic> task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create task');
    }
  }
}
