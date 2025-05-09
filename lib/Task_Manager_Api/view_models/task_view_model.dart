import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'auth_view_model.dart';

class TaskViewModel extends ChangeNotifier {
  List<Task> _tasks = [];
  String _errorMessage = '';
  bool _isLoading = false;
  Task? _selectedTask;
  Task? _newTask;
  final String _baseUrl = 'http://10.0.2.2:3000/api/tasks';

  List<Task> get tasks => _tasks;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Task? get selectedTask => _selectedTask;
  Task? get newTask => _newTask;

  // Hàm tải danh sách công việc
  Future<void> fetchTasks(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    print('Bắt đầu fetchTasks...'); // LOG

    final authToken = await _getAuthToken(context);
    if (authToken == null) {
      _errorMessage = 'Không tìm thấy token đăng nhập.';
      _isLoading = false;
      Future.delayed(Duration.zero, notifyListeners); // Sửa: Gọi notifyListeners sau build
      print('fetchTasks: Không tìm thấy token.'); // LOG
      return;
    }

    try {
      print('fetchTasks: Gửi GET request đến $_baseUrl với token: $authToken'); // LOG
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      print('fetchTasks: Response - Status: ${response.statusCode}, Body: ${response.body}'); // LOG
      if (response.statusCode == 200) {
        final List<dynamic> tasksData = jsonDecode(response.body);
        _tasks = tasksData.map((json) => Task.fromJson(json)).toList();
        print('fetchTasks: Tải thành công ${_tasks.length} công việc.'); // LOG
      } else {
        _errorMessage = 'Không thể tải danh sách công việc. Status code: ${response.statusCode}';
        print('fetchTasks: Lỗi tải công việc - Status: ${response.statusCode}, Body: ${response.body}'); // LOG
      }
    } catch (error) {
      _errorMessage = 'Lỗi kết nối đến server: $error';
      print('fetchTasks: Lỗi kết nối: $error'); // LOG
    } finally {
      _isLoading = false;
      Future.delayed(Duration.zero, notifyListeners); // Sửa: Gọi notifyListeners sau build
      print('fetchTasks: Hoàn tất.'); // LOG
    }
  }

