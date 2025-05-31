import 'package:exam_flutter/blocs/conversation_bloc/conversation_bloc.dart';
import 'package:exam_flutter/ui/screens/chat_detail_screen.dart';
import 'package:exam_flutter/ui/widgets/conversation_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_flutter/repositories/mock_chat_repository.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  static const String routeName = '/';

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  @override
  void initState() {
    super.initState();
    // Load conversations when the screen is initialized
    context.read<ConversationBloc>().add(LoadConversations());
  }

  Future<void> _showCreateConversationDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Create New Conversation'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Contact Name"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // Use ReceiveMessage with contactName to create a new conversation
                  context.read<ConversationBloc>().add(
                    ReceiveMessage('', 'Conversation started', contactName: nameController.text)
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the actual repository from the provider
    final repository = RepositoryProvider.of<MockChatRepository>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: BlocConsumer<ConversationBloc, ConversationState>(
        listener: (context, state) {
          if (state.conversationListStatus == DataStatus.failure && state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
          }
          // If a new conversation was created and selected, navigate
          if (state.messageListStatus == DataStatus.loading && state.activeConversationId != null) {
             final conversation = state.conversations.firstWhere((c) => c.id == state.activeConversationId, orElse: () => state.conversations.first); // fallback
            if (ModalRoute.of(context)?.settings.name != ChatDetailScreen.routeName) {
                 Navigator.of(context).pushNamed(
                  ChatDetailScreen.routeName,
                  arguments: conversation,
                );
            }
          }
        },
        builder: (context, state) {
          if (state.conversationListStatus == DataStatus.loading && state.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.conversationListStatus == DataStatus.success || state.conversations.isNotEmpty) {
            if (state.conversations.isEmpty) {
              return const Center(child: Text('No conversations yet. Create one!'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                 context.read<ConversationBloc>().add(LoadConversations());
              },
              child: ListView.builder(
                itemCount: state.conversations.length,
                itemBuilder: (context, index) {
                  final conversation = state.conversations[index];
                  return ConversationListItem(
                    conversation: conversation,
                    onTap: () {
                      context.read<ConversationBloc>().add(
                        LoadConversations(
                          conversationId: conversation.id,
                          markAsRead: true
                        )
                      );
                      Navigator.of(context).pushNamed(
                        ChatDetailScreen.routeName,
                        arguments: conversation,
                      );
                    }, 
                  );
                },
              ),
            );
          }
          return const Center(child: Text('Something went wrong or no data.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateConversationDialog(context),
        tooltip: 'New Conversation',
        child: const Icon(Icons.add_comment_outlined),
      ),
    );
  }
}
