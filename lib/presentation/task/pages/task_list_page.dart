import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task_tracker_app/core/constants/colors.dart';
import 'package:flutter_task_tracker_app/core/components/loading_indicator.dart';
import 'package:flutter_task_tracker_app/core/components/error_message.dart';
import 'package:flutter_task_tracker_app/core/components/empty_state.dart';
import 'package:flutter_task_tracker_app/core/components/connectivity_widgets.dart';
import 'package:flutter_task_tracker_app/core/services/connectivity_service.dart';
import 'package:flutter_task_tracker_app/presentation/task/blocs/task_bloc.dart';
import 'package:flutter_task_tracker_app/presentation/task/blocs/task_event.dart';
import 'package:flutter_task_tracker_app/presentation/task/blocs/task_state.dart';
import 'package:flutter_task_tracker_app/presentation/task/widgets/task_card.dart';
import 'package:flutter_task_tracker_app/presentation/task/pages/add_task_page.dart';
import 'package:flutter_task_tracker_app/presentation/task/pages/task_detail_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String? _selectedFilter;
  final ScrollController _scrollController = ScrollController();
  bool _isOnline = true;
  StreamSubscription<bool>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _setupScrollListener();
    _setupConnectivityListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<TaskBloc>().add(const GetNextPage());
      }
    });
  }

  void _setupConnectivityListener() {
    final connectivity = context.read<ConnectivityService>();
    _connectivitySub = connectivity.onConnectivityChanged.listen((online) {
      if (mounted) {
        setState(() => _isOnline = online);
        if (online) _loadTasks(); // refresh saat kembali online
      }
    });
  }

  void _loadTasks() {
    context.read<TaskBloc>().add(GetTasks(status: _selectedFilter));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Task Tracker',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ConnectivityIndicator(isOnline: _isOnline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskPage()),
          );
          if (result == true) {
            _loadTasks();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Task'),
      ),
      body: Column(
        children: [
          /// Offline banner
          if (!_isOnline) const OfflineBanner(),

          /// Cache info banner
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TasksLoaded && state.isFromCache) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  color: AppColors.primary.withAlpha(20),
                  child: const Row(
                    children: [
                      Icon(Icons.cached, size: 16.0, color: AppColors.primary),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Menampilkan data dari cache',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          /// Filter chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: AppColors.white,
            child: Row(
              children: [
                _buildFilterChip('Semua', null),
                const SizedBox(width: 8.0),
                _buildFilterChip('Pending', 'pending'),
                const SizedBox(width: 8.0),
                _buildFilterChip('Done', 'completed'),
              ],
            ),
          ),

          /// Task list
          Expanded(
            child: BlocConsumer<TaskBloc, TaskState>(
              listener: (context, state) {
                if (state is TaskUpdated ||
                    state is TaskCreated ||
                    state is TaskDeleted) {
                  _loadTasks();
                }
              },
              builder: (context, state) {
                if (state is TaskLoading) {
                  return LoadingIndicator(message: state.message);
                }
                if (state is TasksLoaded) {
                  final tasks = state.tasks;
                  if (tasks.isEmpty) {
                    return const EmptyState(
                      message:
                          'Belum ada task.\nTekan tombol + untuk menambah!',
                      icon: Icons.task_alt,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _loadTasks(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 88.0,
                      ),
                      itemCount: tasks.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        /// Loading indicator di akhir list untuk pagination
                        if (index >= tasks.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        }

                        final task = tasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TaskDetailPage(taskId: task.id),
                              ),
                            );
                            if (result == true) {
                              _loadTasks();
                            }
                          },
                          onToggleStatus: () {
                            final newStatus = task.status == 'completed'
                                ? 'pending'
                                : 'completed';
                            context.read<TaskBloc>().add(
                                  UpdateTaskStatus(
                                    id: task.id,
                                    status: newStatus,
                                  ),
                                );
                          },
                          onDelete: () => _confirmDelete(task.id),
                        );
                      },
                    ),
                  );
                }
                if (state is TaskError) {
                  return ErrorMessage(
                    message: state.message,
                    onRetry: _loadTasks,
                  );
                }
                return const LoadingIndicator(message: 'Memuat...');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? filterValue) {
    final isSelected = _selectedFilter == filterValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? filterValue : null;
        });
        _loadTasks();
      },
      selectedColor: AppColors.primary.withAlpha(30),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  void _confirmDelete(int taskId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Task'),
        content: const Text('Apakah Anda yakin ingin menghapus task ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TaskBloc>().add(DeleteTask(taskId));
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
