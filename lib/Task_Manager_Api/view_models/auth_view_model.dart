import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthViewModel extends ChangeNotifier {
  User? _loggedInUser;
  String _errorMessage = '';
  final String _baseUrl = 'http://10.0.2.2:3000/api/users';

  User? get loggedInUser => _loggedInUser;
  String get errorMessage => _errorMessage;

  Future<String?> get authToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> _saveAuthInfo(String token, String userId, bool isAdmin, String username, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    await prefs.setString('userId', userId);
    await prefs.setBool('isAdmin', isAdmin);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    _loggedInUser = User(id: userId, username: username, email: email, isAdmin: isAdmin, createdAt: DateTime.now(), lastActive: DateTime.now());
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      final body = jsonEncode({'username': username, 'password': password});
      print('Dữ liệu đăng nhập gửi đi: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final token = data['token'];
          final userId = data['userId'];
          final isAdminFromServer = data['isAdmin'];
          final loggedInUsername = data['username'];
          final loggedInEmail = data['email'];

          bool isAdminBool = false;
          if (isAdminFromServer != null) {
            if (isAdminFromServer is bool) {
              isAdminBool = isAdminFromServer;
            } else if (isAdminFromServer is String) {
              isAdminBool = isAdminFromServer.toLowerCase() == 'true';
            } else if (isAdminFromServer is int) {
              isAdminBool = isAdminFromServer == 1;
            }
          }

          if (token != null && userId != null) {
            await _saveAuthInfo(
              token,
              userId,
              isAdminBool,
              loggedInUsername ?? '',
              loggedInEmail ?? '',
            );
            return true;
          } else {
            _errorMessage = 'Đăng nhập thành công nhưng không nhận được token hoặc ID người dùng.';
            notifyListeners();
            return false;
          }
        } catch (e) {
          _errorMessage = 'Lỗi khi xử lý dữ liệu đăng nhập: $e';
          notifyListeners();
          return false;
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          _errorMessage = errorData['message'] ?? 'Đăng nhập thất bại.';
        } catch (e) {
          _errorMessage = 'Lỗi khi xử lý lỗi đăng nhập: $e';
        }
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'Không thể kết nối đến server: $error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        _errorMessage = 'Đăng ký thành công.';
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Đăng ký thất bại.';
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'Không thể kết nối đến server.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userId');
    await prefs.remove('isAdmin');
    await prefs.remove('username');
    await prefs.remove('email');
    _loggedInUser = null;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final userId = prefs.getString('userId');
    final isAdmin = prefs.getBool('isAdmin') ?? false;
    final username = prefs.getString('username');
    final email = prefs.getString('email');
    if (token != null && userId != null && username != null && email != null) {
      _loggedInUser = User(id: userId, username: username, email: email, isAdmin: isAdmin, createdAt: DateTime.now(), lastActive: DateTime.now());
      notifyListeners();
    }
  }

  bool isAdmin() {
    print('loggedInUser?.isAdmin: ${_loggedInUser?.isAdmin}');
    return _loggedInUser?.isAdmin == true;
  }

  Future<List<User>> fetchUsers() async {
    final token = await authToken;
    if (token == null || !isAdmin()) {
      return []; // Hoặc xử lý lỗi không được phép
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl'), // Lấy danh sách tất cả users
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> usersData = jsonDecode(response.body);
        return usersData.map((json) => User.fromJson(json)).toList();
      } else {
        // Xử lý lỗi khi không thể lấy danh sách người dùng
        print('Failed to fetch users: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error fetching users: $error');
      return [];
    }
  }
}