import 'package:flutter/material.dart';
import 'package:kite_ui/kite_ui.dart';
import '../../../state/app_state.dart';

class DashboardKpiGrid extends StatelessWidget {
  final AppState state;

  const DashboardKpiGrid({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
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
}
