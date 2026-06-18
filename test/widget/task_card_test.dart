import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_task_tracker_app/core/constants/colors.dart';
import 'package:flutter_task_tracker_app/data/models/task_model.dart';
import 'package:flutter_task_tracker_app/presentation/task/widgets/task_card.dart';

void main() {
  final pendingTask = TaskModel(
    id: 1,
    title: 'Belajar Flutter Bloc',
    description: 'Mempelajari state management dengan Bloc pattern',
    status: 'pending',
    createdAt: DateTime(2026, 6, 19),
    updatedAt: DateTime(2026, 6, 19),
  );

  final completedTask = TaskModel(
    id: 2,
    title: 'Setup Project',
    description: 'Inisialisasi struktur project Flutter',
    status: 'completed',
  );

  group('TaskCard Widget', () {
    testWidgets('renders task title and status label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(task: pendingTask),
          ),
        ),
      );

      expect(find.text('Belajar Flutter Bloc'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('renders short description', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(task: pendingTask),
          ),
        ),
      );

      expect(find.text('Mempelajari state management dengan Bloc pattern'),
          findsOneWidget);
    });

    testWidgets('shows "Done" label for completed task', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(task: completedTask),
          ),
        ),
      );

      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('completed task title has line-through', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(task: completedTask),
          ),
        ),
      );

      final titleWidget = tester.widget<Text>(
        find.text('Setup Project'),
      );
      expect(titleWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('triggers onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: pendingTask,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Belajar Flutter Bloc'));
      expect(tapped, true);
    });

    testWidgets('triggers onToggleStatus callback', (tester) async {
      bool toggled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: pendingTask,
              onToggleStatus: () => toggled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.check_circle_outline));
      expect(toggled, true);
    });

    testWidgets('triggers onDelete callback', (tester) async {
      bool deleted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: pendingTask,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, true);
    });

    testWidgets('uses correct status colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TaskCard(task: pendingTask),
                TaskCard(task: completedTask),
              ],
            ),
          ),
        ),
      );

      // Pending label should be orange
      final pendingLabel = tester.widget<Text>(find.text('Pending'));
      expect(pendingLabel.style?.color, AppColors.pending);

      // Done label should be green
      final doneLabel = tester.widget<Text>(find.text('Done'));
      expect(doneLabel.style?.color, AppColors.done);
    });
  });
}
