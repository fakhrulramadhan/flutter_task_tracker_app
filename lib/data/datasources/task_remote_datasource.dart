import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_task_tracker_app/core/constants/variables.dart';
import 'package:flutter_task_tracker_app/data/models/task_model.dart';
import 'package:http/http.dart' as http;

class TaskRemoteDatasource {
  /// GET /api/tasks - Mengambil semua tasks
  /// Optional query: ?status=pending&page=1&per_page=10
  Future<Either<String, TaskListResponseModel>> getTasks({
    String? status,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      queryParams['page'] = page.toString();
      queryParams['per_page'] = perPage.toString();

      final uri = Uri.parse('${Variables.baseUrl}/tasks')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      log("GET Tasks - Status: ${response.statusCode}");
      log("GET Tasks - Body: ${response.body}");

      if (response.statusCode == 200) {
        return Right(
          TaskListResponseModel.fromJson(jsonDecode(response.body)),
        );
      } else {
        return const Left('Gagal mengambil daftar task');
      }
    } catch (e) {
      log("GET Tasks - Error: $e");
      return Left('Terjadi kesalahan: $e');
    }
  }

  /// GET /api/tasks/{id} - Mengambil detail satu task
  Future<Either<String, TaskDetailResponseModel>> getTaskById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/tasks/$id'),
        headers: {
          'Accept': 'application/json',
        },
      );

      log("GET Task Detail - Status: ${response.statusCode}");
      log("GET Task Detail - Body: ${response.body}");

      if (response.statusCode == 200) {
        return Right(
          TaskDetailResponseModel.fromJson(jsonDecode(response.body)),
        );
      } else if (response.statusCode == 404) {
        return const Left('Task tidak ditemukan');
      } else {
        return const Left('Gagal mengambil detail task');
      }
    } catch (e) {
      log("GET Task Detail - Error: $e");
      return Left('Terjadi kesalahan: $e');
    }
  }

  /// POST /api/tasks - Membuat task baru
  Future<Either<String, TaskDetailResponseModel>> createTask({
    required String title,
    String? description,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'title': title,
      };
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }
      if (status != null && status.isNotEmpty) {
        body['status'] = status;
      }

      final response = await http.post(
        Uri.parse('${Variables.baseUrl}/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      log("POST Create Task - Status: ${response.statusCode}");
      log("POST Create Task - Body: ${response.body}");

      if (response.statusCode == 201) {
        return Right(
          TaskDetailResponseModel.fromJson(jsonDecode(response.body)),
        );
      } else if (response.statusCode == 422) {
        final errors = jsonDecode(response.body);
        final message = errors['message'] ?? 'Validasi gagal';
        return Left(message.toString());
      } else {
        return const Left('Gagal membuat task');
      }
    } catch (e) {
      log("POST Create Task - Error: $e");
      return Left('Terjadi kesalahan: $e');
    }
  }

  /// PATCH /api/tasks/{id} - Update task (partial)
  Future<Either<String, TaskDetailResponseModel>> updateTask({
    required int id,
    String? title,
    String? description,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (status != null) body['status'] = status;

      final response = await http.patch(
        Uri.parse('${Variables.baseUrl}/tasks/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      log("PATCH Update Task - Status: ${response.statusCode}");
      log("PATCH Update Task - Body: ${response.body}");

      if (response.statusCode == 200) {
        return Right(
          TaskDetailResponseModel.fromJson(jsonDecode(response.body)),
        );
      } else if (response.statusCode == 404) {
        return const Left('Task tidak ditemukan');
      } else {
        return const Left('Gagal memperbarui task');
      }
    } catch (e) {
      log("PATCH Update Task - Error: $e");
      return Left('Terjadi kesalahan: $e');
    }
  }

  /// PUT /api/tasks/{id} - Update full task
  Future<Either<String, TaskDetailResponseModel>> updateFullTask({
    required int id,
    required String title,
    String? description,
    required String status,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'title': title,
        'status': status,
      };
      if (description != null) body['description'] = description;

      final response = await http.put(
        Uri.parse('${Variables.baseUrl}/tasks/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      log("PUT Update Task - Status: ${response.statusCode}");
      log("PUT Update Task - Body: ${response.body}");

      if (response.statusCode == 200) {
        return Right(
          TaskDetailResponseModel.fromJson(jsonDecode(response.body)),
        );
      } else {
        return const Left('Gagal memperbarui task');
      }
    } catch (e) {
      log("PUT Update Task - Error: $e");
      return Left('Terjadi kesalahan: $e');
    }
  }

  /// DELETE /api/tasks/{id} - Menghapus task
  Future<Either<String, TaskMessageResponseModel>> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${Variables.baseUrl}/tasks/$id'),
        headers: {
          'Accept': 'application/json',
        },
      );

      log("DELETE Task - Status: ${response.statusCode}");
      log("DELETE Task - Body: ${response.body}");

      if (response.statusCode == 200) {
        return Right(
          TaskMessageResponseModel.fromJson(jsonDecode(response.body)),
        );
      } else if (response.statusCode == 404) {
        return const Left('Task tidak ditemukan');
      } else {
        return const Left('Gagal menghapus task');
      }
    } catch (e) {
      log("DELETE Task - Error: $e");
      return Left('Terjadi kesalahan: $e');
    }
  }
}
