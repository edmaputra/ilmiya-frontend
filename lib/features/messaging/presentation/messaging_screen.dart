import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/course.dart';
import '../../../state/app_state.dart';
import '../widgets/chat_bubble_view.dart';
import '../widgets/contextual_inquiry_tag.dart';
import '../widgets/security_audit_dialog.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatContextTag? _selectedTag;

  final List<String> _quickReplies = [
    'Can we discuss this during today’s 3:15 PM office hours?',
    'I’ve pushed the updated test cases to the lab portal.',
    'Could you clarify the rubric criteria for Question 4?',
    'Thank you for the quick grade feedback and review!',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      if (state.pendingInquiryContext != null) {
        final Course course = state.pendingInquiryContext!['course'];
        final Assignment asg = state.pendingInquiryContext!['assignment'];
        setState(() {
          _selectedTag = ChatContextTag(
            type: 'assignment',
            title: '${course.code}: ${asg.title}',
            id: asg.id,
          );
          _textController.text =
              'Hello ${course.teacherName}, I had a quick question regarding my grade on "${asg.title}"...';
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage(AppState state) {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedTag == null) return;

    state.sendMessage(
      channelId: state.activeChannelId,
      content: text.isNotEmpty ? text : 'Regarding inquiry tag',
      contextTag: _selectedTag,
    );

    _textController.clear();
    setState(() {
      _selectedTag = null;
    });
    state.clearInquiryContext();
    _scrollToBottom();
  }

  void _handleAttachPDF(AppState state) {
    state.sendMessage(
      channelId: state.activeChannelId,
      content: 'Attached my revised project draft and test execution logs.',
      contextTag: _selectedTag,
      attachment: const ChatAttachment(
        name: 'Project4_TestCases_V2.pdf',
        type: 'pdf',
        size: '1.8 MB',
      ),
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        height: 720,
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
        clipBehavior: Clip.antiAlias,
        child: isDesktop
            ? Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: _buildChannelsSidebar(state),
                  ),
                  const VerticalDivider(width: 1, color: AppColors.borderLight),
                  Expanded(
                    child: _buildChatMainArea(state),
                  ),
                ],
              )
            : _buildChatMainArea(state),
      ),
    );
  }

  Widget _buildChannelsSidebar(AppState state) {
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
                    const Row(
                      children: [
                        Icon(Icons.lock_outline,
                            size: 16, color: AppColors.forestSage),
                        SizedBox(width: 6),
                        Text(
                          'Secure Communications',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
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
                const Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 14, color: AppColors.forestSage),
                    SizedBox(width: 4),
                    Text('FERPA Protected',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
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

  Widget _buildChatMainArea(AppState state) {
    final activeChannel = state.activeChannel;
    final messages = state.activeChannelMessages;

    return Column(
      children: [
        // Chat Top Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        activeChannel.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warmSand,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock,
                                size: 9, color: AppColors.forestSage),
                            SizedBox(width: 3),
                            Text('Encrypted Channel',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forestSage)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Official academic communications • Responses typically within 2 hours',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.info_outline,
                    size: 18, color: AppColors.textMuted),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const SecurityAuditDialog(),
                  );
                },
              ),
            ],
          ),
        ),

        // Context Tag Bar (if selected)
        if (_selectedTag != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.warmSand,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ContextualInquiryTagView(
                  contextTag: _selectedTag!,
                  onRemove: () => setState(() => _selectedTag = null),
                ),
              ],
            ),
          ),

        // Message Feed
        Expanded(
          child: Container(
            color: AppColors.naturalParchment,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderId == state.currentUser.id;
                return ChatBubbleView(message: msg, isMe: isMe);
              },
            ),
          ),
        ),

        // Quick Suggestions
        Container(
          height: 36,
          color: AppColors.naturalParchment,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: _quickReplies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final reply = _quickReplies[index];
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  _textController.text = reply;
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
                        color: AppColors.textSecondary),
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
                onPressed: () => _handleAttachPDF(state),
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  onSubmitted: (_) => _handleSendMessage(state),
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Message ${activeChannel.name}...',
                    fillColor: AppColors.naturalParchment,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
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
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.send, size: 14),
                label: const Text('Send',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                onPressed: () => _handleSendMessage(state),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
