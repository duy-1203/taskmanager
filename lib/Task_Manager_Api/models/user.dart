class User {
  final String id;
  final String username;
  final String email;
  final String? password; // Cho phép password là null
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isAdmin;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.password, // Password có thể là null
    required this.createdAt,
    required this.lastActive,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'] ?? '', // Vẫn giữ giá trị mặc định từ JSON nếu có
      createdAt: DateTime.parse(json['createdAt']),
      lastActive: DateTime.parse(json['lastActive']),
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'isAdmin': isAdmin,
    };
  }
}