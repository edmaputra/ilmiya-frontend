import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FlutterArchitectureView extends StatelessWidget {
  const FlutterArchitectureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clean Feature-First Flutter Architecture',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.2,
            children: const [
              _ArchCard(
                badge: '1. UI Presentation',
                title: 'Adaptive Widgets',
                desc:
                    'Cupertino widgets on iOS, Material 3 on Android, and responsive web flex layout.',
              ),
              _ArchCard(
                badge: '2. State Management',
                title: 'Provider / ChangeNotifier',
                desc:
                    'Compile-safe reactive state with automated lifecycle caching and notification streams.',
              ),
              _ArchCard(
                badge: '3. Real-Time Network',
                title: 'WebSocket + Push',
                desc:
                    'Full-duplex real-time events for instant teacher-student messaging & alerts.',
              ),
              _ArchCard(
                badge: '4. Security & E2EE',
                title: 'AES-256-GCM + FERPA',
                desc:
                    'Client-side cryptographic agreement verified for strict FERPA and COPPA compliance.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArchCard extends StatelessWidget {
  final String badge;
  final String title;
  final String desc;

  const _ArchCard({
    required this.badge,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.naturalParchment,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.warmSand,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.forestSage,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
