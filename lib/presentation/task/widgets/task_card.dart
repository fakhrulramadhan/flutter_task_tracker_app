import 'package:flutter/material.dart';
import 'package:flutter_task_tracker_app/core/constants/colors.dart';
import 'package:flutter_task_tracker_app/data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == 'completed';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Status indicator
              Container(
                margin: const EdgeInsets.only(top: 2.0),
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? AppColors.done : AppColors.pending,
                ),
              ),
              const SizedBox(width: 12.0),

              /// Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        decoration:
                            isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      task.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.done.withAlpha(30)
                            : AppColors.pending.withAlpha(30),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        task.statusLabel,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: isDone ? AppColors.done : AppColors.pending,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Toggle status button
                  IconButton(
                    onPressed: onToggleStatus,
                    icon: Icon(
                      isDone
                          ? Icons.undo_outlined
                          : Icons.check_circle_outline,
                      color: isDone ? AppColors.pending : AppColors.done,
                    ),
                    tooltip: isDone
                        ? 'Tandai Pending'
                        : 'Tandai Done',
                    iconSize: 22.0,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  const SizedBox(height: 4.0),

                  /// Delete button
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    tooltip: 'Hapus Task',
                    iconSize: 20.0,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
