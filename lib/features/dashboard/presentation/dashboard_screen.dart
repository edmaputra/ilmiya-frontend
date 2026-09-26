import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:provider/provider.dart';

import '../../../state/app_state.dart';
import '../../../state/auth_notifier.dart';
import '../widgets/dashboard_activity_sidebar.dart';
import '../widgets/dashboard_courses_section.dart';
import '../widgets/dashboard_header_banner.dart';
import '../widgets/dashboard_kpi_grid.dart';

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
          DashboardHeaderBanner(
            user: user,
            schoolName: schoolName,
            state: state,
          ),

          const SizedBox(height: KiteSpace.xl),

          // 2. Kite KPI Stat Grid
          DashboardKpiGrid(state: state),

          const SizedBox(height: KiteSpace.xl),

          // 3. Main Content: Courses (Left) & Timetable / Live Stream (Right)
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: DashboardCoursesSection(state: state),
                ),
                const SizedBox(width: KiteSpace.xl),
                Expanded(
                  flex: 5,
                  child: DashboardActivitySidebar(state: state),
                ),
              ],
            )
          else ...[
            DashboardCoursesSection(state: state),
            const SizedBox(height: KiteSpace.xl),
            DashboardActivitySidebar(state: state),
          ],
        ],
      ),
    );
  }
}
