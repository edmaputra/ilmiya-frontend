import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../ilmiya_logo.dart';

class HeaderBrandTitle extends StatelessWidget {
  final bool isDesktop;
  final String tenantDisplayName;

  const HeaderBrandTitle({
    super.key,
    required this.isDesktop,
    required this.tenantDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IlmiyaLogo(size: 38, isSquircle: true),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ilmiya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warmSand,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Text(
                      'SIS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestSage,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                tenantDisplayName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.forestSage,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Expanded(
      child: Row(
        children: [
          const IlmiyaLogo(size: 38, isSquircle: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ilmiya',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warmSand,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Text(
                          'SIS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.forestSage,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  tenantDisplayName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestSage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