  // Hàm lấy chi tiết công việc
  Future<Task?> fetchTaskDetail(BuildContext context, String taskId) async {
    _isLoading = true;
    notifyListeners();
    print('Bắt đầu fetchTaskDetail với ID: $taskId...'); // LOG

    final authToken = await _getAuthToken(context);
    if (authToken == null) {
      _errorMessage = 'Không tìm thấy token đăng nhập.';
      _isLoading = false;
      Future.delayed(Duration.zero, notifyListeners); // Sửa: Gọi notifyListeners sau build
      print('fetchTaskDetail: Không tìm thấy token.'); // LOG
      return null;
    }

    try {
      print('fetchTaskDetail: Gửi GET request đến $_baseUrl/$taskId với token: $authToken'); // LOG
      final response = await http.get(
        Uri.parse('$_baseUrl/$taskId'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      print('fetchTaskDetail: Response - Status: ${response.statusCode}, Body: ${response.body}'); // LOG
      if (response.statusCode == 200) {
        final taskData = jsonDecode(response.body);
        _selectedTask = Task.fromJson(taskData);
        print('fetchTaskDetail: Tải thành công chi tiết công việc.'); // LOG
        return _selectedTask;
      } else {
        _errorMessage = 'Không thể tải chi tiết công việc. Status code: ${response.statusCode}';
        print('fetchTaskDetail: Lỗi tải chi tiết - Status: ${response.statusCode}, Body: ${response.body}'); // LOG
        return null;
      }
    } catch (error) {
      _errorMessage = 'Lỗi kết nối đến server: $error';
      print('fetchTaskDetail: Lỗi kết nối: $error'); // LOG
      return null;
    } finally {
      _isLoading = false;
      Future.delayed(Duration.zero, notifyListeners); // Sửa: Gọi notifyListeners sau build
      print('fetchTaskDetail: Hoàn tất.'); // LOG
    }
  }

  // Hàm lấy token đăng nhập
  Future<String?> _getAuthToken(BuildContext context) async {
    final authToken = await Provider.of<AuthViewModel>(context, listen: false).authToken;
    return authToken;
  }

  // Thêm công việc mới
  Future<bool> addTask(BuildContext context, Task task) async {
    _isLoading = true;
    notifyListeners();
    print('Bắt đầu addTask...'); // LOG

    final authToken = await _getAuthToken(context);
    if (authToken == null) {
      _errorMessage = 'Không tìm thấy token đăng nhập.';
      _isLoading = false;
      Future.delayed(Duration.zero, notifyListeners); // Sửa: Gọi notifyListeners sau build
      print('addTask: Không tìm thấy token.'); // LOG
      return false;
    }

    try {
      print('addTask: Gửi POST request đến $_baseUrl với token: $authToken, body: ${jsonEncode(task.toJson()..remove('id'))}'); // LOG
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $authToken'},
        body: jsonEncode(task.toJson()..remove('id')),
      );
      print('addTask: Response - Status: ${response.statusCode}, Body: ${response.body}'); // LOG
      if (response.statusCode == 201) {
        fetchTasks(context);
        _errorMessage = '';
        print('addTask: Thêm công việc thành công.'); // LOG
        return true;
      } else {
        _errorMessage = 'Không thể thêm công việc. Status code: ${response.statusCode}, Body: ${response.body}';
        print('addTask: Lỗi thêm công việc - Status: ${response.statusCode}, Body: ${response.body}'); // LOG
      }
    } catch (error) {
      _errorMessage = 'Lỗi kết nối đến server: $error';
      print('addTask: Lỗi kết nối: $error'); // LOG
    } finally {
      _isLoading = false;
      Future.delayed(Duration.zero, notifyListeners); // Sửa: Gọi notifyListeners sau build
      print('addTask: Hoàn tất.'); // LOG
    }
    return false;
  }

  // Cập nhật công việc
  Future<bool> updateTask(BuildContext context, Task task) async {
    _isLoading = true;
    notifyListeners();
    print('Bắt đầu updateTask với ID: ${task.id}...'); // LOG

    final authToken = await _getAuthToken(context);
    if (authToken == null) {
      _errorMessage = 'Không tìm thấy token đăng nhập.';
      _isLoading = false;
      Future.delayed(Duration.zero, notifyListeners); // Sửa: Gọi notifyListeners sau build
      print('updateTask: Không tìm thấy token.'); // LOG
      return false;
    }

    try {
      print('updateTask: Gửi PUT request đến $_baseUrl/${task.id} với token: $authToken, body: ${jsonEncode(task.toJson())}'); // LOG
      final response = await http.put(
        Uri.parse('$_baseUrl/${task.id}'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $authToken'},
        body: jsonEncode(task.toJson()),
      );
      print('updateTask: Response - Status: ${response.statusCode}, Body: ${response.body}'); // LOG
      if (response.statusCode == 200) {
        fetchTasks(context);
        _errorMessage = '';
        print('updateTask: Cập nhật công việc thành công.'); // LOG
        return true;
      } else {
        _errorMessage = 'Không thể cập nhật công việc. Status code: ${response.statusCode}, Body: ${response.body}';
        print('updateTask: Lỗi cập nhật công việc - Status: ${response.statusCode}, Body: ${response.body}'); // LOG
      }
    } catch (error) {
      _errorMessage = 'Lỗi kết nối đến server: $error';
      print('updateTask: Lỗi kết nối: $error'); // LOG
    } finally {
      _isLoading = false;
      Future.delayed(Duration.zero, notifyListeners); // Sửa: Gọi notifyListeners sau build
      print('updateTask: Hoàn tất.'); // LOG
    }
    return false;
  }

  // Xóa công việc
  Future<bool> deleteTask(BuildContext context, String taskId) async {
    _isLoading = true;
    notifyListeners();
    print('Bắt đầu deleteTask với ID: $taskId...'); // LOG

    final authToken = await _getAuthToken(context);
    if (authToken == null) {
      _errorMessage = 'Không tìm thấy token đăng nhập.';
      _isLoading = false;
      Future.delayed(Duration.zero, notifyListeners); // Sửa: Gọi notifyListeners sau build
      print('deleteTask: Không tìm thấy token.'); // LOG
      return false;
    }

    try {
      print('deleteTask: Gửi DELETE request đến $_baseUrl/$taskId với token: $authToken'); // LOG
      final response = await http.delete(
        Uri.parse('$_baseUrl/$taskId'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      print('deleteTask: Response - Status: ${response.statusCode}, Body: ${response.body}'); // LOG
      if (response.statusCode == 200) {
        _tasks.removeWhere((task) => task.id == taskId);
        _errorMessage = '';
        print('deleteTask: Xóa công việc thành công.'); // LOG
        return true;
      } else {
        _errorMessage = 'Không thể xóa công việc. Status code: ${response.statusCode}, Body: ${response.body}';
        print('deleteTask: Lỗi xóa công việc - Status: ${response.statusCode}, Body: ${response.body}'); // LOG
      }
    } catch (error) {
      _errorMessage = 'Lỗi kết nối đến server: $error';
      print('deleteTask: Lỗi kết nối: $error'); // LOG
    } finally {
      _isLoading = false;
      Future.delayed(Duration.zero, notifyListeners); // Sửa: Gọi notifyListeners sau build
      print('deleteTask: Hoàn tất.'); // LOG
    }
    return false;
  }

  // Cập nhật trạng thái công việc
  Future<bool> updateTaskStatus(String taskId, String newStatus, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    print('Bắt đầu updateTaskStatus cho ID: $taskId thành trạng thái: $newStatus...'); // LOG

    final authToken = await _getAuthToken(context); // Truyền context để lấy token
    if (authToken == null) {
      _errorMessage = 'Không tìm thấy token đăng nhập.';
      _isLoading = false;
      Future.delayed(Duration.zero, notifyListeners);
      print('updateTaskStatus: Không tìm thấy token.'); // LOG
      return false;
    }

    try {
      print('updateTaskStatus: Gửi PATCH request đến $_baseUrl/$taskId/status với token: $authToken, body: {"status": "$newStatus"}'); // LOG
      final response = await http.patch( // Sử dụng http.patch
        Uri.parse('$_baseUrl/$taskId/status'), // Endpoint chính xác
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $authToken'},
        body: jsonEncode({'status': newStatus}),
      );
      print('updateTaskStatus: Response - Status: ${response.statusCode}, Body: ${response.body}'); // LOG
      if (response.statusCode == 200) {
        // Cập nhật trạng thái trong danh sách cục bộ
        final index = _tasks.indexWhere((task) => task.id == taskId);
        if (index != -1) {
          _tasks[index].status = newStatus;
        }
        _errorMessage = '';
        notifyListeners();
        print('updateTaskStatus: Cập nhật trạng thái thành công.'); // LOG
        return true;
      } else {
        _errorMessage = 'Không thể cập nhật trạng thái công việc. Status code: ${response.statusCode}, Body: ${response.body}';
        print('updateTaskStatus: Lỗi cập nhật trạng thái - Status: ${response.statusCode}, Body: ${response.body}'); // LOG
      }
    } catch (error) {
      _errorMessage = 'Lỗi kết nối đến server: $error';
      print('updateTaskStatus: Lỗi kết nối: $error'); // LOG
    } finally {
      _isLoading = false;
      Future.delayed(Duration.zero, notifyListeners);
      print('updateTaskStatus: Hoàn tất.'); // LOG
    }
    return false;
  }
}