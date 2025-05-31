import 'package:exam_flutter/blocs/conversation_bloc/conversation_bloc.dart';
import 'package:exam_flutter/models/conversation_model.dart';
import 'package:exam_flutter/providers/ui_details_provider.dart';
import 'package:exam_flutter/repositories/mock_chat_repository.dart';
import 'package:exam_flutter/ui/screens/chat_detail_screen.dart';
import 'package:exam_flutter/ui/screens/conversation_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize repository and UI details
    final chatRepository = MockChatRepository();

    // Create initial UI details from repository data
    final Map<String, String> initialAvatars = {};
    final Map<String, int> initialUnreadCounts = {};

    // Set up these maps from repository data
    chatRepository.getConversations().then((conversations) {
      for (final convo in conversations) {
        initialAvatars[convo.id] =
            'https://i.pravatar.cc/150?u=${convo.contactName.toLowerCase()}';
        initialUnreadCounts[convo.id] = 0; // Default to 0
      }
    });

    return RepositoryProvider.value(
      value: chatRepository,
      child: UIDetailsProvider(
        initialAvatars: initialAvatars,
        initialUnreadCounts: initialUnreadCounts,
        child: BlocProvider(
          create: (context) => ConversationBloc(chatRepository: chatRepository),
          child: MaterialApp(
            title: 'Chat App BLoC',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
              ),
              useMaterial3: true,
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: ConversationListScreen.routeName,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case ConversationListScreen.routeName:
                  return MaterialPageRoute(
                      builder: (_) => const ConversationListScreen());
                case ChatDetailScreen.routeName:
                  final conversation = settings.arguments as Conversation;
                  return MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(conversation: conversation));
                default:
                  return MaterialPageRoute(
                      builder: (_) => const ConversationListScreen());
              }
            },
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat App - Phase 0')),
      body: const Center(
        child: Text(
          'Project Setup Complete!\nReady for Phase 1.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
