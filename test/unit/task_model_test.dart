import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_task_tracker_app/data/models/task_model.dart';

void main() {
  group('TaskModel', () {
    final sampleJson = {
      'id': 1,
      'title': 'Belajar Flutter',
      'description': 'Mempelajari state management Bloc',
      'status': 'pending',
      'created_at': '2026-06-19T10:00:00.000000Z',
      'updated_at': '2026-06-19T10:00:00.000000Z',
    };

    test('fromJson creates valid TaskModel', () {
      final task = TaskModel.fromJson(sampleJson);

      expect(task.id, 1);
      expect(task.title, 'Belajar Flutter');
      expect(task.description, 'Mempelajari state management Bloc');
      expect(task.status, 'pending');
      expect(task.createdAt, isNotNull);
      expect(task.updatedAt, isNotNull);
    });

    test('toJson returns correct map', () {
      final task = TaskModel.fromJson(sampleJson);
      final json = task.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Belajar Flutter');
      expect(json['status'], 'pending');
    });

    test('statusLabel returns "Done" for completed', () {
      final task = TaskModel.fromJson({...sampleJson, 'status': 'completed'});
      expect(task.statusLabel, 'Done');
    });

    test('statusLabel returns "Pending" for pending', () {
      final task = TaskModel.fromJson(sampleJson);
      expect(task.statusLabel, 'Pending');
    });

    test('shortDescription truncates long text', () {
      final longDesc = 'A' * 100;
      final task = TaskModel.fromJson({
        ...sampleJson,
        'description': longDesc,
      });
      expect(task.shortDescription.length, 53); // 50 + "..."
      expect(task.shortDescription.endsWith('...'), isTrue);
    });

    test('shortDescription handles null description', () {
      final task = TaskModel.fromJson({
        'id': 1,
        'title': 'Test',
        'status': 'pending',
      });
      expect(task.shortDescription, 'Tidak ada deskripsi');
    });

    test('fromJson handles null dates gracefully', () {
      final task = TaskModel.fromJson({
        'id': 1,
        'title': 'Test',
        'status': 'pending',
      });
      expect(task.createdAt, isNull);
      expect(task.updatedAt, isNull);
    });
  });

  group('TaskListResponseModel', () {
    test('fromJson parses list of tasks', () {
      final json = {
        'success': true,
        'message': 'Daftar tasks berhasil diambil',
        'data': [
          {
            'id': 1,
            'title': 'Task 1',
            'status': 'pending',
          },
          {
            'id': 2,
            'title': 'Task 2',
            'status': 'completed',
          },
        ],
      };

      final response = TaskListResponseModel.fromJson(json);
      expect(response.success, true);
      expect(response.data.length, 2);
      expect(response.data[0].title, 'Task 1');
      expect(response.data[1].status, 'completed');
    });

    test('fromJson handles empty data', () {
      final json = {
        'success': true,
        'message': 'OK',
        'data': [],
      };
      final response = TaskListResponseModel.fromJson(json);
      expect(response.data, isEmpty);
    });
  });

  group('TaskDetailResponseModel', () {
    test('fromJson parses single task', () {
      final json = {
        'success': true,
        'message': 'Detail task',
        'data': {
          'id': 1,
          'title': 'Detail Task',
          'status': 'completed',
        },
      };

      final response = TaskDetailResponseModel.fromJson(json);
      expect(response.success, true);
      expect(response.data, isNotNull);
      expect(response.data!.id, 1);
      expect(response.data!.title, 'Detail Task');
    });
  });
}
