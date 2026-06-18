/// Event untuk TaskBloc
sealed class TaskEvent {
  const TaskEvent();
}

/// Mengambil tasks (initial load / refresh)
class GetTasks extends TaskEvent {
  final String? status;
  const GetTasks({this.status});
}

/// Load halaman berikutnya (infinite scroll)
class GetNextPage extends TaskEvent {
  const GetNextPage();
}

/// Mengambil detail satu task
class GetTaskDetail extends TaskEvent {
  final int id;
  const GetTaskDetail(this.id);
}

/// Membuat task baru
class CreateTask extends TaskEvent {
  final String title;
  final String? description;
  final String? status;
  const CreateTask({
    required this.title,
    this.description,
    this.status,
  });
}

/// Update status task (PATCH)
class UpdateTaskStatus extends TaskEvent {
  final int id;
  final String status;
  const UpdateTaskStatus({
    required this.id,
    required this.status,
  });
}

/// Update penuh task (PUT)
class UpdateFullTask extends TaskEvent {
  final int id;
  final String title;
  final String? description;
  final String status;
  const UpdateFullTask({
    required this.id,
    required this.title,
    this.description,
    required this.status,
  });
}

/// Menghapus task
class DeleteTask extends TaskEvent {
  final int id;
  const DeleteTask(this.id);
}

/// Reset state ke initial (untuk form)
class ResetTaskForm extends TaskEvent {
  const ResetTaskForm();
}
