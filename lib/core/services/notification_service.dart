import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NotificationService {
  NotificationService._();

  static Future<void> playNotificationChime() async {
    try {
      if (!kIsWeb) {
        // Haptic feedback on physical mobile platforms
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.alert);
      }
    } catch (_) {
      // Ignored if sound is restricted by browser or platform
    }
  }
}
