import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/course.dart';
import '../../../state/app_state.dart';
import '../widgets/chat_bubble_view.dart';
import '../widgets/chat_channels_sidebar.dart';
import '../widgets/chat_header_bar.dart';
import '../widgets/chat_input_bar.dart';
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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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
                    width: 320,
                    child: ChatChannelsSidebar(state: state),
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

  Widget _buildChatMainArea(AppState state) {
    final activeChannel = state.activeChannel;
    final messages = state.activeChannelMessages;

    return Column(
      children: [
        // Chat Top Bar
        ChatHeaderBar(
          activeChannel: activeChannel,
          onInfoTap: () {
            showDialog(
              context: context,
              builder: (_) => const SecurityAuditDialog(),
            );
          },
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

        // Input Bar & Quick Replies
        ChatInputBar(
          textController: _textController,
          quickReplies: _quickReplies,
          channelName: activeChannel.name,
          onSend: () => _handleSendMessage(state),
          onAttach: () => _handleAttachPDF(state),
          onSubmitted: (_) => _handleSendMessage(state),
        ),
      ],
    );
  }
}
