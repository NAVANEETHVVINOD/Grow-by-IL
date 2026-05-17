import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class ToastMessage {
  final String title;
  final String message;
  final Color color;
  final IconData icon;

  ToastMessage({
    required this.title,
    required this.message,
    this.color = const Color(0xFF1A1A2E), // AppColors.navy
    this.icon = Icons.notifications_rounded,
  });
}

class ToastNotifier extends StateNotifier<ToastMessage?> {
  ToastNotifier() : super(null);

  void show({
    required String title,
    required String message,
    Color color = const Color(0xFF1A1A2E),
    IconData icon = Icons.notifications_rounded,
  }) {
    state = ToastMessage(
      title: title,
      message: message,
      color: color,
      icon: icon,
    );

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (state?.title == title) {
        state = null;
      }
    });
  }

  void dismiss() {
    state = null;
  }
}

final toastProvider =
    StateNotifierProvider<ToastNotifier, ToastMessage?>((ref) {
  return ToastNotifier();
});
