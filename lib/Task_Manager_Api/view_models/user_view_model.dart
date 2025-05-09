import 'package:flutter/material.dart';
import 'package:app_01/Task_Manager_Api/services/api_service.dart';
import 'package:app_01/Task_Manager_Api/models/user.dart';

class UserViewModel with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Fetch users from API
  Future<List<User>> fetchUsers() async {
    try {
      return await _apiService.fetchUsers();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }
}
