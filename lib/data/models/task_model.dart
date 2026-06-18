class TaskModel {
  final int id;
  final String title;
  final String? description;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        status: json["status"] ?? 'pending',
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };

  /// Helper untuk menampilkan status dalam bahasa Indonesia
  String get statusLabel => status == 'completed' ? 'Done' : 'Pending';

  /// Helper untuk deskripsi pendek (max 50 karakter)
  String get shortDescription {
    if (description == null || description!.isEmpty) return 'Tidak ada deskripsi';
    if (description!.length <= 50) return description!;
    return '${description!.substring(0, 50)}...';
  }
}

class TaskListResponseModel {
  final bool success;
  final String message;
  final List<TaskModel> data;

  TaskListResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TaskListResponseModel.fromJson(Map<String, dynamic> json) =>
      TaskListResponseModel(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null
            ? List<TaskModel>.from(
                json["data"].map((x) => TaskModel.fromJson(x)))
            : [],
      );
}

class TaskDetailResponseModel {
  final bool success;
  final String message;
  final TaskModel? data;

  TaskDetailResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory TaskDetailResponseModel.fromJson(Map<String, dynamic> json) =>
      TaskDetailResponseModel(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null ? TaskModel.fromJson(json["data"]) : null,
      );
}

class TaskMessageResponseModel {
  final bool success;
  final String message;

  TaskMessageResponseModel({
    required this.success,
    required this.message,
  });

  factory TaskMessageResponseModel.fromJson(Map<String, dynamic> json) =>
      TaskMessageResponseModel(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
      );
}
