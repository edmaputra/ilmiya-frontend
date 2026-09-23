import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/chat_message.dart';

class ContextualInquiryTagView extends StatelessWidget {
  final ChatContextTag contextTag;
  final bool isMe;
  final VoidCallback? onRemove;

  const ContextualInquiryTagView({
    super.key,
    required this.contextTag,
    this.isMe = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isMe ? Colors.black.withOpacity(0.18) : AppColors.warmSand,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMe ? Colors.white.withOpacity(0.2) : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.tag,
            size: 13,
            color: isMe ? AppColors.warmSand : AppColors.earthyTerra,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              'Regarding: ${contextTag.title}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isMe ? Colors.white : AppColors.forestSage,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onRemove,
              child:
                  const Icon(Icons.close, size: 13, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
