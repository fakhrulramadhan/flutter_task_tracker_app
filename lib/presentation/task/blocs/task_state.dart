import 'package:flutter_task_tracker_app/data/models/task_model.dart';

/// State untuk TaskBloc
sealed class TaskState {
  const TaskState();
}

/// Initial state
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// Loading state
class TaskLoading extends TaskState {
  final String? message;
  const TaskLoading({this.message});
}

/// Success - daftar tasks (dengan pagination info)
class TasksLoaded extends TaskState {
  final List<TaskModel> tasks;
  final bool hasReachedMax;
  final int currentPage;
  final bool isFromCache;

  const TasksLoaded(
    this.tasks, {
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isFromCache = false,
  });

  TasksLoaded copyWith({
    List<TaskModel>? tasks,
    bool? hasReachedMax,
    int? currentPage,
    bool? isFromCache,
  }) {
    return TasksLoaded(
      tasks ?? this.tasks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

/// Success - detail satu task
class TaskDetailLoaded extends TaskState {
  final TaskModel task;
  const TaskDetailLoaded(this.task);
}

/// Success - task berhasil dibuat
class TaskCreated extends TaskState {
  final TaskModel task;
  const TaskCreated(this.task);
}

/// Success - task berhasil diupdate
class TaskUpdated extends TaskState {
  final TaskModel task;
  const TaskUpdated(this.task);
}

/// Success - task berhasil dihapus
class TaskDeleted extends TaskState {
  final String message;
  const TaskDeleted(this.message);
}

/// Success - form direset
class TaskFormReset extends TaskState {
  const TaskFormReset();
}

/// Error state
class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
}
