import 'package:flutter/material.dart';

enum NotificationType {
  success,
  error,
  info,
  warning,
}

class NotificationBanner {
  static void show(BuildContext context, String message, NotificationType type) {
    final color = type == NotificationType.success
        ? Colors.green
        : type == NotificationType.error
            ? Colors.red
            : type == NotificationType.warning
                ? Colors.orange
                : Colors.blue;

    final icon = type == NotificationType.success
        ? Icons.check_circle
        : type == NotificationType.error
            ? Icons.error
            : type == NotificationType.warning
                ? Icons.warning
                : Icons.info;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
