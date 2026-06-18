import 'package:dartz/dartz.dart';
import 'package:flutter_task_tracker_app/core/services/connectivity_service.dart';
import 'package:flutter_task_tracker_app/data/datasources/task_local_datasource.dart';
import 'package:flutter_task_tracker_app/data/datasources/task_remote_datasource.dart';
import 'package:flutter_task_tracker_app/data/models/task_model.dart';

/// Repository bertindak sebagai single source of truth.
/// Strategy: API-first, fallback ke local cache jika offline atau error.
class TaskRepository {
  final TaskRemoteDatasource _remote;
  final TaskLocalDatasource _local;
  final ConnectivityService _connectivity;

  TaskRepository({
    required TaskRemoteDatasource remote,
    required TaskLocalDatasource local,
    required ConnectivityService connectivity,
  })  : _remote = remote,
        _local = local,
        _connectivity = connectivity;

  /// Mengambil daftar task dengan strategi:
  /// 1. Jika online → ambil dari API, lalu cache hasilnya
  /// 2. Jika offline → ambil dari local cache
  /// 3. Jika online tapi API error → coba fallback ke cache
  Future<Either<String, TaskListResponseModel>> getTasks({
    String? status,
    int page = 1,
    int perPage = 10,
  }) async {
    // Strategy: selalu coba API dulu
    final result = await _remote.getTasks(
      status: status,
      page: page,
      perPage: perPage,
    );

    return result.fold(
      (error) async {
        // API gagal → coba fallback ke cache
        final cached = await _local.getCachedTasks();
        if (cached != null && cached.isNotEmpty) {
          // Filter cache by status jika ada
          List<TaskModel> filtered = cached;
          if (status != null && status.isNotEmpty) {
            filtered = cached.where((t) => t.status == status).toList();
          }
          return Right(
            TaskListResponseModel(
              success: true,
              message: 'Data dari cache (offline)',
              data: filtered,
            ),
          );
        }
        return Left(error);
      },
      (response) async {
        // API sukses → cache data (hanya page 1 untuk full refresh)
        if (page == 1 && status == null) {
          await _local.cacheTasks(response.data);
        }
        return Right(response);
      },
    );
  }

  /// Mengambil detail task
  Future<Either<String, TaskDetailResponseModel>> getTaskById(int id) async {
    return _remote.getTaskById(id);
  }

  /// Membuat task baru
  Future<Either<String, TaskDetailResponseModel>> createTask({
    required String title,
    String? description,
    String? status,
  }) async {
    final result = await _remote.createTask(
      title: title,
      description: description,
      status: status,
    );

    // Jika sukses, invalidate cache agar data terbaru di-fetch
    result.fold(
      (_) => null,
      (_) async => await _local.clearCache(),
    );

    return result;
  }

  /// Update status task
  Future<Either<String, TaskDetailResponseModel>> updateTask({
    required int id,
    String? title,
    String? description,
    String? status,
  }) async {
    final result = await _remote.updateTask(
      id: id,
      title: title,
      description: description,
      status: status,
    );

    result.fold(
      (_) => null,
      (_) async => await _local.clearCache(),
    );

    return result;
  }

  /// Update full task
  Future<Either<String, TaskDetailResponseModel>> updateFullTask({
    required int id,
    required String title,
    String? description,
    required String status,
  }) async {
    final result = await _remote.updateFullTask(
      id: id,
      title: title,
      description: description,
      status: status,
    );

    result.fold(
      (_) => null,
      (_) async => await _local.clearCache(),
    );

    return result;
  }

  /// Hapus task
  Future<Either<String, TaskMessageResponseModel>> deleteTask(int id) async {
    final result = await _remote.deleteTask(id);

    result.fold(
      (_) => null,
      (_) async => await _local.clearCache(),
    );

    return result;
  }

  /// Cek status koneksi
  Future<bool> isOnline() => _connectivity.isOnline();

  /// Dapatkan timestamp cache terakhir
  Future<DateTime?> getLastCacheTime() => _local.getLastCacheTime();
}
