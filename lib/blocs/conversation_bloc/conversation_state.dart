part of 'conversation_bloc.dart';

enum DataStatus { initial, loading, success, failure, sending }

class ConversationState extends Equatable {
  const ConversationState({
    this.conversations = const [],
    this.conversationListStatus = DataStatus.initial,
    this.activeConversationMessages = const [],
    this.activeConversationId,
    this.messageListStatus = DataStatus.initial,
    this.sendMessageStatus = DataStatus.initial,
    this.error,
  });

  final List<Conversation> conversations;
  final DataStatus conversationListStatus;

  final List<Message> activeConversationMessages;
  final String? activeConversationId;
  final DataStatus messageListStatus;
  final DataStatus sendMessageStatus;

  final String? error;

  ConversationState copyWith({
    List<Conversation>? conversations,
    DataStatus? conversationListStatus,
    List<Message>? activeConversationMessages,
    String? activeConversationId,
    // Helper to explicitly set activeConversationId to null if needed
    bool clearActiveConversation = false,
    DataStatus? messageListStatus,
    DataStatus? sendMessageStatus,
    String? error,
    // Helper to explicitly set error to null if needed
    bool clearError = false,
  }) {
    return ConversationState(
      conversations: conversations ?? this.conversations,
      conversationListStatus: conversationListStatus ?? this.conversationListStatus,
      activeConversationMessages: activeConversationMessages ?? this.activeConversationMessages,
      activeConversationId: clearActiveConversation ? null : (activeConversationId ?? this.activeConversationId),
      messageListStatus: messageListStatus ?? this.messageListStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        conversations,
        conversationListStatus,
        activeConversationMessages,
        activeConversationId,
        messageListStatus,
        sendMessageStatus,
        error,
      ];
}