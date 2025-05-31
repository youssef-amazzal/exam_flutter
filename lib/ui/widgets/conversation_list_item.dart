import 'package:exam_flutter/models/conversation_model.dart';
import 'package:exam_flutter/providers/ui_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get avatar and unread count from provider
    final uiProvider = UIDetailsProvider.of(context);
    final avatarUrl = uiProvider.getAvatarUrl(conversation.id);
    final unreadCount = uiProvider.getUnreadCount(conversation.id);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Text(conversation.contactName[0].toUpperCase())
            : null,
      ),
      title: Text(conversation.contactName, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormat.jm().format(conversation.timestamp), // Short time
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ]
        ],
      ),
      onTap: onTap,
    );
  }
}
