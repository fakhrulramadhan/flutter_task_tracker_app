import 'dart:convert';

import 'package:flutter_task_tracker_app/data/models/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local datasource untuk caching task list menggunakan SharedPreferences.
/// Cache disimpan sebagai JSON string dengan timestamp untuk validasi.
class TaskLocalDatasource {
  static const String _cacheKey = 'cached_tasks';
  static const String _timestampKey = 'cached_tasks_timestamp';
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Menyimpan task list ke local cache
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_cacheKey, jsonString);
    await prefs.setInt(
      _timestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Mengambil task list dari local cache.
  /// Return null jika cache kosong atau expired.
  Future<List<TaskModel>?> getCachedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    final timestamp = prefs.getInt(_timestampKey);

    if (jsonString == null || timestamp == null) return null;

    // Cek apakah cache masih valid (belum expired)
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final isExpired = DateTime.now().difference(cacheTime) > _cacheExpiry;
    if (isExpired) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    } catch (_) {
      return null;
    }
  }

  /// Mendapatkan timestamp terakhir cache (untuk info "terakhir diupdate")
  Future<DateTime?> getLastCacheTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_timestampKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Menghapus cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_timestampKey);
  }
}
