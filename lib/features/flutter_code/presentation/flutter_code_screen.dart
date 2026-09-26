import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/flutter_architecture_view.dart';
import '../widgets/flutter_cli_guide_view.dart';
import '../widgets/flutter_source_code_view.dart';

class FlutterCodeScreen extends StatefulWidget {
  const FlutterCodeScreen({super.key});

  @override
  State<FlutterCodeScreen> createState() => _FlutterCodeScreenState();
}

class _FlutterCodeScreenState extends State<FlutterCodeScreen> {
  int _activeSubTab = 0; // 0: Source Code, 1: Architecture, 2: CLI Guide

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'FLUTTER 3.19+ CROSS-PLATFORM',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: AppColors.forestSage,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '• Clean Architecture',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Multiplatform Flutter Codebase & Architecture',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Production-ready Flutter & Dart source files targeting iOS, Android, Web, and Desktop',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sub-tab switcher
                    Row(
                      children: [
                        _buildSubTab(0, 'Source Code'),
                        const SizedBox(width: 6),
                        _buildSubTab(1, 'Architecture'),
                        const SizedBox(width: 6),
                        _buildSubTab(2, 'CLI Guide'),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Targets Indicator
                Row(
                  children: [
                    _buildTargetBadge(
                      Icons.phone_iphone,
                      'Apple iOS',
                      'Cupertino HIG, APNs Push',
                    ),
                    const SizedBox(width: 12),
                    _buildTargetBadge(
                      Icons.android,
                      'Google Android',
                      'Material 3, Firebase FCM',
                    ),
                    const SizedBox(width: 12),
                    _buildTargetBadge(
                      Icons.language,
                      'Flutter Web',
                      'CanvasKit, Responsive Grid',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sub-Tab Content
          if (_activeSubTab == 0)
            const FlutterSourceCodeView()
          else if (_activeSubTab == 1)
            const FlutterArchitectureView()
          else
            const FlutterCliGuideView(),
        ],
      ),
    );
  }

  Widget _buildSubTab(int index, String label) {
    final isActive = _activeSubTab == index;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isActive ? AppColors.forestSage : AppColors.borderLight,
        foregroundColor: isActive ? Colors.white : AppColors.textSecondary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => setState(() => _activeSubTab = index),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildTargetBadge(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.naturalParchment,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warmSand,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Icon(icon, size: 16, color: AppColors.forestSage),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
