import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_item.dart';
import '../../../core/models/user_profile.dart';
import '../../../state/app_state.dart';
import '../../../state/auth_notifier.dart';
import '../widgets/course_card.dart';
import '../widgets/schedule_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final auth = context.watch<AuthNotifier>();
    final user = state.currentUser;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isMobile = KiteBreak.isMobile(context);

    final schoolName = auth.tenantId == 'tenant-lincoln-high-001'
        ? 'Lincoln High School'
        : auth.tenantId == 'tenant-sma1-ilmiya-002'
            ? 'SMA Negeri 1 Ilmiya'
            : auth.tenantId;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? KiteSpace.sm : KiteSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Welcome & School Header Bar
          _buildHeaderBanner(context, user, schoolName, state),

          const SizedBox(height: KiteSpace.xl),

          // 2. Kite KPI Stat Grid
          _buildKpiStatGrid(context, state),

          const SizedBox(height: KiteSpace.xl),

          // 3. Main Content: Courses (Left) & Timetable / Live Stream (Right)
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _buildCoursesSection(context, state),
                ),
                const SizedBox(width: KiteSpace.xl),
                Expanded(
                  flex: 5,
                  child: _buildSideSection(context, state),
                ),
              ],
            )
          else ...[
            _buildCoursesSection(context, state),
            const SizedBox(height: KiteSpace.xl),
            _buildSideSection(context, state),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderBanner(
    BuildContext context,
    UserProfile user,
    String schoolName,
    AppState state,
  ) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 500
          ? KiteSpace.md
          : KiteSpace.xl),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262925) : Colors.white,
        borderRadius: KiteRadius.allLg,
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final isMobile = constraints.maxWidth < 500;

          final textContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: KiteSpace.sm,
                runSpacing: KiteSpace.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const KiteBadge('2025/2026 Term 2 Active',
                      tone: KiteTone.success),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.muted,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.shieldCheck,
                            size: 12, color: AppColors.forestSage),
                        const SizedBox(width: 4),
                        Text(
                          'FERPA & RBAC Verified',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KiteSpace.sm),
              Text(
                'Welcome back, ${user.name}',
                style: (isMobile ? t.h4 : t.h3).copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$schoolName • Administrative Portal & Student Information Control',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.muted.copyWith(fontSize: isMobile ? 11 : 13),
              ),
            ],
          );

          final actions = Wrap(
            spacing: KiteSpace.sm,
            runSpacing: KiteSpace.sm,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: c.border),
                ),
                icon: const Icon(LucideIcons.calendar, size: 15),
                label: const Text('Academic Terms',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                onPressed: () => state.setTab(1),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: c.border),
                ),
                icon: const Icon(LucideIcons.graduationCap, size: 15),
                label: const Text('Gradebook',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                onPressed: () => state.setTab(5),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(LucideIcons.userPlus, size: 15),
                label: const Text('IAM Console',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                onPressed: () => state.setTab(2),
              ),
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: textContent),
                const SizedBox(width: KiteSpace.md),
                actions,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textContent,
              const SizedBox(height: KiteSpace.md),
              actions,
            ],
          );
        },
      ),
    );
  }

  Widget _buildKpiStatGrid(BuildContext context, AppState state) {
    final gpa = state.cumulativeGpa;

    return KiteStatGrid(
      height: 155,
      minTileWidth: 200,
      children: [
        const KiteStat(
          label: 'Total Enrolled Students',
          value: '1,248',
          delta: '+4.2% vs prior term',
          deltaTone: KiteTone.success,
          padding: EdgeInsets.all(KiteSpace.lg),
        ),
        const KiteStat(
          label: 'Active Faculty & Staff',
          value: '94',
          delta: '100% active IAM access',
          deltaTone: KiteTone.info,
          padding: EdgeInsets.all(KiteSpace.lg),
        ),
        const KiteStat(
          label: 'Daily Attendance Rate',
          value: '96.4%',
          delta: '+1.1% above target',
          deltaTone: KiteTone.success,
          padding: EdgeInsets.all(KiteSpace.lg),
        ),
        KiteStat(
          label: 'Cumulative GPA',
          value: gpa['unweighted'] ?? '3.88',
          delta: 'Weighted honors: ${gpa['weighted'] ?? '4.12'}',
          deltaTone: KiteTone.info,
          padding: const EdgeInsets.all(KiteSpace.lg),
        ),
      ],
    );
  }

  Widget _buildCoursesSection(BuildContext context, AppState state) {
    final t = KiteText.of(context);
    final isMobile = KiteBreak.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.bookOpen,
                    size: 18, color: AppColors.forestSage),
                const SizedBox(width: KiteSpace.sm),
                Flexible(
                  child: Text('Active Academic Courses',
                      overflow: TextOverflow.ellipsis,
                      style: isMobile ? t.h4.copyWith(fontSize: 16) : t.h4),
                ),
              ],
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onPressed: () => state.setTab(5),
              icon: const Icon(LucideIcons.arrowUpRight,
                  size: 14, color: AppColors.forestSage),
              label: const Text(
                'Full Coursework & Grades',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forestSage,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: KiteSpace.md),

        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth > 550 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                crossAxisSpacing: KiteSpace.md,
                mainAxisSpacing: KiteSpace.md,
                childAspectRatio: count == 1 ? 2.3 : 1.7,
              ),
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                return CourseCard(course: state.courses[index]);
              },
            );
          },
        ),

        const SizedBox(height: KiteSpace.lg),

        // Upcoming Submission Alert Card
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 500;
            return Container(
              padding: const EdgeInsets.all(KiteSpace.lg),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3).withOpacity(0.5),
                borderRadius: KiteRadius.allLg,
                border: Border.all(color: const Color(0xFFFDE047)),
              ),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF08A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(LucideIcons.clock,
                                  color: Color(0xFF854D0E), size: 18),
                            ),
                            const SizedBox(width: KiteSpace.md),
                            const Expanded(
                              child: Text(
                                'UPCOMING SUBMISSION PENDING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF854D0E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Final Term Capstone: Distributed State Machine (CS-301) • Due Friday',
                          style: t.small.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.forestSage,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                          ),
                          onPressed: () => state.setTab(5),
                          child: const Text('View Rubric',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF08A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.clock,
                              color: Color(0xFF854D0E), size: 18),
                        ),
                        const SizedBox(width: KiteSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'UPCOMING SUBMISSION PENDING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF854D0E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Final Term Capstone: Distributed State Machine (CS-301) • Due Friday',
                                style: t.small
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: KiteSpace.md),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.forestSage,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: () => state.setTab(5),
                          child: const Text('View Rubric',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSideSection(BuildContext context, AppState state) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    final isMobile = KiteBreak.isMobile(context);

    return Column(
      children: [
        // 1. Weekly Schedule & Timetable
        const ScheduleWidget(),

        const SizedBox(height: KiteSpace.xl),

        // 2. Kite-styled Live Stream Feed Card
        KiteCard(
          padding: EdgeInsets.all(isMobile ? KiteSpace.md : KiteSpace.xl),
          title: 'Live Activity & Notifications',
          trailing: InkWell(
            onTap: () => state.simulateNotification('grade'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.sparkles,
                    size: 12, color: AppColors.earthyTerra),
                const SizedBox(width: 4),
                Text(
                  'Simulate',
                  style: t.small.copyWith(
                    color: AppColors.forestSage,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.notifications.take(3).length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: KiteSpace.sm),
                itemBuilder: (context, index) {
                  final notif = state.notifications[index];
                  final isMsg = notif.category == NotificationCategory.message;

                  return InkWell(
                    borderRadius: KiteRadius.allMd,
                    onTap: () => state.setTab(isMsg ? 6 : 7),
                    child: Container(
                      padding: const EdgeInsets.all(KiteSpace.md),
                      decoration: BoxDecoration(
                        color: notif.read
                            ? c.background
                            : c.muted.withOpacity(0.5),
                        borderRadius: KiteRadius.allMd,
                        border: Border.all(color: c.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: t.small
                                      .copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                notif.timestamp,
                                style: t.muted.copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: t.muted.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: KiteSpace.sm),
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  onPressed: () => state.setTab(7),
                  icon: const Icon(LucideIcons.arrowRight, size: 14),
                  label: const Text('View All Notifications',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
