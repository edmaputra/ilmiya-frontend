import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FlutterCliGuideView extends StatelessWidget {
  const FlutterCliGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CLI Setup & Multiplatform Build Instructions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 16),
          _CliStep(
            title: '1. Install Dependencies',
            cmd: 'flutter pub get',
          ),
          SizedBox(height: 12),
          _CliStep(
            title: '2. Run in Development',
            cmd:
                'flutter run -d web-server --web-port=8080  # Run on Generic Web Server\nflutter run -d chrome                     # Run on Chrome\nflutter run -d linux                      # Run on Linux Desktop\nflutter run -d ios                        # Run on iOS\nflutter run -d android                    # Run on Android',
          ),
          SizedBox(height: 12),
          _CliStep(
            title: '3. Build Production Releases',
            cmd:
                'flutter build web --release\nflutter build linux --release\nflutter build appbundle --release\nflutter build ipa --release',
          ),
        ],
      ),
    );
  }
}

class _CliStep extends StatelessWidget {
  final String title;
  final String cmd;

  const _CliStep({
    required this.title,
    required this.cmd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.naturalParchment,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF242724),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(
              cmd,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.softKhaki,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
