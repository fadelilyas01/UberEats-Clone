import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';

// Chat State
class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final MessageType type;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.type = MessageType.text,
  });
}

enum MessageType { text, image, location }

// Mock courier data
class CourierInfo {
  final String name;
  final String photoUrl;
  final double rating;
  final String vehicleType;

  const CourierInfo({
    required this.name,
    required this.photoUrl,
    required this.rating,
    required this.vehicleType,
  });
}

final courierProvider = Provider<CourierInfo>((ref) => const CourierInfo(
      name: 'Pierre Laurent',
      photoUrl: 'https://i.pravatar.cc/200?u=courier',
      rating: 4.9,
      vehicleType: 'Bicycle',
    ));

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
        (ref) => ChatMessagesNotifier());

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier()
      : super([
          ChatMessage(
              id: '1',
              text: "Hey! I'm on my way to pick up your order 🏃",
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(minutes: 10))),
          ChatMessage(
              id: '2',
              text: 'Got your order, heading to you now!',
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
          ChatMessage(
              id: '3',
              text: 'Great! Thanks for the update',
              isMe: true,
              timestamp: DateTime.now().subtract(const Duration(minutes: 4))),
          ChatMessage(
              id: '4',
              text: "I'll be there in about 10 minutes 🚴",
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(minutes: 2))),
        ]);

  void addMessage(String text) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isMe: true,
      timestamp: DateTime.now(),
    );
    state = [...state, message];

    // Simulate courier reply
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final replies = [
          "Got it! 👍",
          "No problem!",
          "Sure thing!",
          "On my way! 🚴",
          "Almost there!",
        ];
        final reply = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: replies[DateTime.now().second % replies.length],
          isMe: false,
          timestamp: DateTime.now(),
        );
        state = [...state, reply];
      }
    });
  }

  @override
  bool get mounted => true;
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatMessagesProvider.notifier).addMessage(text);
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final courier = ref.watch(courierProvider);
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      body: Stack(children: [
        const BackgroundOrb(
            size: 250,
            color: AppColors.primary,
            alignment: Alignment(1.5, -0.5)),
        Column(children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
              ],
            ),
            child: Row(children: [
              GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                  size: 42),
              const SizedBox(width: 14),

              // Courier Info
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: OptimizedImage(
                      imageUrl: courier.photoUrl, width: 44, height: 44),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(courier.name,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Online • ${courier.vehicleType}',
                          style: GoogleFonts.inter(
                              color: AppColors.textMuted, fontSize: 12)),
                    ]),
                  ])),

              GlassIconButton(icon: Icons.call_rounded, onTap: () {}, size: 42),
            ]),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (ctx, i) => _MessageBubble(
                message: messages[i],
                showAvatar: i == messages.length - 1 ||
                    messages[i].isMe !=
                        messages[i + 1 < messages.length ? i + 1 : i].isMe,
                courier: courier,
                index: i,
              ),
            ),
          ),

          // Input
          _ChatInput(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ]),
      ]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final CourierInfo courier;
  final int index;

  const _MessageBubble(
      {required this.message,
      required this.showAvatar,
      required this.courier,
      required this.index});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe && showAvatar)
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: ClipOval(
                  child: OptimizedImage(
                      imageUrl: courier.photoUrl, width: 32, height: 32)),
            )
          else if (!message.isMe)
            const SizedBox(width: 42),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isMe ? AppColors.gradientPrimary : null,
                color: message.isMe ? null : AppColors.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isMe ? 20 : 6),
                  bottomRight: Radius.circular(message.isMe ? 6 : 20),
                ),
                boxShadow: message.isMe
                    ? [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]
                    : null,
              ),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(message.text,
                    style: GoogleFonts.inter(fontSize: 15, height: 1.4)),
                const SizedBox(height: 4),
                Text(timeStr,
                    style: GoogleFonts.inter(
                        color: message.isMe
                            ? Colors.white.withOpacity(0.7)
                            : AppColors.textMuted,
                        fontSize: 11)),
              ]),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn()
        .slideY(begin: 0.1, end: 0);
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: Row(children: [
          // Attachment button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.add_rounded, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),

          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: TextField(
                controller: controller,
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ]),
      );
}

// Quick Chat Floating Button (to add to tracking screen)
class QuickChatButton extends StatelessWidget {
  final VoidCallback onTap;

  const QuickChatButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.chat_bubble_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('Chat with Courier',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ]),
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
}
