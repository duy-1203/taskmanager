class Task {
  final String id;
  final String title;
  final String description;
  String status;
  int priority;
  DateTime? dueDate;
  final DateTime createdAt;
  DateTime? updatedAt;
  final String createdBy; // Lưu ID người tạo
  String? assignedTo; // Lưu ID người được giao
  String? assignedToName; // Tên người được giao
  String? category;
  List<String>? attachments;
  List<Comment>? comments; // Danh sách bình luận
  String? createdByName; // Thuộc tính để lưu tên người tạo


  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
    this.assignedTo,
    this.assignedToName,
    required this.createdBy,
    this.category,
    this.attachments,
    this.comments,
    this.createdByName, // Thêm vào constructor

  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'Mới',
      priority: json['priority'] as int? ?? 1,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      assignedTo: json['assignedTo'] is Map ? json['assignedTo']['id'] as String? : json['assignedTo'] as String?,
      assignedToName: json['assignedTo'] is Map ? json['assignedTo']['username'] as String? : null,
      createdBy: json['createdBy'] is Map ? json['createdBy']['id'] as String? ?? '' : json['createdBy'] as String? ?? '',
      createdByName: json['createdBy'] is Map ? json['createdBy']['username'] as String? : null, // Thêm dòng này để lấy tên người tạo
      category: json['category'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)?.cast<String>(),
      comments: (json['comments'] as List<dynamic>?)?.map((c) => Comment.fromJson(c as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'category': category,
      'attachments': attachments,
      'comments': comments?.map((c) => c.toJson()).toList(),
    };
  }
}

class Comment {
  final String content;
  final String createdBy; // Lưu ID người tạo bình luận
  final String createdByName; // Tên người tạo bình luận
  final DateTime createdAt;

  Comment({
    required this.content,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      content: json['content'] as String? ?? '', // Xử lý null cho content
      createdBy: json['createdBy'] is Map ? json['createdBy']['id'] as String? ?? '' : json['createdBy'] as String? ?? '', // Xử lý trường hợp createdBy là object hoặc string
      createdByName: json['createdBy'] is Map ? json['createdBy']['username'] as String? ?? 'Unknown' : 'Unknown',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}