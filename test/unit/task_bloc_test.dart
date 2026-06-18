import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_task_tracker_app/data/models/task_model.dart';
import 'package:flutter_task_tracker_app/data/repositories/task_repository.dart';
import 'package:flutter_task_tracker_app/presentation/task/blocs/task_bloc.dart';
import 'package:flutter_task_tracker_app/presentation/task/blocs/task_event.dart';
import 'package:flutter_task_tracker_app/presentation/task/blocs/task_state.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late TaskBloc bloc;
  late MockTaskRepository mockRepository;

  final testTasks = [
    TaskModel(id: 1, title: 'Task 1', status: 'pending'),
    TaskModel(id: 2, title: 'Task 2', status: 'completed'),
  ];

  setUp(() {
    mockRepository = MockTaskRepository();
    bloc = TaskBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('TaskBloc - Initial', () {
    test('initial state is TaskInitial', () {
      expect(bloc.state, isA<TaskInitial>());
    });
  });

  group('TaskBloc - GetTasks', () {
    test('emits TasksLoaded on success', () async {
      when(() => mockRepository.getTasks(
            status: any(named: 'status'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => Right(
                TaskListResponseModel(
                  success: true,
                  message: 'OK',
                  data: testTasks,
                ),
              ));

      final states = <TaskState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetTasks());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<TaskLoading>());
      expect(states[1], isA<TasksLoaded>());
      expect((states[1] as TasksLoaded).tasks.length, 2);

      await sub.cancel();
    });

    test('emits TaskError on failure', () async {
      when(() => mockRepository.getTasks(
            status: any(named: 'status'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => const Left('Network error'));

      final states = <TaskState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetTasks());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<TaskLoading>());
      expect(states[1], isA<TaskError>());
      expect((states[1] as TaskError).message, 'Network error');

      await sub.cancel();
    });
  });

  group('TaskBloc - GetTaskDetail', () {
    test('emits TaskDetailLoaded on success', () async {
      when(() => mockRepository.getTaskById(1)).thenAnswer(
        (_) async => Right(
          TaskDetailResponseModel(
            success: true,
            message: 'OK',
            data: testTasks[0],
          ),
        ),
      );

      final states = <TaskState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const GetTaskDetail(1));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<TaskLoading>());
      expect(states[1], isA<TaskDetailLoaded>());
      expect((states[1] as TaskDetailLoaded).task.id, 1);

      await sub.cancel();
    });
  });

  group('TaskBloc - CreateTask', () {
    test('emits TaskCreated on success', () async {
      when(() => mockRepository.createTask(
            title: any(named: 'title'),
            description: any(named: 'description'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => Right(
                TaskDetailResponseModel(
                  success: true,
                  message: 'Created',
                  data: testTasks[0],
                ),
              ));

      final states = <TaskState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const CreateTask(title: 'New Task'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<TaskLoading>());
      expect(states[1], isA<TaskCreated>());

      await sub.cancel();
    });
  });

  group('TaskBloc - UpdateTaskStatus', () {
    test('emits TaskUpdated on success', () async {
      when(() => mockRepository.updateTask(
            id: any(named: 'id'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => Right(
                TaskDetailResponseModel(
                  success: true,
                  message: 'Updated',
                  data: TaskModel(id: 1, title: 'Task 1', status: 'completed'),
                ),
              ));

      final states = <TaskState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const UpdateTaskStatus(id: 1, status: 'completed'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<TaskLoading>());
      expect(states[1], isA<TaskUpdated>());

      await sub.cancel();
    });
  });

  group('TaskBloc - DeleteTask', () {
    test('emits TaskDeleted on success', () async {
      when(() => mockRepository.deleteTask(1)).thenAnswer(
        (_) async => Right(
          TaskMessageResponseModel(
            success: true,
            message: 'Task berhasil dihapus',
          ),
        ),
      );

      final states = <TaskState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DeleteTask(1));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<TaskLoading>());
      expect(states[1], isA<TaskDeleted>());

      await sub.cancel();
    });
  });

  group('TaskBloc - ResetTaskForm', () {
    test('emits TaskFormReset', () async {
      final states = <TaskState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ResetTaskForm());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states.length, 1);
      expect(states[0], isA<TaskFormReset>());

      await sub.cancel();
    });
  });
}
