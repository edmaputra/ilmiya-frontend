import React, { useState, useRef, useEffect } from 'react';
import { 
  Lock, 
  ShieldCheck, 
  Send, 
  Paperclip, 
  FileText, 
  CheckCheck, 
  Search, 
  Sparkles, 
  Info, 
  Tag, 
  Mic, 
  CornerDownRight, 
  PhoneCall, 
  Video, 
  AlertCircle,
  HelpCircle,
  X,
  Clock
} from 'lucide-react';
import { ChatChannel, ChatMessage, UserProfile, UserRole, Course, Assignment } from '../types';

interface MessagingViewProps {
  channels: ChatChannel[];
  messages: Record<string, ChatMessage[]>;
  currentUser: UserProfile;
  currentRole: UserRole;
  courses: Course[];
  activeChannelId: string;
  onSelectChannel: (channelId: string) => void;
  onSendMessage: (channelId: string, content: string, contextTag?: { type: 'assignment' | 'grade' | 'exam'; title: string; id: string }, attachment?: { name: string; type: 'pdf' | 'image' | 'code' | 'doc'; size: string }) => void;
  pendingInquiryContext?: { course: Course; assignment: Assignment } | null;
  onClearInquiryContext: () => void;
}

export const MessagingView: React.FC<MessagingViewProps> = ({
  channels,
  messages,
  currentUser,
  currentRole,
  courses,
  activeChannelId,
  onSelectChannel,
  onSendMessage,
  pendingInquiryContext,
  onClearInquiryContext,
}) => {
  const [inputText, setInputText] = useState('');
  const [showSecurityModal, setShowSecurityModal] = useState(false);
  const [selectedTag, setSelectedTag] = useState<{ type: 'assignment' | 'grade' | 'exam'; title: string; id: string } | null>(null);
  const [searchFilter, setSearchFilter] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const activeChannel = channels.find(c => c.id === activeChannelId) || channels[0];
  const channelMessages = messages[activeChannel?.id] || [];

  // When an inquiry context is passed from Grade Tracking
  useEffect(() => {
    if (pendingInquiryContext) {
      setSelectedTag({
        type: 'assignment',
        title: `${pendingInquiryContext.course.code}: ${pendingInquiryContext.assignment.title}`,
        id: pendingInquiryContext.assignment.id
      });
      setInputText(`Hello ${pendingInquiryContext.course.teacherName}, I had a quick question regarding my grade on "${pendingInquiryContext.assignment.title}"...`);
    }
  }, [pendingInquiryContext]);

  // Scroll to bottom
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [channelMessages]);

  const handleSend = () => {
    if (!inputText.trim() && !selectedTag) return;
    onSendMessage(
      activeChannel.id,
      inputText.trim(),
      selectedTag || undefined
    );
    setInputText('');
    setSelectedTag(null);
    onClearInquiryContext();
  };

  const handleAttachMockPDF = () => {
    onSendMessage(
      activeChannel.id,
      'Attached my revised project draft and test execution logs.',
      selectedTag || undefined,
      {
        name: 'Project4_TestCases_V2.pdf',
        type: 'pdf',
        size: '1.8 MB'
      }
    );
  };

  const quickReplies = [
    'Can we discuss this during today’s 3:15 PM office hours?',
    'I’ve pushed the updated test cases to the lab portal.',
    'Could you clarify the rubric criteria for Question 4?',
    'Thank you for the quick grade feedback and review!'
  ];

  return (
    <div className="bg-white border border-[#E9E4DB] rounded-[28px] shadow-sm overflow-hidden flex flex-col md:flex-row h-[750px]">
      
      {/* Left Sidebar: Channels List */}
      <div className="w-full md:w-80 bg-[#FAF9F6] border-r border-[#E9E4DB] flex flex-col">
        
        {/* Header & Search */}
        <div className="p-4.5 border-b border-[#E9E4DB] space-y-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Lock className="w-4 h-4 text-[#5F6F52]" />
              <h2 className="text-sm font-serif font-bold text-[#2C2E2A] tracking-tight">Secure Communications</h2>
            </div>
            <span className="text-[10px] font-bold uppercase tracking-widest bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB] px-2.5 py-0.5 rounded-full">
              AES-256
            </span>
          </div>

          <div className="relative">
            <Search className="w-3.5 h-3.5 text-[#8C887D] absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Search conversations..."
              value={searchFilter}
              onChange={(e) => setSearchFilter(e.target.value)}
              className="w-full bg-white border border-[#D9D1C5] rounded-xl pl-8 pr-3 py-1.5 text-xs text-[#2C2E2A] placeholder-[#8C887D] focus:outline-none focus:border-[#5F6F52]"
            />
          </div>
        </div>

        {/* Channels List */}
        <div className="flex-1 overflow-y-auto p-2 space-y-1">
          {channels.map((channel) => {
            const isSelected = channel.id === activeChannel.id;
            const otherParticipant = channel.participants.find(p => p.id !== currentUser.id) || channel.participants[0];

            return (
              <div
                key={channel.id}
                onClick={() => onSelectChannel(channel.id)}
                className={`p-3 rounded-2xl transition-all cursor-pointer ${
                  isSelected
                    ? 'bg-[#FEFAE0] border border-[#5F6F52]/40 shadow-xs'
                    : 'hover:bg-[#F2EDE4]/60 border border-transparent'
                }`}
              >
                <div className="flex items-start gap-3">
                  <div className="relative">
                    <img
                      src={otherParticipant?.avatar}
                      alt={channel.name}
                      className="w-10 h-10 rounded-full object-cover border border-[#D9D1C5]"
                    />
                    {otherParticipant?.online && (
                      <span className="absolute bottom-0 right-0 w-2.5 h-2.5 bg-[#5F6F52] border-2 border-white rounded-full" />
                    )}
                  </div>

                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <p className={`text-xs font-bold truncate ${isSelected ? 'text-[#5F6F52]' : 'text-[#2C2E2A]'}`}>
                        {channel.name}
                      </p>
                      <span className="text-[10px] text-[#8C887D] font-mono">
                        {channel.lastMessage?.timestamp}
                      </span>
                    </div>

                    <p className="text-[11px] text-[#6B6E68] truncate mt-0.5">
                      {channel.lastMessage?.text}
                    </p>

                    <div className="mt-1 flex items-center justify-between">
                      <span className="text-[10px] text-[#5F6F52] font-mono font-bold">
                        {channel.courseCode}
                      </span>
                      {channel.unreadCount > 0 && (
                        <span className="px-1.5 py-0.2 bg-[#5F6F52] text-white rounded-full text-[10px] font-bold">
                          {channel.unreadCount}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {/* Security Compliance Footer */}
        <div className="p-3 bg-[#F2EDE4]/60 border-t border-[#E9E4DB] text-[11px] text-[#6B6E68] flex items-center justify-between">
          <div className="flex items-center gap-1.5">
            <ShieldCheck className="w-4 h-4 text-[#5F6F52] shrink-0" />
            <span>FERPA / Student Privacy Guard</span>
          </div>
          <button
            onClick={() => setShowSecurityModal(true)}
            className="text-[#5F6F52] hover:text-[#2C2E2A] font-bold cursor-pointer"
          >
            Audit Keys
          </button>
        </div>
      </div>

      {/* Right Main Chat Window */}
      <div className="flex-1 flex flex-col bg-[#FAF9F6]">
        
        {/* Chat Top Banner */}
        <div className="p-4 border-b border-[#E9E4DB] bg-white flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div>
              <div className="flex items-center gap-2">
                <h3 className="text-sm font-serif font-bold text-[#2C2E2A]">{activeChannel.name}</h3>
                <span className="flex items-center gap-1 text-[10px] text-[#5F6F52] font-bold bg-[#FEFAE0] px-2 py-0.5 rounded-full border border-[#E9E4DB]">
                  <Lock className="w-2.5 h-2.5" />
                  Encrypted Channel
                </span>
              </div>
              <p className="text-xs text-[#8C887D] mt-0.5">
                Official academic communications • Responses typically within 2 hours
              </p>
            </div>
          </div>

          <button
            onClick={() => setShowSecurityModal(true)}
            className="p-2 text-[#8C887D] hover:text-[#2C2E2A] rounded-xl hover:bg-[#F2EDE4] transition-colors cursor-pointer"
            title="View Security Audit"
          >
            <Info className="w-4 h-4" />
          </button>
        </div>

        {/* Academic Context Tag Bar (if active) */}
        {selectedTag && (
          <div className="bg-[#FEFAE0] border-b border-[#E9E4DB] px-4 py-2 flex items-center justify-between text-xs">
            <div className="flex items-center gap-2 text-[#5F6F52]">
              <Tag className="w-3.5 h-3.5 text-[#D67D5B]" />
              <span>Linked Inquiry Context: <strong>{selectedTag.title}</strong></span>
            </div>
            <button
              onClick={() => setSelectedTag(null)}
              className="text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer"
            >
              <X className="w-3.5 h-3.5" />
            </button>
          </div>
        )}

        {/* Message Stream */}
        <div className="flex-1 overflow-y-auto p-4 space-y-3">
          {channelMessages.map((msg) => {
            const isMe = msg.senderId === currentUser.id;

            return (
              <div
                key={msg.id}
                className={`flex gap-2.5 max-w-lg ${isMe ? 'ml-auto flex-row-reverse' : 'mr-auto'}`}
              >
                {!isMe && (
                  <img
                    src={msg.senderAvatar}
                    alt={msg.senderName}
                    className="w-7 h-7 rounded-full object-cover shrink-0 mt-1 border border-[#D9D1C5]"
                  />
                )}

                <div className="space-y-1">
                  <div
                    className={`p-3.5 rounded-2xl text-xs space-y-2 shadow-xs ${
                      isMe
                        ? 'bg-[#5F6F52] text-[#FAF9F6] rounded-tr-none'
                        : 'bg-white text-[#2C2E2A] rounded-tl-none border border-[#E9E4DB]'
                    }`}
                  >
                    {/* Attached context tag */}
                    {msg.contextTag && (
                      <div className={`px-2.5 py-1 rounded-lg text-[11px] font-bold flex items-center gap-1.5 ${isMe ? 'bg-black/15 text-[#FEFAE0]' : 'bg-[#FEFAE0] text-[#5F6F52] border border-[#E9E4DB]'}`}>
                        <Tag className="w-3 h-3" />
                        <span>Regarding: {msg.contextTag.title}</span>
                      </div>
                    )}

                    <p className="leading-relaxed text-sm">{msg.content}</p>

                    {/* Attachment preview */}
                    {msg.attachment && (
                      <div className={`p-2.5 rounded-xl flex items-center gap-2 border ${isMe ? 'bg-black/15 border-white/10' : 'bg-[#FAF9F6] border-[#E9E4DB]'}`}>
                        <FileText className={`w-4 h-4 ${isMe ? 'text-[#FEFAE0]' : 'text-[#5F6F52]'}`} />
                        <div className="flex-1 min-w-0">
                          <p className={`text-xs font-bold truncate ${isMe ? 'text-white' : 'text-[#2C2E2A]'}`}>{msg.attachment.name}</p>
                          <p className={`text-[10px] ${isMe ? 'text-[#FAF9F6]/80' : 'text-[#8C887D]'}`}>{msg.attachment.size} • Verified PDF</p>
                        </div>
                      </div>
                    )}

                    <div className={`flex items-center justify-end gap-1.5 text-[10px] ${isMe ? 'text-[#FAF9F6]/80' : 'text-[#8C887D]'}`}>
                      <span>{msg.timestamp}</span>
                      {isMe && <CheckCheck className="w-3.5 h-3.5 text-[#FEFAE0]" />}
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
          <div ref={messagesEndRef} />
        </div>

        {/* Quick Suggestion Chips */}
        <div className="px-4 py-2.5 bg-[#FAF9F6] border-t border-[#E9E4DB] flex items-center gap-2 overflow-x-auto text-[11px]">
          <span className="text-[#8C887D] font-bold shrink-0 flex items-center gap-1">
            <Sparkles className="w-3 h-3 text-[#5F6F52]" />
            Quick:
          </span>
          {quickReplies.map((reply, idx) => (
            <button
              key={idx}
              onClick={() => setInputText(reply)}
              className="px-3 py-1 bg-white hover:bg-[#F2EDE4] text-[#2C2E2A] rounded-xl border border-[#D9D1C5] whitespace-nowrap transition-colors cursor-pointer font-medium"
            >
              {reply}
            </button>
          ))}
        </div>

        {/* Input Bar */}
        <div className="p-3.5 bg-white border-t border-[#E9E4DB] flex items-center gap-2">
          <button
            onClick={handleAttachMockPDF}
            className="p-2 rounded-xl text-[#8C887D] hover:text-[#2C2E2A] hover:bg-[#F2EDE4] transition-colors cursor-pointer"
            title="Attach Lab/Assignment Document (PDF)"
          >
            <Paperclip className="w-4 h-4 text-[#5F6F52]" />
          </button>

          <input
            type="text"
            placeholder={`Message ${activeChannel.name}...`}
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSend()}
            className="flex-1 bg-[#FAF9F6] border border-[#D9D1C5] rounded-xl px-4 py-2 text-xs text-[#2C2E2A] placeholder-[#8C887D] focus:outline-none focus:border-[#5F6F52]"
          />

          <button
            onClick={handleSend}
            disabled={!inputText.trim()}
            className="px-4.5 py-2 rounded-xl bg-[#5F6F52] hover:bg-[#4E5C43] disabled:opacity-40 disabled:cursor-not-allowed text-white font-bold text-xs flex items-center gap-1.5 shadow-sm transition-all cursor-pointer"
          >
            <span>Send</span>
            <Send className="w-3.5 h-3.5" />
          </button>
        </div>

      </div>

      {/* Security & Cryptography Modal */}
      {showSecurityModal && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white border border-[#E9E4DB] rounded-[28px] max-w-md w-full p-6 space-y-4 shadow-xl text-[#2C2E2A]">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <ShieldCheck className="w-5 h-5 text-[#5F6F52]" />
                <h3 className="text-base font-serif font-bold text-[#2C2E2A]">End-to-End Encryption Audit</h3>
              </div>
              <button
                onClick={() => setShowSecurityModal(false)}
                className="text-[#8C887D] hover:text-[#2C2E2A] cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <p className="text-xs text-[#6B6E68] leading-relaxed">
              All direct student-to-teacher communications in ILMIYA use authenticated AES-256 GCM encryption. Keys are exchanged client-side using Elliptic Curve Cryptography (ECDH Curve25519) and verified for strict FERPA and COPPA compliance.
            </p>

            <div className="bg-[#FAF9F6] p-3.5 rounded-2xl border border-[#E9E4DB] text-xs space-y-2">
              <div className="flex justify-between text-[#6B6E68]">
                <span>Encryption Standard:</span>
                <span className="font-mono text-[#5F6F52] font-bold">AES-256-GCM</span>
              </div>
              <div className="flex justify-between text-[#6B6E68]">
                <span>Key Exchange Protocol:</span>
                <span className="font-mono text-[#2C2E2A]">ECDH X25519</span>
              </div>
              <div className="flex justify-between text-[#6B6E68]">
                <span>Student Fingerprint:</span>
                <span className="font-mono text-[#2C2E2A]">89A4 • E19B • 401C • 77D9</span>
              </div>
              <div className="flex justify-between text-[#6B6E68]">
                <span>Teacher Fingerprint:</span>
                <span className="font-mono text-[#2C2E2A]">22FE • 90BC • 110A • 844F</span>
              </div>
            </div>

            <button
              onClick={() => setShowSecurityModal(false)}
              className="w-full py-2.5 bg-[#5F6F52] hover:bg-[#4E5C43] text-white rounded-xl text-xs font-bold cursor-pointer transition-colors shadow-sm"
            >
              Confirm Verified Identity
            </button>
          </div>
        </div>
      )}

    </div>
  );
};
