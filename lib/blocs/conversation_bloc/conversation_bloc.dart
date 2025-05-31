import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_flutter/models/conversation_model.dart';
import 'package:exam_flutter/models/message_model.dart';
import 'package:exam_flutter/repositories/mock_chat_repository.dart';
import 'package:equatable/equatable.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final MockChatRepository _chatRepository;

  ConversationBloc({required MockChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ConversationState()) {
    on<LoadConversations>(_onLoadConversations);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    // Handle general conversation loading
    if (event.conversationId == null) {
      emit(state.copyWith(conversationListStatus: DataStatus.loading));
      try {
        final conversations = await _chatRepository.getConversations();
        emit(state.copyWith(
          conversations: conversations,
          conversationListStatus: DataStatus.success,
        ));
      } catch (e) {
        emit(state.copyWith(conversationListStatus: DataStatus.failure, error: e.toString()));
      }
    } 
    // Handle selecting a specific conversation (previously SelectConversation)
    else {
      emit(state.copyWith(
        activeConversationId: event.conversationId,
        messageListStatus: DataStatus.loading,
        activeConversationMessages: [], // Clear previous messages
      ));
      
      try {
        final messages = await _chatRepository.getMessages(event.conversationId!);
        emit(state.copyWith(
          activeConversationMessages: messages,
          messageListStatus: DataStatus.success,
        ));
        
        // Mark as read if requested
        if (event.markAsRead) {
          await _chatRepository.markConversationAsRead(event.conversationId!);
          final conversations = await _chatRepository.getConversations();
          emit(state.copyWith(conversations: conversations));
        }
      } catch (e) {
        emit(state.copyWith(messageListStatus: DataStatus.failure, error: e.toString()));
      }
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(sendMessageStatus: DataStatus.sending));
    try {
      final newMessage = await _chatRepository.sendMessage(event.conversationId, event.content, true);
      // Update message list for active chat
      final updatedMessages = List<Message>.from(state.activeConversationMessages)..add(newMessage);
      emit(state.copyWith(
          activeConversationMessages: updatedMessages,
          sendMessageStatus: DataStatus.success,
          clearError: true
      ));
      
      // Refresh conversation list to show updated last message and timestamp
      final conversations = await _chatRepository.getConversations();
      emit(state.copyWith(conversations: conversations, conversationListStatus: DataStatus.success));

    } catch (e) {
      emit(state.copyWith(sendMessageStatus: DataStatus.failure, error: e.toString()));
    }
  }
  
  Future<void> _onReceiveMessage(
    ReceiveMessage event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      // Handle creating a new conversation if contactName is provided
      if (event.contactName != null) {
        emit(state.copyWith(conversationListStatus: DataStatus.loading));
        
        final newConversation = await _chatRepository.createConversation(event.contactName!);
        final updatedConversations = List<Conversation>.from(state.conversations)..insert(0, newConversation);
        
        emit(state.copyWith(
          conversations: updatedConversations,
          conversationListStatus: DataStatus.success,
          activeConversationId: newConversation.id,
          messageListStatus: DataStatus.loading,
        ));
        
        // Load messages for the new conversation
        add(LoadConversations(conversationId: newConversation.id));
        return;
      }
      
      // Handle receiving a message in an existing conversation
      final receivedMessage = await _chatRepository.sendMessage(event.conversationId, event.content, false);
      
      if (state.activeConversationId == event.conversationId) {
        final updatedMessages = List<Message>.from(state.activeConversationMessages)..add(receivedMessage);
        emit(state.copyWith(
          activeConversationMessages: updatedMessages,
        ));
      }
      
      final conversations = await _chatRepository.getConversations();
      emit(state.copyWith(conversations: conversations, conversationListStatus: DataStatus.success));

    } catch (e) {
      // Handle error silently
    }
  }
}
