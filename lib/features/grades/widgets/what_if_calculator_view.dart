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

class WhatIfCalculatorView extends StatefulWidget {
  const WhatIfCalculatorView({super.key});

  @override
  State<WhatIfCalculatorView> createState() => _WhatIfCalculatorViewState();
}

class _WhatIfCalculatorViewState extends State<WhatIfCalculatorView> {
  final List<SimulatedAssignment> _simulations = [
    SimulatedAssignment(
      id: 'sim_1',
      name: 'AP CS Term Final Project',
      courseName: 'AP Computer Science A (CS-301)',
      weight: 25,
      simulatedScore: 96,
    ),
    SimulatedAssignment(
      id: 'sim_2',
      name: 'AP Physics Final Exam',
      courseName: 'AP Physics C (PHYS-302)',
      weight: 30,
      simulatedScore: 92,
    ),
    SimulatedAssignment(
      id: 'sim_3',
      name: 'AP Calc BC AP Mock Test',
      courseName: 'AP Calculus BC (MATH-401)',
      weight: 25,
      simulatedScore: 95,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Dynamic recalculation
    double avgSimScore = _simulations.fold(0.0, (sum, s) => sum + s.simulatedScore) / _simulations.length;
    double simUnweighted = (3.80 + (avgSimScore - 80) * 0.006).clamp(3.0, 4.0);
    double simWeighted = (4.00 + (avgSimScore - 80) * 0.009).clamp(3.5, 5.0);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate_outlined, size: 20, color: AppColors.forestSage),
                        SizedBox(width: 8),
                        Text(
                          'GPA What-If Scenario Prediction Studio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Simulate upcoming midterm, final exam, and project scores to calculate their exact impact on your final cumulative GPA.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.auto_awesome, size: 14, color: AppColors.warmSand),
                label: const Text('Celebrate Target!', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.forestSage,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      content: const Text(
                        '🎉 Congratulations! Projected GPA reaches top tier Dean\'s Honor Roll!',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Simulation Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 700 ? 3 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: count == 1 ? 2.3 : 1.35,
                ),
                itemCount: _simulations.length,
                itemBuilder: (context, index) {
                  final sim = _simulations[index];
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
                            onChanged: (val) {
                              setState(() {
                                sim.simulatedScore = val;
                              });
                            },
                          ),
                        ),
                        Text(
                          sim.simulatedScore >= 90 ? 'Maintains Grade A (4.0)' : 'Impact: Adjusts to B+ (3.3)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: sim.simulatedScore >= 90 ? AppColors.forestSage : AppColors.earthyTerra,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 24),

          // Target Outcome Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.warmSand,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderMedium),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Cumulative GPA Outcome',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'With these simulated scores, your semester GPA will adjust to:',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        const Text(
                          'SIMULATED UNWEIGHTED',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                        ),
                        Text(
                          simUnweighted.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.forestSage,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Column(
                      children: [
                        const Text(
                          'SIMULATED WEIGHTED',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                        ),
                        Text(
                          simWeighted.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.earthyTerra,
                          ),
                        ),
                      ],
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
