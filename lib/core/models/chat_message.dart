import 'user_profile.dart';

class ChatAttachment {
  final String name;
  final String type; // 'pdf' | 'image' | 'code' | 'doc'
  final String size;
  final String? url;

  const ChatAttachment({
    required this.name,
    required this.type,
    required this.size,
    this.url,
  });
}

class ChatContextTag {
  final String type; // 'assignment' | 'grade' | 'exam'
  final String title;
  final String id;

  const ChatContextTag({
    required this.type,
    required this.title,
    required this.id,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final UserRole senderRole;
  final String senderAvatar;
  final String content;
  final String timestamp;
  final bool isEncrypted;
  final String status; // 'sending' | 'sent' | 'delivered' | 'read'
  final ChatAttachment? attachment;
  final ChatContextTag? contextTag;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.senderAvatar,
    required this.content,
    required this.timestamp,
    this.isEncrypted = true,
    this.status = 'delivered',
    this.attachment,
    this.contextTag,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    UserRole? senderRole,
    String? senderAvatar,
    String? content,
    String? timestamp,
    bool? isEncrypted,
    String? status,
    ChatAttachment? attachment,
    ChatContextTag? contextTag,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      status: status ?? this.status,
      attachment: attachment ?? this.attachment,
      contextTag: contextTag ?? this.contextTag,
    );
  }
}

class ChatParticipant {
  final String id;
  final String name;
  final UserRole role;
  final String avatar;
  final bool online;

  const ChatParticipant({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    this.online = false,
  });
}

class ChatLastMessage {
  final String text;
  final String timestamp;
  final String senderId;

  const ChatLastMessage({
    required this.text,
    required this.timestamp,
    required this.senderId,
  });
}

class ChatChannel {
  final String id;
  final String name;
  final String type; // 'direct' | 'class_group' | 'office_hours'
  final List<ChatParticipant> participants;
  final String? courseCode;
  final ChatLastMessage? lastMessage;
  final int unreadCount;
  final bool isEncrypted;

  const ChatChannel({
    required this.id,
    required this.name,
    required this.type,
    required this.participants,
    this.courseCode,
    this.lastMessage,
    this.unreadCount = 0,
    this.isEncrypted = true,
  });

  ChatChannel copyWith({
    String? id,
    String? name,
    String? type,
    List<ChatParticipant>? participants,
    String? courseCode,
    ChatLastMessage? lastMessage,
    int? unreadCount,
    bool? isEncrypted,
  }) {
    return ChatChannel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      courseCode: courseCode ?? this.courseCode,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }
}
