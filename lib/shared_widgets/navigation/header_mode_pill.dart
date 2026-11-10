import 'package:flutter/material.dart';

import '../../core/services/api_client.dart';

class HeaderModePill extends StatelessWidget {
  const HeaderModePill({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: apiClient,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: apiClient.isMockMode
                ? const Color(0xFFF3E8FF)
                : const Color(0xFFE6F4EA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: apiClient.isMockMode
                  ? const Color(0xFFD8B4FE)
                  : const Color(0xFFA8DAB5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: apiClient.isMockMode
                      ? const Color(0xFF9333EA)
                      : const Color(0xFF137333),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                apiClient.isMockMode ? 'Mock Simulation' : 'Live REST API',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: apiClient.isMockMode
                      ? const Color(0xFF7E22CE)
                      : const Color(0xFF137333),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
