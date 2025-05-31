import 'dart:async';
import 'package:exam_flutter/models/conversation_model.dart';
import 'package:exam_flutter/models/message_model.dart';
import 'package:exam_flutter/utils/id_generator.dart';

class MockChatRepository {
  List<Conversation> _conversations = [];
  Map<String, List<Message>> _messages = {};
  // Store avatar URLs separately since they're not in the model
  final Map<String, String> _avatars = {};
  // Store unread counts separately
  final Map<String, int> _unreadCounts = {};

  MockChatRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final convo1Id = generateId();
    final convo2Id = generateId();
    final convo3Id = generateId();

    _conversations = [
      Conversation(
        id: convo1Id,
        contactName: 'Mohammed',
        lastMessage: 'Hey, how are you?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Conversation(
        id: convo2Id,
        contactName: 'Fatima',
        lastMessage: 'See you tomorrow!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Conversation(
        id: convo3Id,
        contactName: 'Rachid',
        lastMessage: 'Okay, sounds good.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    
    // Set avatars separately
    _avatars[convo1Id] = 'https://i.pravatar.cc/150?u=alice';
    _avatars[convo2Id] = 'https://i.pravatar.cc/150?u=bob';
    _avatars[convo3Id] = 'https://i.pravatar.cc/150?u=charlie';
    
    // Set unread counts
    _unreadCounts[convo1Id] = 2;
    _unreadCounts[convo2Id] = 0;
    _unreadCounts[convo3Id] = 0;
    
    // Create and add messages to the map
    final messages1 = <Message>[
      Message(
        id: generateId(), 
        conversationId: convo1Id, 
        content: 'Hi there!', 
        isMe: false, 
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Message(
        id: generateId(), 
        conversationId: convo1Id, 
        content: 'Hello!', 
        isMe: true, 
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      Message(
        id: generateId(), 
        conversationId: convo1Id, 
        content: 'Hey, how are you?', 
        isMe: false, 
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];

    final messages2 = <Message>[
      Message(
        id: generateId(), 
        conversationId: convo2Id, 
        content: 'Project update?', 
        isMe: true, 
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Message(
        id: generateId(), 
        conversationId: convo2Id, 
        content: 'Almost done, will send it by EOD.', 
        isMe: false, 
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      Message(
        id: generateId(), 
        conversationId: convo2Id, 
        content: 'See you tomorrow!', 
        isMe: true, 
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    final messages3 = <Message>[
      Message(
        id: generateId(), 
        conversationId: convo3Id, 
        content: 'Okay, sounds good.', 
        isMe: true, 
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // Add messages to the map
    _messages = {
      convo1Id: messages1,
      convo2Id: messages2,
      convo3Id: messages3,
    };

    // Sort messages by timestamp
    for (final messageList in _messages.values) {
      messageList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
  }

  String? getAvatarUrl(String conversationId) {
    return _avatars[conversationId];
  }
  
  int getUnreadCount(String conversationId) {
    return _unreadCounts[conversationId] ?? 0;
  }

  Future<List<Conversation>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    _conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List<Conversation>.from(_conversations);
  }

  Future<List<Message>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return List<Message>.from(_messages[conversationId] ?? []);
  }

  Future<Message> sendMessage(String conversationId, String content, bool isMe) async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate network delay
    final message = Message(
      id: generateId(),
      conversationId: conversationId,
      content: content,
      isMe: isMe,
      timestamp: DateTime.now(),
    );

    if (_messages.containsKey(conversationId)) {
      _messages[conversationId]!.add(message);
    } else {
      _messages[conversationId] = [message];
    }
    
    // Sort messages by timestamp
    _messages[conversationId]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Update conversation's last message and timestamp
    final convoIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (convoIndex != -1) {
      var convo = _conversations[convoIndex];
      _conversations[convoIndex] = convo.copyWith(
        lastMessage: content,
        timestamp: message.timestamp,
      );
      
      // Update unread count separately
      if (!isMe) {
        _unreadCounts[conversationId] = (_unreadCounts[conversationId] ?? 0) + 1;
      }
    }
    
    _conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return message;
  }

  Future<Conversation> createConversation(String contactName) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = generateId();
    final newConversation = Conversation(
      id: id,
      contactName: contactName,
      lastMessage: 'Conversation started',
      timestamp: DateTime.now(),
    );
    
    _conversations.add(newConversation);
    
    // Set avatar separately
    _avatars[id] = 'https://i.pravatar.cc/150?u=${contactName.toLowerCase()}';
    
    // Initialize unread count
    _unreadCounts[id] = 0;
    
    final initialMessage = Message(
      id: generateId(),
      conversationId: newConversation.id,
      content: 'Conversation started',
      isMe: false,
      timestamp: DateTime.now(),
    );
    
    _messages[newConversation.id] = [initialMessage];
    _conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return newConversation;
  }

  Future<void> markConversationAsRead(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _unreadCounts[conversationId] = 0;
  }
}