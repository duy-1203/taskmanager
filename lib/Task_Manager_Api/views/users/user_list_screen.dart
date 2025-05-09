import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context); // Sửa lỗi ở đây

    if (!authViewModel.isAdmin()) {
      return Scaffold(
        appBar: AppBar(title: Text('Không được phép')),
        body: Center(
          child: Text('Bạn không có quyền truy cập vào trang này.', style: TextStyle(fontSize: 18.0)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Quản lý Thành viên')),
      body: Center(
        child: Text('Tính năng quản lý thành viên sẽ được triển khai sau (chỉ dành cho Admin).'),
      ),
    );
  }
}