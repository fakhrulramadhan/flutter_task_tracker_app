import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task_tracker_app/data/repositories/task_repository.dart';
import 'package:flutter_task_tracker_app/presentation/task/blocs/task_event.dart';
import 'package:flutter_task_tracker_app/presentation/task/blocs/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  static const int _perPage = 10;

  /// Menyimpan filter yang sedang aktif untuk pagination
  String? _activeFilter;

  TaskBloc(this.repository) : super(const TaskInitial()) {
    /// GET tasks (initial load / refresh)
    on<GetTasks>((event, emit) async {
      _activeFilter = event.status;
      emit(const TaskLoading(message: 'Memuat daftar task...'));
      final result = await repository.getTasks(
        status: event.status,
        page: 1,
        perPage: _perPage,
      );

      result.fold(
        (error) => emit(TaskError(error)),
        (response) {
          final isCache = response.message.contains('cache');
          emit(TasksLoaded(
            response.data,
            hasReachedMax: response.data.length < _perPage,
            currentPage: 1,
            isFromCache: isCache,
          ));
        },
      );
    });

    /// GET next page (infinite scroll)
    on<GetNextPage>((event, emit) async {
      final currentState = state;
      if (currentState is! TasksLoaded || currentState.hasReachedMax) return;

      final nextPage = currentState.currentPage + 1;
      final result = await repository.getTasks(
        status: _activeFilter,
        page: nextPage,
        perPage: _perPage,
      );

      result.fold(
        (error) {
          // Jangan replace seluruh state jika pagination error
          // Biarkan data existing tetap tampil
        },
        (response) {
          final allTasks = [...currentState.tasks, ...response.data];
          emit(currentState.copyWith(
            tasks: allTasks,
            hasReachedMax: response.data.length < _perPage,
            currentPage: nextPage,
          ));
        },
      );
    });

    /// GET detail task
    on<GetTaskDetail>((event, emit) async {
      emit(const TaskLoading(message: 'Memuat detail task...'));
      final result = await repository.getTaskById(event.id);

      result.fold(
        (error) => emit(TaskError(error)),
        (response) {
          if (response.data != null) {
            emit(TaskDetailLoaded(response.data!));
          } else {
            emit(const TaskError('Task tidak ditemukan'));
          }
        },
      );
    });

    /// POST create task
    on<CreateTask>((event, emit) async {
      emit(const TaskLoading(message: 'Membuat task...'));
      final result = await repository.createTask(
        title: event.title,
        description: event.description,
        status: event.status,
      );

      result.fold(
        (error) => emit(TaskError(error)),
        (response) {
          if (response.data != null) {
            emit(TaskCreated(response.data!));
          } else {
            emit(const TaskError('Gagal membuat task'));
          }
        },
      );
    });

    /// PATCH update status
    on<UpdateTaskStatus>((event, emit) async {
      emit(const TaskLoading(message: 'Memperbarui status...'));
      final result = await repository.updateTask(
        id: event.id,
        status: event.status,
      );

      result.fold(
        (error) => emit(TaskError(error)),
        (response) {
          if (response.data != null) {
            emit(TaskUpdated(response.data!));
          } else {
            emit(const TaskError('Gagal memperbarui status'));
          }
        },
      );
    });

    /// PUT update full task
    on<UpdateFullTask>((event, emit) async {
      emit(const TaskLoading(message: 'Memperbarui task...'));
      final result = await repository.updateFullTask(
        id: event.id,
        title: event.title,
        description: event.description,
        status: event.status,
      );

      result.fold(
        (error) => emit(TaskError(error)),
        (response) {
          if (response.data != null) {
            emit(TaskUpdated(response.data!));
          } else {
            emit(const TaskError('Gagal memperbarui task'));
          }
        },
      );
    });

    /// DELETE task
    on<DeleteTask>((event, emit) async {
      emit(const TaskLoading(message: 'Menghapus task...'));
      final result = await repository.deleteTask(event.id);

      result.fold(
        (error) => emit(TaskError(error)),
        (response) => emit(TaskDeleted(response.message)),
      );
    });

    /// Reset form
    on<ResetTaskForm>((event, emit) {
      emit(const TaskFormReset());
    });
  }
}
