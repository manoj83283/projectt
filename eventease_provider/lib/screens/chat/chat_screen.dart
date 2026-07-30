import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message_model.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String userName;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.userName,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController
      _messageController =
      TextEditingController();

  final ScrollController
      _scrollController =
      ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  Future<void> _loadMessages() async {
    await context
        .read<ChatProvider>()
        .getMessages(widget.roomId);

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController
                .position.maxScrollExtent,
            duration: const Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  Future<void> _sendMessage() async {
    final text =
        _messageController.text.trim();

    if (text.isEmpty) return;

    _messageController.clear();

    final success = await context
        .read<ChatProvider>()
        .sendMessage(
          receiverId: widget.roomId,
          message: text,
        );

    if (success) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isMyMessage(
      ChatMessageModel message) {
    return message.isMine ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  Colors.blue.shade100,
              child: Text(
                widget.userName
                    .substring(0, 1)
                    .toUpperCase(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    widget.userName,
                    style:
                        const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.more_vert,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // =====================
          // CHAT MESSAGES
          // =====================

          Expanded(
            child:
                Consumer<ChatProvider>(
              builder: (
                context,
                provider,
                child,
              ) {
                if (provider.isLoading &&
                    provider.messages
                        .isEmpty) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (provider
                    .messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          Icons.chat,
                          size: 80,
                          color:
                              Colors.grey,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          'Start Conversation',
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller:
                      _scrollController,
                  padding:
                      const EdgeInsets
                          .all(16),
                  itemCount: provider
                      .messages.length,
                  itemBuilder:
                      (context, index) {
                    final message =
                        provider
                            .messages[index];

                    return Align(
                      alignment: _isMyMessage(
                              message)
                          ? Alignment
                              .centerRight
                          : Alignment
                              .centerLeft,
                      child: Container(
                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 10,
                        ),
                        constraints:
                            BoxConstraints(
                          maxWidth:
                              MediaQuery.of(
                                        context,
                                      )
                                      .size
                                      .width *
                                  0.75,
                        ),
                        padding:
                            const EdgeInsets
                                .all(12),
                        decoration:
                            BoxDecoration(
                          color: _isMyMessage(
                                  message)
                              ? Theme.of(
                                      context)
                                  .primaryColor
                              : Colors
                                  .grey
                                  .shade200,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            if ((message
                                        .message ??
                                    '')
                                .isNotEmpty)
                              Text(
                                message
                                        .message ??
                                    '',
                                style:
                                    TextStyle(
                                  color: _isMyMessage(
                                          message)
                                      ? Colors
                                          .white
                                      : Colors
                                          .black,
                                ),
                              ),

                            const SizedBox(
                              height: 4,
                            ),

                            Row(
                              mainAxisSize:
                                  MainAxisSize
                                      .min,
                              children: [
                                Text(
                                  message
                                          .createdAt ??
                                      '',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        10,
                                    color: _isMyMessage(
                                            message)
                                        ? Colors
                                            .white70
                                        : Colors
                                            .grey,
                                  ),
                                ),

                                if (_isMyMessage(
                                    message))
                                  const SizedBox(
                                    width: 4,
                                  ),

                                if (_isMyMessage(
                                    message))
                                  Icon(
                                    Icons
                                        .done_all,
                                    size: 14,
                                    color: message
                                                .isRead ==
                                            true
                                        ? Colors
                                            .lightBlueAccent
                                        : Colors
                                            .white70,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // =====================
          // MESSAGE INPUT
          // =====================

          SafeArea(
            top: false,
            child: Container(
              padding:
                  const EdgeInsets.all(12),
              decoration:
                  const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color:
                        Color(0xFFE0E0E0),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                    ),
                    onPressed: () {
                      // Upload File
                    },
                  ),

                  Expanded(
                    child: TextField(
                      controller:
                          _messageController,
                      textInputAction:
                          TextInputAction
                              .send,
                      onSubmitted:
                          (_) =>
                              _sendMessage(),
                      decoration:
                          InputDecoration(
                        hintText:
                            'Type a message...',
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        Theme.of(context)
                            .primaryColor,
                    child: IconButton(
                      onPressed:
                          _sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color:
                            Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}