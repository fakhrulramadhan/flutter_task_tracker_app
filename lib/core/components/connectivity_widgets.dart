import 'package:flutter/material.dart';
import 'package:flutter_task_tracker_app/core/constants/colors.dart';

/// Banner yang muncul ketika aplikasi offline.
/// Menampilkan pesan informatif di bagian atas layar.
class OfflineBanner extends StatelessWidget {
  final String? message;

  const OfflineBanner({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: AppColors.pending,
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.white,
            size: 18.0,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              message ?? 'Anda sedang offline. Menampilkan data cache.',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indikator status koneksi kecil di AppBar
class ConnectivityIndicator extends StatelessWidget {
  final bool isOnline;

  const ConnectivityIndicator({
    super.key,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? AppColors.done : AppColors.error,
      ),
    );
  }
}
