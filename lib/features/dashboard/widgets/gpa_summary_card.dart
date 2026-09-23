import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state.dart';

class MetricsRow extends StatelessWidget {
  const MetricsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final gpa = state.cumulativeGpa;

    final avgPercentage =
        (state.courses.fold<double>(0, (sum, c) => sum + c.currentPercentage) /
                (state.courses.isNotEmpty ? state.courses.length : 1))
            .toStringAsFixed(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 500
                ? 2
                : 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: crossAxisCount == 1 ? 2.3 : 1.45,
          children: [
            // 1. Cumulative GPA
            _buildMetricCard(
              title: 'CUMULATIVE GPA',
              mainValue: gpa['unweighted'] ?? '3.88',
              unit: '/ 4.0 Unweighted',
              icon: Icons.emoji_events_outlined,
              iconBg: AppColors.warmSand,
              iconColor: AppColors.forestSage,
              bottomLeft: 'Weighted: ${gpa['weighted'] ?? '4.12'}',
              bottomRight: user.gpa?.classRank ?? 'Top 4%',
              bottomRightIcon: Icons.trending_up,
            ),

            // 2. Course Average
            _buildMetricCard(
              title: 'COURSE AVERAGE',
              mainValue: '$avgPercentage%',
              unit: 'Grade A Avg',
              unitColor: AppColors.forestSage,
              icon: Icons.trending_up,
              iconBg: AppColors.borderLight,
              iconColor: AppColors.forestSage,
              bottomLeft: '${state.courses.length} Active Courses',
              bottomRight: '21.0 Credits',
            ),

            // 3. Attendance Rate
            _buildMetricCard(
              title: 'ATTENDANCE RATE',
              mainValue: '98.5%',
              unit: 'Exemplary',
              unitColor: AppColors.forestSage,
              icon: Icons.check_circle_outline,
              iconBg: AppColors.warmSand,
              iconColor: AppColors.forestSage,
              bottomLeft: '100% Present this week',
              bottomRight: '0 Unexcused',
            ),

            // 4. Real-time Hub
            _buildMetricCard(
              title: 'REAL-TIME HUB',
              mainValue: '${state.unreadNotifsCount}',
              unit: 'Unread Alerts',
              unitColor: AppColors.earthyTerra,
              icon: Icons.bolt,
              iconBg: AppColors.surfaceMuted,
              iconColor: AppColors.earthyTerra,
              bottomLeft: 'View alerts →',
              bottomLeftAction: () => state.setTab(3),
              bottomRight: 'WebSocket Live',
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String mainValue,
    required String unit,
    Color? unitColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String bottomLeft,
    VoidCallback? bottomLeftAction,
    required String bottomRight,
    IconData? bottomRightIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                mainValue,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: unitColor ?? AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: bottomLeftAction != null
                      ? InkWell(
                          onTap: bottomLeftAction,
                          child: Text(
                            bottomLeft,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.forestSage,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : Text(
                          bottomLeft,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (bottomRightIcon != null) ...[
                      Icon(bottomRightIcon,
                          size: 12, color: AppColors.forestSage),
                      const SizedBox(width: 3),
                    ],
                    Text(
                      bottomRight,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestSage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
