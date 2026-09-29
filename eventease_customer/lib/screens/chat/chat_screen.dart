import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme_config.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
  });

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  String bookingId = '';
  String roomId = '';
  String receiverId = '';
  String receiverName = 'Service Provider';
  String receiverPhone = '';

  bool _argumentsLoaded = false;
  bool _isSending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argumentsLoaded) {
      return;
    }

    _argumentsLoaded = true;

    final arguments =
        ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      final map = arguments.map(
        (key, value) {
          return MapEntry(
            key.toString(),
            value,
          );
        },
      );

      bookingId =
          map['bookingId']?.toString().trim() ?? '';

      roomId =
          map['roomId']?.toString().trim() ??
              map['chatRoomId']?.toString().trim() ??
              '';

      receiverId =
          map['receiverId']?.toString().trim() ??
              map['providerId']?.toString().trim() ??
              '';

      receiverName =
          map['receiverName']?.toString().trim() ??
              map['providerName']?.toString().trim() ??
              'Service Provider';

      receiverPhone =
          map['receiverPhone']?.toString().trim() ??
              map['providerPhone']?.toString().trim() ??
              '';
    }

    if (roomId.isEmpty && bookingId.isNotEmpty) {
      roomId = 'booking:$bookingId';
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _initializeChat();
      },
    );
  }

  @override
  void dispose() {
    final provider = context.read<ChatProvider>();

    if (roomId.isNotEmpty) {
      provider.leaveRoom(roomId);
    }

    messageController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  Future<void> _initializeChat() async {
    if (!mounted) {
      return;
    }

    if (bookingId.isEmpty || roomId.isEmpty) {
      _showMessage(
        'Booking chat information is unavailable.',
        isError: true,
      );

      return;
    }

    final provider = context.read<ChatProvider>();

    provider.joinRoom(
      roomId: roomId,
      bookingId: bookingId,
    );

    await provider.loadRoomMessages(
      roomId: roomId,
      bookingId: bookingId,
    );

    if (!mounted) {
      return;
    }

    await provider.markRoomAsRead(
      roomId: roomId,
      bookingId: bookingId,
    );

    _scrollToBottom();
  }

  Future<void> _refreshMessages() async {
    if (roomId.isEmpty || bookingId.isEmpty) {
      return;
    }

    final provider = context.read<ChatProvider>();

    await provider.loadRoomMessages(
      roomId: roomId,
      bookingId: bookingId,
      showLoading: false,
    );

    if (!mounted) {
      return;
    }

    await provider.markRoomAsRead(
      roomId: roomId,
      bookingId: bookingId,
    );

    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    if (_isSending) {
      return;
    }

    final message =
        messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    if (bookingId.isEmpty ||
        roomId.isEmpty ||
        receiverId.isEmpty) {
      _showMessage(
        'Unable to send the message because chat information is incomplete.',
        isError: true,
      );

      return;
    }

    setState(() {
      _isSending = true;
    });

    messageController.clear();

    try {
      final success = await context
          .read<ChatProvider>()
          .sendRoomMessage(
            bookingId: bookingId,
            roomId: roomId,
            receiverId: receiverId,
            message: message,
          );

      if (!mounted) {
        return;
      }

      if (!success) {
        messageController.text = message;

        final error =
            context.read<ChatProvider>().error;

        _showMessage(
          error?.trim().isNotEmpty == true
              ? error!
              : 'Unable to send the message.',
          isError: true,
        );

        return;
      }

      _scrollToBottom();
    } catch (error) {
      if (mounted) {
        messageController.text = message;

        _showMessage(
          error.toString(),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _callProvider() async {
    final normalizedPhone =
        receiverPhone.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );

    if (normalizedPhone.isEmpty) {
      _showMessage(
        'Provider phone number is unavailable.',
        isError: true,
      );

      return;
    }

    final uri = Uri(
      scheme: 'tel',
      path: normalizedPhone,
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage(
          'Unable to open the phone application.',
          isError: true,
        );
      }
    } catch (_) {
      _showMessage(
        'Unable to open the phone application.',
        isError: true,
      );
    }
  }

  void _handleTypingChanged(
    String value,
  ) {
    if (roomId.isEmpty || bookingId.isEmpty) {
      return;
    }

    final provider = context.read<ChatProvider>();

    if (value.trim().isEmpty) {
      provider.stopTyping(
        roomId: roomId,
        bookingId: bookingId,
        receiverId: receiverId,
      );

      return;
    }

    provider.startTyping(
      roomId: roomId,
      bookingId: bookingId,
      receiverId: receiverId,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!scrollController.hasClients) {
          return;
        }

        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(
            milliseconds: 300,
          ),
          curve: Curves.easeOut,
        );
      },
    );
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _formatMessageTime(
    DateTime? dateTime,
  ) {
    if (dateTime == null) {
      return '';
    }

    final localTime = dateTime.toLocal();

    final hour = localTime.hour;
    final minute =
        localTime.minute.toString().padLeft(
              2,
              '0',
            );

    final period =
        hour >= 12 ? 'PM' : 'AM';

    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;

    return '$displayHour:$minute $period';
  }

  String _formatDateSeparator(
    DateTime dateTime,
  ) {
    final date = dateTime.toLocal();
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final messageDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference =
        today.difference(messageDate).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  bool _showDateSeparator(
    int index,
    List<dynamic> messages,
  ) {
    if (index == 0) {
      return true;
    }

    final currentDate =
        messages[index].createdAt?.toLocal();

    final previousDate =
        messages[index - 1].createdAt?.toLocal();

    if (currentDate == null ||
        previousDate == null) {
      return false;
    }

    return currentDate.year != previousDate.year ||
        currentDate.month != previousDate.month ||
        currentDate.day != previousDate.day;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        final messages = provider.messages;

        if (messages.isNotEmpty) {
          _scrollToBottom();
        }

        return Scaffold(
          backgroundColor:
              const Color(0xFFF8F9FC),
          appBar: AppBar(
            elevation: 0,
            titleSpacing: 8,
            title: Row(
              children: [
                const CircleAvatar(
                  child: Icon(
                    Icons.person,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiverName.isEmpty
                            ? 'Service Provider'
                            : receiverName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      Text(
                        provider.isOtherUserTyping
                            ? 'Typing...'
                            : provider.isConnected
                                ? 'Online'
                                : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              provider.isOtherUserTyping
                                  ? Colors.green
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: provider.isLoading
                    ? null
                    : _refreshMessages,
                icon: const Icon(
                  Icons.refresh,
                ),
              ),
              IconButton(
                tooltip: 'Call Provider',
                onPressed: _callProvider,
                icon: const Icon(
                  Icons.call,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              if (bookingId.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: ThemeConfig.primaryColor
                      .withOpacity(0.08),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color:
                            ThemeConfig.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Booking-specific secure chat',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                ThemeConfig.primaryColor,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _buildMessagesArea(
                  provider,
                  messages,
                ),
              ),
              _buildMessageInput(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessagesArea(
    ChatProvider provider,
    List<dynamic> messages,
  ) {
    if (provider.isLoading &&
        messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null &&
        provider.error!.trim().isNotEmpty &&
        messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshMessages,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                      0.55,
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.error!,
                        textAlign:
                            TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed:
                            _refreshMessages,
                        icon: const Icon(
                          Icons.refresh,
                        ),
                        label: const Text(
                          'Try Again',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshMessages,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                      0.55,
              child: const Center(
                child: Padding(
                  padding:
                      EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 55,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Send a message to your service provider.',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMessages,
      child: ListView.builder(
        controller: scrollController,
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          12,
        ),
        itemCount: messages.length,
        itemBuilder: (
          context,
          index,
        ) {
          final message = messages[index];

          final isMe = message.isMine == true;

          final createdAt =
              message.createdAt as DateTime?;

          return Column(
            children: [
              if (_showDateSeparator(
                index,
                messages,
              ))
                _buildDateSeparator(
                  _formatDateSeparator(
                    createdAt ??
                        DateTime.now(),
                  ),
                ),
              _buildMessageBubble(
                message: message,
                isMe: isMe,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateSeparator(
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Divider(),
          ),
          Container(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
          const Expanded(
            child: Divider(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required dynamic message,
    required bool isMe,
  }) {
    final messageText =
        message.message?.toString() ?? '';

    final createdAt =
        message.createdAt as DateTime?;

    final isRead = message.isRead == true;

    final delivered =
        message.delivered == true;

    return Align(
      alignment: isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 8,
        ),
        padding: const EdgeInsets.fromLTRB(
          13,
          10,
          10,
          7,
        ),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
                  0.76,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? ThemeConfig.primaryColor
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft:
                const Radius.circular(16),
            topRight:
                const Radius.circular(16),
            bottomLeft: Radius.circular(
              isMe ? 16 : 4,
            ),
            bottomRight: Radius.circular(
              isMe ? 4 : 16,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                messageText,
                style: TextStyle(
                  color: isMe
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(
                    createdAt,
                  ),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white70
                        : Colors.grey,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead
                        ? Icons.done_all
                        : delivered
                            ? Icons.done_all
                            : Icons.done,
                    size: 15,
                    color: isRead
                        ? Colors.lightBlueAccent
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    ChatProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        10,
        8,
        10,
        10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                enabled: !_isSending,
                minLines: 1,
                maxLines: 5,
                maxLength: 5000,
                textCapitalization:
                    TextCapitalization.sentences,
                textInputAction:
                    TextInputAction.newline,
                onChanged:
                    _handleTypingChanged,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: provider.isConnected
                      ? 'Type a message...'
                      : 'Type a message...',
                  filled: true,
                  fillColor:
                      Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(26),
                    borderSide:
                        BorderSide.none,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(26),
                    borderSide:
                        BorderSide.none,
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(26),
                    borderSide:
                        const BorderSide(
                      color:
                          ThemeConfig.primaryColor,
                    ),
                  ),
                ),
                onSubmitted: (_) {
                  _sendMessage();
                },
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 23,
              backgroundColor:
                  ThemeConfig.primaryColor,
              child: _isSending
                  ? const Padding(
                      padding:
                          EdgeInsets.all(12),
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : IconButton(
                      tooltip: 'Send',
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}