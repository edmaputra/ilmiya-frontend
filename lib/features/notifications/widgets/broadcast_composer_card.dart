import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_item.dart';
import '../../../state/app_state.dart';

class BroadcastComposerCard extends StatefulWidget {
  const BroadcastComposerCard({super.key});

  @override
  State<BroadcastComposerCard> createState() => _BroadcastComposerCardState();
}

class _BroadcastComposerCardState extends State<BroadcastComposerCard> {
  String _target = 'All School (Students & Parents)';
  NotificationPriority _priority = NotificationPriority.high;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  void _handleDispatch(AppState state) {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    if (title.isEmpty || message.isEmpty) return;

    state.broadcastAnnouncement(
      title: title,
      message: message,
      priority: _priority,
      target: _target,
    );

    _titleController.clear();
    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.forestSage,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          '📢 Broadcast "$title" dispatched to $_target!',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.podcasts, size: 18, color: AppColors.forestSage),
              SizedBox(width: 8),
              Text(
                'Broadcast Announcement',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Send instant high-priority push notifications to selected classes, grade levels, or the entire school body.',
            style: TextStyle(
                fontSize: 11, color: AppColors.textSecondary, height: 1.3),
          ),

          const SizedBox(height: 14),

          // Target Audience
          const Text('Target Audience',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _target,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              fillColor: AppColors.naturalParchment,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: const [
              DropdownMenuItem(
                  value: 'All School (Students & Parents)',
                  child: Text('All School (Students & Parents)',
                      style: TextStyle(fontSize: 11))),
              DropdownMenuItem(
                  value: 'Grade 11 (Juniors)',
                  child: Text('Grade 11 (Juniors)',
                      style: TextStyle(fontSize: 11))),
              DropdownMenuItem(
                  value: 'AP Computer Science A - Period 1',
                  child: Text('AP Computer Science A - Period 1',
                      style: TextStyle(fontSize: 11))),
              DropdownMenuItem(
                  value: 'AP Physics C - Period 3',
                  child: Text('AP Physics C - Period 3',
                      style: TextStyle(fontSize: 11))),
            ],
            onChanged: (val) => setState(() => _target = val!),
          ),

          const SizedBox(height: 10),

          // Priority
          const Text('Priority Level',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          DropdownButtonFormField<NotificationPriority>(
            value: _priority,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              fillColor: AppColors.naturalParchment,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: const [
              DropdownMenuItem(
                  value: NotificationPriority.medium,
                  child:
                      Text('Standard Notice', style: TextStyle(fontSize: 11))),
              DropdownMenuItem(
                  value: NotificationPriority.high,
                  child: Text('High Academic Priority',
                      style: TextStyle(fontSize: 11))),
              DropdownMenuItem(
                  value: NotificationPriority.urgent,
                  child: Text('Urgent / Emergency Alert',
                      style: TextStyle(fontSize: 11))),
            ],
            onChanged: (val) => setState(() => _priority = val!),
          ),

          const SizedBox(height: 10),

          // Title
          const Text('Broadcast Headline',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'e.g. Schedule Change for Period 4',
              fillColor: AppColors.naturalParchment,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 10),

          // Message
          const Text('Message Content',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          TextField(
            controller: _messageController,
            maxLines: 3,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Type broadcast description...',
              fillColor: AppColors.naturalParchment,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestSage,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.send, size: 14),
              label: const Text('Dispatch Instant Push Broadcast',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              onPressed: () => _handleDispatch(state),
            ),
          ),
        ],
      ),
    );
  }
}
