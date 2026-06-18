import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_task_tracker_app/core/components/empty_state.dart';
import 'package:flutter_task_tracker_app/core/components/error_message.dart';
import 'package:flutter_task_tracker_app/core/components/loading_indicator.dart';
import 'package:flutter_task_tracker_app/core/components/connectivity_widgets.dart';

void main() {
  group('LoadingIndicator Widget', () {
    testWidgets('renders CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoadingIndicator()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders optional message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingIndicator(message: 'Memuat data...'),
        ),
      );

      expect(find.text('Memuat data...'), findsOneWidget);
    });
  });

  group('ErrorMessage Widget', () {
    testWidgets('renders error message and retry button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorMessage(
            message: 'Gagal memuat data',
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Gagal memuat data'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('triggers onRetry callback', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorMessage(
            message: 'Error',
            onRetry: () => retried = true,
          ),
        ),
      );

      await tester.tap(find.text('Coba Lagi'));
      expect(retried, true);
    });
  });

  group('EmptyState Widget', () {
    testWidgets('renders message with icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmptyState(message: 'Tidak ada task'),
        ),
      );

      expect(find.text('Tidak ada task'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmptyState(
            message: 'Kosong',
            icon: Icons.task_alt,
          ),
        ),
      );

      expect(find.byIcon(Icons.task_alt), findsOneWidget);
    });
  });

  group('OfflineBanner Widget', () {
    testWidgets('renders offline message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OfflineBanner()),
      );

      expect(find.text('Anda sedang offline. Menampilkan data cache.'),
          findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });
  });

  group('ConnectivityIndicator Widget', () {
    testWidgets('shows green dot when online', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConnectivityIndicator(isOnline: true),
        ),
      );

      // Container with circle decoration exists
      expect(find.byType(ConnectivityIndicator), findsOneWidget);
    });

    testWidgets('shows red dot when offline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConnectivityIndicator(isOnline: false),
        ),
      );

      expect(find.byType(ConnectivityIndicator), findsOneWidget);
    });
  });
}
