import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SimulatedAssignment {
  final String id;
  final String name;
  final String courseName;
  final double weight;
  double simulatedScore;

  SimulatedAssignment({
    required this.id,
    required this.name,
    required this.courseName,
    required this.weight,
    required this.simulatedScore,
  });
}

class SimulationCard extends StatelessWidget {
  final SimulatedAssignment sim;
  final ValueChanged<double> onScoreChanged;

  const SimulationCard({
    super.key,
    required this.sim,
    required this.onScoreChanged,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight: ${sim.weight.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forestSage,
                ),
              ),
              Text(
                '${sim.simulatedScore.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sim.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                sim.courseName,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.forestSage,
              inactiveTrackColor: AppColors.borderMedium,
              thumbColor: AppColors.forestSage,
              overlayColor: AppColors.forestSage.withOpacity(0.12),
              trackHeight: 4,
            ),
            child: Slider(
              min: 50,
              max: 100,
              value: sim.simulatedScore,
              onChanged: onScoreChanged,
            ),
          ),
          Text(
            sim.simulatedScore >= 90
                ? 'Maintains Grade A (4.0)'
                : 'Impact: Adjusts to B+ (3.3)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: sim.simulatedScore >= 90
                  ? AppColors.forestSage
                  : AppColors.earthyTerra,
            ),
          ),
        ],
      ),
    );
  }
}
