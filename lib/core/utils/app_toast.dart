import 'package:flutter/material.dart';
import '../../main.dart';

/// Centralized utility for showing consistent, styled floating toast notifications
/// across the application for both success and error outcomes.
class AppToast {
  AppToast._();

  static void showSuccess(BuildContext? context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF15803D), // Forest green
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showError(BuildContext? context, String message) {
    final cleanMessage = message
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiException: ', '');
    _show(
      context: context,
      message: cleanMessage,
      backgroundColor: const Color(0xFFDC2626), // Error red
      icon: Icons.error_outline_rounded,
      duration: const Duration(seconds: 4),
    );
  }

  static void showInfo(BuildContext? context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF1D4ED8), // Blue
      icon: Icons.info_outline_rounded,
    );
  }

  static void _show({
    required BuildContext? context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    ScaffoldMessengerState? messenger;
    if (context != null && context.mounted) {
      messenger = ScaffoldMessenger.maybeOf(context);
    }
    messenger ??= appScaffoldMessengerKey.currentState;

    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(snackBar);
    }
  }
}
