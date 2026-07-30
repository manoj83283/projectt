import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../chat/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() =>
      _ChatListScreenState();
}

class _ChatListScreenState
    extends State<ChatListScreen> {
  final TextEditingController
      _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadChats();
    });
  }

  Future<void> _loadChats() async {
    await context
        .read<ChatProvider>()
        .getChatRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          return Column(
            children: [
              // ======================
              // SEARCH
              // ======================

              Padding(
                padding:
                    const EdgeInsets.all(16),
                child: TextField(
                  controller:
                      _searchController,
                  decoration:
                      InputDecoration(
                    hintText:
                        'Search chats...',
                    prefixIcon:
                        const Icon(
                      Icons.search,
                    ),
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),

              // ======================
              // UNREAD SUMMARY
              // ======================

              Container(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                padding:
                    const EdgeInsets.all(12),
                decoration:
                    BoxDecoration(
                  color: Theme.of(
                    context,
                  ).primaryColor.withOpacity(
                        0.08,
                      ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mark_chat_unread,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Unread Messages: ${provider.unreadCount}',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ======================
              // CHAT LIST
              // ======================

              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : provider.chatRooms
                            .isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh:
                                _loadChats,
                            child:
                                ListView.builder(
                              padding:
                                  const EdgeInsets
                                      .all(
                                16,
                              ),
                              itemCount:
                                  provider
                                      .chatRooms
                                      .length,
                              itemBuilder:
                                  (
                                context,
                                index,
                              ) {
                                final room =
                                    provider
                                            .chatRooms[
                                        index];

                                return _chatCard(
                                  context,
                                  room,
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'No Chats Available',
          ),
        ],
      ),
    );
  }

  Widget _chatCard(
    BuildContext context,
    dynamic room,
  ) {
    final String roomId =
        room['id'] ?? '';

    final String userName =
        room['userName'] ??
            'Customer';

    final String lastMessage =
        room['lastMessage'] ??
            'Start Conversation';

    final String lastMessageTime =
        room['lastMessageTime'] ??
            '';

    final int unreadCount =
        room['unreadCount'] ?? 0;

    final String? profileImage =
        room['profileImage'];

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 26,
          backgroundImage:
              profileImage != null
                  ? NetworkImage(
                      profileImage,
                    )
                  : null,
          child: profileImage == null
              ? Text(
                  userName
                      .substring(0, 1)
                      .toUpperCase(),
                )
              : null,
        ),
        title: Text(
          userName,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              lastMessageTime,
              style:
                  const TextStyle(
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 5),
            if (unreadCount > 0)
              CircleAvatar(
                radius: 10,
                backgroundColor:
                    Colors.red,
                child: Text(
                  unreadCount
                      .toString(),
                  style:
                      const TextStyle(
                    fontSize: 10,
                    color:
                        Colors.white,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChatScreen(
                roomId: roomId,
                userName: userName,
              ),
            ),
          );
        },
      ),
    );
  }
}