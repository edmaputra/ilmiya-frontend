import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_client.dart';
import '../../../shared_widgets/ilmiya_logo.dart';
import 'login_dialog.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.naturalParchment,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          padding:
              EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 8),
          child: Row(
            children: [
              const IlmiyaLogo(size: 28),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ilmiya',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (!isMobile)
                    const Text(
                      'School Information System & IAM Portal',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textSecondary),
                    ),
                ],
              ),
              const Spacer(),
              // Mode Status Badge (Determined at Startup Profile)
              ListenableBuilder(
                listenable: apiClient,
                builder: (context, _) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          apiClient.isMockMode
                              ? 'Mock Simulation'
                              : 'Live REST API',
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
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: const LoginDialog(isStandalone: true),
          ),
        ),
      ),
    );
  }
}
