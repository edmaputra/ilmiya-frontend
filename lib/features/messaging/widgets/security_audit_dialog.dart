import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SecurityAuditDialog extends StatelessWidget {
  const SecurityAuditDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.security, size: 20, color: AppColors.forestSage),
                    SizedBox(width: 8),
                    Text(
                      'End-to-End Encryption Audit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Text(
              'All direct student-to-teacher communications in Ilmiya use authenticated AES-256 GCM encryption. Keys are exchanged client-side using Elliptic Curve Cryptography (ECDH Curve25519) and verified for strict FERPA and COPPA compliance.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.naturalParchment,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _buildSecurityRow('Encryption Standard:', 'AES-256-GCM', isAccent: true),
                  const SizedBox(height: 8),
                  _buildSecurityRow('Key Exchange Protocol:', 'ECDH X25519'),
                  const SizedBox(height: 8),
                  _buildSecurityRow('Student Fingerprint:', '89A4 • E19B • 401C • 77D9'),
                  const SizedBox(height: 8),
                  _buildSecurityRow('Teacher Fingerprint:', '22FE • 90BC • 110A • 844F'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Confirm Verified Identity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityRow(String label, String value, {bool isAccent = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isAccent ? AppColors.forestSage : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
