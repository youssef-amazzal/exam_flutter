import 'package:exam_flutter/blocs/conversation_bloc/conversation_bloc.dart';
import 'package:exam_flutter/models/conversation_model.dart';
import 'package:exam_flutter/ui/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.conversation});

  final Conversation conversation;
  static const String routeName = '/chat-detail';

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ConversationBloc>();
    if (bloc.state.activeConversationId != widget.conversation.id || 
        bloc.state.messageListStatus != DataStatus.success) {
      bloc.add(LoadConversations(
        conversationId: widget.conversation.id,
        markAsRead: true
      ));
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final text = _messageController.text.trim();
      context.read<ConversationBloc>().add(
        SendMessage(widget.conversation.id, text),
      );
      _messageController.clear();
      
      // Simulate receiving a reply after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          context.read<ConversationBloc>().add(
            ReceiveMessage(widget.conversation.id, "Got it! You said: '$text'"),
          );
        }
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.contactName),
      ),
      body: BlocConsumer<ConversationBloc, ConversationState>(
        listener: (context, state) {
          if (state.sendMessageStatus == DataStatus.failure && state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text('Send Error: ${state.error}')));
          }
          if (state.messageListStatus == DataStatus.success || state.sendMessageStatus == DataStatus.success) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: state.messageListStatus == DataStatus.loading && state.activeConversationMessages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.activeConversationMessages.isEmpty
                        ? const Center(child: Text('No messages yet. Say hi!'))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(8.0),
                            itemCount: state.activeConversationMessages.length,
                            itemBuilder: (context, index) {
                              final message = state.activeConversationMessages[index];
                              return MessageBubble(message: message);
                            },
                          ),
              ),
              _buildMessageInput(context, state.sendMessageStatus),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, DataStatus sendStatus) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          sendStatus == DataStatus.sending
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
