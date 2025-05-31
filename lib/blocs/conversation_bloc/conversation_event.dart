part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversations extends ConversationEvent {
  final String? conversationId;
  final bool markAsRead;
  
  const LoadConversations({this.conversationId, this.markAsRead = false});

  @override
  List<Object?> get props => [conversationId, markAsRead];
}

class SendMessage extends ConversationEvent {
  final String conversationId;
  final String content;
  const SendMessage(this.conversationId, this.content);

  @override
  List<Object?> get props => [conversationId, content];
}

class ReceiveMessage extends ConversationEvent {
  final String conversationId;
  final String content;
  // Optional contactName to support creating new conversations
  final String? contactName;
  
  const ReceiveMessage(this.conversationId, this.content, {this.contactName});
  
  @override
  List<Object?> get props => [conversationId, content, contactName];
}