import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/notification_item.dart';
import '../../../state/app_state.dart';
import '../widgets/gpa_summary_card.dart';
import '../widgets/course_card.dart';
import '../widgets/schedule_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Hero Banner
          _buildHeroBanner(context, user, state),

          const SizedBox(height: 20),

          // 2. Metrics Row
          const MetricsRow(),

          const SizedBox(height: 24),

          // 3. Split Content: Courses (Left) & Schedule/Feed (Right)
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _buildCoursesSection(context, state),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 4,
                  child: _buildSideSection(context, state),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildCoursesSection(context, state),
                const SizedBox(height: 24),
                _buildSideSection(context, state),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, UserProfile user, AppState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.forestSage,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.forestSageDark),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestSage.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: isWide ? 6 : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warmSand,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Text(
                            '${user.role.displayName} Portal',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: AppColors.forestSage,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Row(
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: AppColors.warmSand),
                            SizedBox(width: 4),
                            Text(
                              'FERPA Compliant • E2EE Active',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Welcome back, ${user.name}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRoleSubtitle(user),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              if (!isWide) const SizedBox(height: 18),

              // Action shortcuts
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warmSand,
                      foregroundColor: AppColors.forestSage,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.calculate_outlined, size: 16),
                    label: const Text(
                      'What-If GPA',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => state.setTab(1),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      backgroundColor: Colors.white.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: AppColors.warmSand),
                    label: const Text(
                      'Transcript PDF',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => state.setTab(1),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      backgroundColor: Colors.white.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.warmSand),
                    label: const Text(
                      'Teacher Chat',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => state.setTab(2),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _getRoleSubtitle(UserProfile user) {
    switch (user.role) {
      case UserRole.student:
        return '${user.gradeLevel} • ID: ${user.schoolId} • Lincoln High STEM Academy';
      case UserRole.teacher:
        return '${user.department} • 4 Active Sections • 118 Students';
      case UserRole.parent:
        return 'Viewing Academic Record for Alex Rivera (Grade 11)';
      case UserRole.admin:
        return 'Lincoln District High School • Central Administrative Control';
    }
  }

  Widget _buildCoursesSection(BuildContext context, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.book_outlined, size: 18, color: AppColors.forestSage),
                SizedBox(width: 8),
                Text(
                  'Active Academic Courses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => state.setTab(1),
              icon: const Text(
                'Full gradebook',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.forestSage),
              ),
              label: const Icon(Icons.arrow_outward, size: 14, color: AppColors.forestSage),
            ),
          ],
        ),

        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth > 550 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: count == 1 ? 2.4 : 1.75,
              ),
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                return CourseCard(course: state.courses[index]);
              },
            );
          },
        ),

        const SizedBox(height: 16),

        // Upcoming submission banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warmSand,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderMedium),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: const Icon(Icons.access_time, color: AppColors.earthyTerra, size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPCOMING SUBMISSION PENDING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: AppColors.earthyTerra,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Final Term Capstone: Distributed State Machine (CS-301) • Due Apr 18',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => state.setTab(1),
                child: const Text('View Rubric', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSideSection(BuildContext context, AppState state) {
    return Column(
      children: [
        // 1. Schedule Card
        const ScheduleWidget(),

        const SizedBox(height: 20),

        // 2. Live Notifications Stream Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notifications_outlined, size: 16, color: AppColors.forestSage),
                      SizedBox(width: 8),
                      Text(
                        'Live Stream',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => state.simulateNotification('grade'),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 12, color: AppColors.earthyTerra),
                        SizedBox(width: 4),
                        Text(
                          'Simulate',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestSage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.notifications.take(3).length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final notif = state.notifications[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => state.setTab(notif.category == NotificationCategory.message ? 2 : 3),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: notif.read ? AppColors.naturalParchment.withOpacity(0.6) : AppColors.naturalParchment,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderMedium),
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                notif.timestamp,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
