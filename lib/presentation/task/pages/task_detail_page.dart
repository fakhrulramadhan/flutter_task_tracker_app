import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task_tracker_app/core/constants/colors.dart';
import 'package:flutter_task_tracker_app/core/components/loading_indicator.dart';
import 'package:flutter_task_tracker_app/core/components/error_message.dart';
import 'package:flutter_task_tracker_app/presentation/task/blocs/task_bloc.dart';
import 'package:flutter_task_tracker_app/presentation/task/blocs/task_event.dart';
import 'package:flutter_task_tracker_app/presentation/task/blocs/task_state.dart';

class TaskDetailPage extends StatefulWidget {
  final int taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(GetTaskDetail(widget.taskId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Detail Task',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Status task berhasil diupdate!'),
                backgroundColor: AppColors.done,
              ),
            );
            context.read<TaskBloc>().add(GetTaskDetail(widget.taskId));
          }
          if (state is TaskDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.done,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return LoadingIndicator(message: state.message);
          }
          if (state is TaskDetailLoaded) {
            return _buildDetailContent(state.task);
          }
          if (state is TaskError) {
            return ErrorMessage(
              message: state.message,
              onRetry: () {
                context.read<TaskBloc>().add(GetTaskDetail(widget.taskId));
              },
            );
          }
          return const LoadingIndicator(message: 'Memuat...');
        },
      ),
    );
  }

  Widget _buildDetailContent(task) {
    final isDone = task.status == 'completed';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// Status card
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  /// Status badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppColors.done.withAlpha(30)
                              : AppColors.pending.withAlpha(30),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDone
                                  ? Icons.check_circle
                                  : Icons.schedule,
                              color: isDone ? AppColors.done : AppColors.pending,
                              size: 18.0,
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              task.statusLabel,
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: isDone
                                    ? AppColors.done
                                    : AppColors.pending,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12.0),

          /// Description card
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    task.description != null && task.description!.isNotEmpty
                        ? task.description!
                        : 'Tidak ada deskripsi',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: task.description != null &&
                              task.description!.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12.0),

          /// Timestamps card
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Waktu',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  _buildTimeRow(
                    icon: Icons.calendar_today,
                    label: 'Dibuat',
                    value: task.createdAt != null
                        ? _formatDateTime(task.createdAt!)
                        : '-',
                  ),
                  const SizedBox(height: 8.0),
                  _buildTimeRow(
                    icon: Icons.update,
                    label: 'Diupdate',
                    value: task.updatedAt != null
                        ? _formatDateTime(task.updatedAt!)
                        : '-',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24.0),

          /// Toggle status button
          SizedBox(
            height: 50.0,
            child: ElevatedButton.icon(
              onPressed: () {
                final newStatus =
                    task.status == 'completed' ? 'pending' : 'completed';
                context.read<TaskBloc>().add(
                      UpdateTaskStatus(
                        id: task.id,
                        status: newStatus,
                      ),
                    );
              },
              icon: Icon(
                isDone ? Icons.undo : Icons.check_circle,
              ),
              label: Text(
                isDone ? 'Tandai Pending' : 'Tandai Done',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? AppColors.pending : AppColors.done,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2.0,
              ),
            ),
          ),

          const SizedBox(height: 12.0),

          /// Delete button
          SizedBox(
            height: 50.0,
            child: OutlinedButton.icon(
              onPressed: () => _confirmDelete(task.id),
              icon: const Icon(Icons.delete_outline),
              label: const Text(
                'Hapus Task',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: AppColors.textSecondary),
        const SizedBox(width: 8.0),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14.0,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
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
