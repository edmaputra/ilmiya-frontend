import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController textController;
  final List<String> quickReplies;
  final String channelName;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final ValueChanged<String> onSubmitted;

  const ChatInputBar({
    super.key,
    required this.textController,
    required this.quickReplies,
    required this.channelName,
    required this.onSend,
    required this.onAttach,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick Suggestions
        Container(
          height: 36,
          color: AppColors.naturalParchment,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: quickReplies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final reply = quickReplies[index];
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  textController.text = reply;
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderMedium),
                  ),
                  child: Text(
                    reply,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Input Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.attach_file, color: AppColors.forestSage),
                onPressed: onAttach,
              ),
              Expanded(
                child: TextField(
                  controller: textController,
                  onSubmitted: onSubmitted,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Message $channelName...',
                    fillColor: AppColors.naturalParchment,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: AppColors.borderMedium),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestSage,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.send, size: 14),
                label: const Text(
                  'Send',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                onPressed: onSend,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
