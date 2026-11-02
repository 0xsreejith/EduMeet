import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edumeet/app/router/route_constants.dart';
import 'package:edumeet/app/theme/app_colors.dart';
import 'package:edumeet/app/theme/app_typography.dart';
import 'package:edumeet/core/widgets/edumeet_app_bar.dart';
import 'package:edumeet/core/widgets/edumeet_card.dart';
import 'package:edumeet/core/widgets/responsive_layout.dart';
import 'package:edumeet/features/auth/presentation/providers/auth_provider.dart';
import 'package:edumeet/features/chat/domain/entities/chat_entity.dart';
import 'package:edumeet/features/chat/presentation/providers/chat_provider.dart';

class ChatMessagesScreen extends ConsumerStatefulWidget {
  const ChatMessagesScreen({super.key});

  @override
  ConsumerState<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends ConsumerState<ChatMessagesScreen> {
  int _selectedTabIndex = 0; // 0: Messages, 1: Announcements, 2: Alerts
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChatDialog(BuildContext context, ChatConversationEntity conv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ChatDetailSheet(conversation: conv),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final conversationsAsync = ref.watch(conversationsStreamProvider);
    final announcementsAsync = ref.watch(announcementsStreamProvider);
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: EduMeetAppBar(
        showLogo: true,
        avatarUrl: user?.avatarUrl,
        onAvatarTap: () => context.go(RouteConstants.profile),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                  // Top Segmented Nav / Tabs
                  Row(
                    children: [
                      _TabButton(
                        label: 'Messages (3)',
                        isSelected: _selectedTabIndex == 0,
                        onTap: () => setState(() => _selectedTabIndex = 0),
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        label: 'Announcements',
                        isSelected: _selectedTabIndex == 1,
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        label: 'Alerts',
                        isSelected: _selectedTabIndex == 2,
                        onTap: () => setState(() => _selectedTabIndex = 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search Bar
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.bodySm(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search chats, announcements, or alerts...',
                        hintStyle: AppTypography.bodySm(color: AppColors.outline),
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.outline),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab View Body
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  // Tab 0: Messages
                  conversationsAsync.when(
                    data: (conversations) => ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      itemCount: conversations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final conv = conversations[index];
                        return _ConversationCard(
                          conversation: conv,
                          onTap: () => _openChatDialog(context, conv),
                        );
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error loading chats: $err')),
                  ),

                  // Tab 1: Announcements
                  announcementsAsync.when(
                    data: (announcements) => ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      itemCount: announcements.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ann = announcements[index];
                        return _AnnouncementCard(announcement: ann);
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error loading announcements: $err')),
                  ),

                  // Tab 2: Alerts
                  notificationsAsync.when(
                    data: (notifications) => ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Alerts',
                              style: AppTypography.headlineSm(color: AppColors.onSurface),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(chatRepositoryProvider).markNotificationsAsRead();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('All alerts marked as read')),
                                );
                              },
                              child: Text(
                                'Mark all as read',
                                style: AppTypography.labelMd(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final notif in notifications) ...[
                          _NotificationCard(notification: notif),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error loading alerts: $err')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? const [AppColors.softShadow] : null,
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMd(
                color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final ChatConversationEntity conversation;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return EduMeetCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: conversation.avatarUrl != null
                    ? NetworkImage(conversation.avatarUrl!)
                    : null,
                child: conversation.avatarUrl == null
                    ? const Icon(Icons.group, color: AppColors.primary)
                    : null,
              ),
              if (conversation.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.tertiary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        conversation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineSm(color: AppColors.onSurface).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      conversation.lastMessageTime,
                      style: AppTypography.labelSm(color: AppColors.outline),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  conversation.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (conversation.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${conversation.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (conversation.isPinned) ...[
                const SizedBox(height: 4),
                const Icon(Icons.push_pin_rounded, size: 16, color: AppColors.primary),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementEntity announcement;

  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    if (announcement.isPinned) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryFixed.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.campaign, size: 18, color: AppColors.onPrimary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PINNED ANNOUNCEMENT',
                      style: AppTypography.labelSm(color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  announcement.timeAgo,
                  style: AppTypography.labelSm(color: AppColors.outline),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              announcement.title,
              style: AppTypography.headlineSm(color: AppColors.onSurface).copyWith(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              announcement.content,
              style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  announcement.postedBy,
                  style: AppTypography.labelSm(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (announcement.actionLabel != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: () {},
                    child: Text(announcement.actionLabel!),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return EduMeetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event,
                      size: 18,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CAMPUS EVENT',
                    style: AppTypography.labelSm(color: AppColors.secondary).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                announcement.timeAgo,
                style: AppTypography.labelSm(color: AppColors.outline),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            announcement.title,
            style: AppTypography.headlineSm(color: AppColors.onSurface).copyWith(fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            announcement.content,
            style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                announcement.postedBy,
                style: AppTypography.labelSm(color: AppColors.secondary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (announcement.actionLabel != null)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () {},
                  child: Text(announcement.actionLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationAlertEntity notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color iconBg;
    IconData icon;

    switch (notification.type) {
      case 'assignment':
        borderColor = AppColors.primary;
        iconBg = AppColors.primaryFixed;
        icon = Icons.assignment_rounded;
        break;
      case 'live_class':
        borderColor = AppColors.secondary;
        iconBg = AppColors.secondaryFixed;
        icon = Icons.schedule_rounded;
        break;
      case 'forum':
      default:
        borderColor = AppColors.outlineVariant;
        iconBg = AppColors.surfaceContainer;
        icon = Icons.forum_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
        boxShadow: const [AppColors.softShadow],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.onSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification.title,
                      style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      notification.timeAgo,
                      style: AppTypography.labelSm(color: AppColors.outline),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: AppTypography.bodySm(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatDetailSheet extends ConsumerStatefulWidget {
  final ChatConversationEntity conversation;

  const _ChatDetailSheet({required this.conversation});

  @override
  ConsumerState<_ChatDetailSheet> createState() => _ChatDetailSheetState();
}

class _ChatDetailSheetState extends ConsumerState<_ChatDetailSheet> {
  final TextEditingController _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authNotifierProvider).user;
    final newMsg = ChatMessageEntity(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversation.id,
      senderId: user?.id ?? 'me',
      senderName: user?.displayName ?? 'You',
      senderRole: user?.role.displayName ?? 'Student',
      text: text,
      timestamp: DateTime.now(),
    );

    ref.read(chatRepositoryProvider).sendMessage(newMsg);
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesFamilyProvider(widget.conversation.id));
    final currentUserId = ref.watch(authNotifierProvider).user?.id ?? 'me';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.conversation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headlineSm(color: AppColors.onSurface).copyWith(fontSize: 16),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: AppColors.tertiary),
                          SizedBox(width: 4),
                          Text(
                            'Online',
                            style: TextStyle(fontSize: 11, color: AppColors.tertiary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == currentUserId || msg.senderRole == 'Student' && currentUserId.contains('sarah');
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16).copyWith(
                          topRight: isMe ? Radius.zero : const Radius.circular(16),
                          topLeft: !isMe ? Radius.zero : const Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Text(
                              msg.senderName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          Text(
                            msg.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: isMe ? AppColors.onPrimary : AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe
                                    ? AppColors.onPrimary.withValues(alpha: 0.7)
                                    : AppColors.outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.outline),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: AppTypography.bodySm(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, size: 18, color: AppColors.onPrimary),
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
