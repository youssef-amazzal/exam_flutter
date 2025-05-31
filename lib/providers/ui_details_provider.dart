import 'package:flutter/material.dart';

/// Provider for UI-only details not included in the core models
class UIDetailsProvider extends InheritedWidget {
  final Map<String, String> avatars = {};
  final Map<String, int> unreadCounts = {};

  UIDetailsProvider({
    Key? key,
    required Widget child,
    Map<String, String>? initialAvatars,
    Map<String, int>? initialUnreadCounts,
  }) : super(key: key, child: child) {
    if (initialAvatars != null) avatars.addAll(initialAvatars);
    if (initialUnreadCounts != null) unreadCounts.addAll(initialUnreadCounts);
  }

  String? getAvatarUrl(String conversationId) => 
      avatars[conversationId] ?? 'https://i.pravatar.cc/150?u=$conversationId';
  
  int getUnreadCount(String conversationId) => unreadCounts[conversationId] ?? 0;
  
  void setUnreadCount(String conversationId, int count) {
    unreadCounts[conversationId] = count;
  }
  
  void setAvatar(String conversationId, String url) {
    avatars[conversationId] = url;
  }

  static UIDetailsProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<UIDetailsProvider>();
    if (provider == null) {
      throw Exception('UIDetailsProvider not found in context');
    }
    return provider;
  }

  @override
  bool updateShouldNotify(UIDetailsProvider oldWidget) => true;
}
