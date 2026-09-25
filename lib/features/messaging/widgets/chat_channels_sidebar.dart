import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../state/app_state.dart';
import 'security_audit_dialog.dart';

class ChatChannelsSidebar extends StatelessWidget {
  final AppState state;

  const ChatChannelsSidebar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.naturalParchment,
      child: Column(
        children: [
          // Sidebar Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline,
                              size: 16, color: AppColors.forestSage),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Secure Communications',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warmSand,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Text(
                        'AES-256',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.forestSage),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // Channels List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: state.channels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final channel = state.channels[index];
                final isSelected = channel.id == state.activeChannelId;
                final participant = channel.participants.firstWhere(
                  (p) => p.id != state.currentUser.id,
                  orElse: () => channel.participants.first,
                );

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => state.setActiveChannel(channel.id),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.warmSand : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.forestSage.withOpacity(0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(participant.avatar),
                              backgroundColor: AppColors.borderLight,
                            ),
                            if (participant.online)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.forestSage,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      channel.name,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.forestSage
                                            : AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (channel.lastMessage != null)
                                    Text(
                                      channel.lastMessage!.timestamp,
                                      style: const TextStyle(
                                          fontSize: 9,
                                          color: AppColors.textMuted),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                channel.lastMessage?.text ?? 'No messages yet',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Security footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.surfaceMuted.withOpacity(0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 14, color: AppColors.forestSage),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'FERPA Protected',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const SecurityAuditDialog(),
                    );
                  },
                  child: const Text(
                    'Audit Keys',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestSage),
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
