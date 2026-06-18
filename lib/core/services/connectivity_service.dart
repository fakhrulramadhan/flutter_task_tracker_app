import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Service untuk memantau status koneksi internet.
/// Menggunakan connectivity_plus untuk mendeteksi perubahan koneksi.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  /// Stream yang mengirim `true` jika online, `false` jika offline
  Stream<bool> get onConnectivityChanged => _controller.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((results) {
      final isOnline = results.any((result) => result != ConnectivityResult.none);
      _controller.add(isOnline);
    });
  }

  /// Cek status koneksi saat ini
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  void dispose() {
    _controller.close();
  }
}
