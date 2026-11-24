import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message_model.dart';
import '../../providers/chat_provider.dart';

// =====================================================
// CHAT SCREEN
//
// FINAL CHAT CONTRACT
//
// roomId
//   -> conversation / Socket.IO room
//   -> booking:<bookingId>
//   -> negotiation:<conversationId>
//
// receiverId
//   -> actual Customer MongoDB user ID
//
// receiverName
//   -> Customer display name
//
// bookingId
//   -> optional
//   -> Booking Chat only
//
// serviceId
//   -> service context
//
// negotiationMode
//   -> true for pre-booking negotiation
//   -> false for Booking Chat
//
// IMPORTANT:
//
// roomId and receiverId are NEVER interchangeable.
// =====================================================

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String receiverId;
  final String receiverName;

  final String? bookingId;
  final String? serviceId;

  final bool negotiationMode;
  final bool readOnly;

  final String topic;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.receiverId,
    required this.receiverName,
    this.bookingId,
    this.serviceId,
    this.negotiationMode = false,
    this.readOnly = false,
    this.topic = 'general',
  });

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  ChatProvider? _chatProvider;

  bool _isInitializing = false;
  bool _isSending = false;

  // =====================================================
  // NORMALIZED VALUES
  // =====================================================

  String get _roomId {
    return widget.roomId.trim();
  }

  String get _receiverId {
    return widget.receiverId.trim();
  }

  String get _receiverName {
    final value =
        widget.receiverName.trim();

    return value.isEmpty
        ? 'Customer'
        : value;
  }

  String get _bookingId {
    return widget.bookingId?.trim() ?? '';
  }

  String get _serviceId {
    return widget.serviceId?.trim() ?? '';
  }

  bool get _canSendMessage {
    return !widget.readOnly &&
        _roomId.isNotEmpty &&
        _receiverId.isNotEmpty;
  }

  // =====================================================
  // LIFECYCLE
  // =====================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _initializeChat();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _chatProvider ??=
        context.read<ChatProvider>();
  }

  @override
  void dispose() {
    final provider =
        _chatProvider;

    if (provider != null &&
        _roomId.isNotEmpty) {
      try {
        provider.stopTyping(
          roomId: _roomId,
          bookingId: _bookingId,
          receiverId: _receiverId,
        );
      } catch (error) {
        debugPrint(
          'STOP TYPING CLEANUP ERROR: $error',
        );
      }

      try {
        provider.leaveRoom(
          _roomId,
        );
      } catch (error) {
        debugPrint(
          'LEAVE CHAT ROOM ERROR: $error',
        );
      }
    }

    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // =====================================================
  // INITIALIZE CHAT
  // =====================================================

  Future<void> _initializeChat() async {
    if (!mounted ||
        _isInitializing) {
      return;
    }

    if (_roomId.isEmpty) {
      _showMessage(
        'Chat room is unavailable.',
        isError: true,
      );

      return;
    }

    if (_receiverId.isEmpty) {
      _showMessage(
        'Customer information is unavailable.',
        isError: true,
      );

      return;
    }

    final provider =
        _chatProvider ??
        context.read<ChatProvider>();

    _chatProvider =
        provider;

    setState(() {
      _isInitializing = true;
    });

    try {
      bool opened;

      // =================================================
      // NEGOTIATION CHAT
      // =================================================

      if (widget.negotiationMode) {
        if (_serviceId.isEmpty) {
          _showMessage(
            'Service information is unavailable for this negotiation.',
            isError: true,
          );

          return;
        }

        /*
         * PRE-BOOKING NEGOTIATION
         *
         * roomId:
         * negotiation:<conversationId>
         *
         * receiverId:
         * Customer MongoDB user ID
         *
         * bookingId:
         * NOT REQUIRED
         */

        opened =
            await provider.openNegotiation(
          roomId: _roomId,
          serviceId: _serviceId,
          customerId: _receiverId,
          topic: widget.topic,
        );
      } else {
        // =================================================
        // BOOKING CHAT
        // =================================================

        if (_bookingId.isEmpty) {
          _showMessage(
            'Booking information is unavailable.',
            isError: true,
          );

          return;
        }

        /*
         * BOOKING CHAT
         *
         * roomId:
         * booking:<bookingId>
         *
         * receiverId:
         * Customer MongoDB user ID
         */

        opened =
            await provider.openBookingChat(
          bookingId: _bookingId,
          roomId: _roomId,
          customerId: _receiverId,
          serviceId:
              _serviceId.isEmpty
                  ? null
                  : _serviceId,
        );
      }

      if (!mounted) {
        return;
      }

      if (!opened) {
        _showMessage(
          provider.errorMessage ??
              'Unable to open chat.',
          isError: true,
        );

        return;
      }

      await provider.markRoomAsRead(
        _roomId,
      );

      if (!mounted) {
        return;
      }

      _scrollToBottom();
    } catch (error, stackTrace) {
      debugPrint(
        'PROVIDER CHAT INITIALIZATION ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      if (mounted) {
        _showMessage(
          'Unable to initialize chat.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      } else {
        _isInitializing = false;
      }
    }
  }

  // =====================================================
  // REFRESH MESSAGES
  // =====================================================

  Future<void> _refreshMessages() async {
    if (!mounted ||
        _roomId.isEmpty) {
      return;
    }

    final provider =
        _chatProvider ??
        context.read<ChatProvider>();

    _chatProvider =
        provider;

    try {
      await provider.loadMessages(
        roomId: _roomId,
        showLoading: false,
      );

      if (!mounted) {
        return;
      }

      await provider.markRoomAsRead(
        _roomId,
      );

      if (!mounted) {
        return;
      }

      _scrollToBottom();
    } catch (error, stackTrace) {
      debugPrint(
        'PROVIDER CHAT REFRESH ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );
    }
  }

  // =====================================================
  // SEND MESSAGE
  // =====================================================

  Future<void> _sendMessage() async {
    if (!mounted ||
        _isSending ||
        !_canSendMessage) {
      return;
    }

    final message =
        _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    if (_roomId.isEmpty) {
      _showMessage(
        'Chat room is unavailable.',
        isError: true,
      );

      return;
    }

    if (_receiverId.isEmpty) {
      _showMessage(
        'Customer information is unavailable.',
        isError: true,
      );

      return;
    }

    setState(() {
      _isSending = true;
    });

    _messageController.clear();

    try {
      final provider =
          _chatProvider ??
          context.read<ChatProvider>();

      _chatProvider =
          provider;

      // =================================================
      // FINAL SEND CONTRACT
      //
      // IMPORTANT:
      //
      // roomId != receiverId
      //
      // Never:
      //
      // receiverId: widget.roomId
      //
      // Correct:
      //
      // roomId: widget.roomId
      // receiverId: widget.receiverId
      // =================================================

      final success =
          await provider.sendMessage(
        roomId: _roomId,
        receiverId: _receiverId,
        message: message,
        bookingId:
            _bookingId.isEmpty
                ? null
                : _bookingId,
        serviceId:
            _serviceId.isEmpty
                ? null
                : _serviceId,
        negotiationMode:
            widget.negotiationMode,
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        _messageController.text =
            message;

        _showMessage(
          provider.errorMessage ??
              'Unable to send the message.',
          isError: true,
        );

        return;
      }

      provider.stopTyping(
        roomId: _roomId,
        bookingId: _bookingId,
        receiverId: _receiverId,
      );

      _scrollToBottom();
    } catch (error, stackTrace) {
      debugPrint(
        'PROVIDER SEND CHAT ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      if (mounted) {
        _messageController.text =
            message;

        _showMessage(
          error
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              ),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      } else {
        _isSending = false;
      }
    }
  }

  // =====================================================
  // TYPING
  // =====================================================

  void _handleTyping(
    String value,
  ) {
    if (!_canSendMessage ||
        _roomId.isEmpty ||
        _receiverId.isEmpty) {
      return;
    }

    final provider =
        _chatProvider ??
        context.read<ChatProvider>();

    _chatProvider =
        provider;

    if (value.trim().isEmpty) {
      provider.stopTyping(
        roomId: _roomId,
        bookingId: _bookingId,
        receiverId: _receiverId,
      );

      return;
    }

    provider.startTyping(
      roomId: _roomId,
      bookingId: _bookingId,
      receiverId: _receiverId,
    );
  }

  // =====================================================
  // MESSAGE OWNERSHIP
  // =====================================================

  bool _isMyMessage(
    ChatMessageModel message,
  ) {
    return message.isMine ??
        false;
  }

  // =====================================================
  // MESSAGE TIME
  // =====================================================

  String _formatMessageTime(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    DateTime? dateTime;

    if (value is DateTime) {
      dateTime = value;
    } else {
      dateTime =
          DateTime.tryParse(
        value.toString(),
      );
    }

    if (dateTime == null) {
      return value.toString();
    }

    final local =
        dateTime.toLocal();

    final hour =
        local.hour == 0
            ? 12
            : local.hour > 12
                ? local.hour - 12
                : local.hour;

    final minute =
        local.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final period =
        local.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }

  // =====================================================
  // SCROLL
  // =====================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted ||
            !_scrollController.hasClients) {
          return;
        }

        _scrollController.animateTo(
          _scrollController
              .position
              .maxScrollExtent,
          duration:
              const Duration(
            milliseconds: 300,
          ),
          curve:
              Curves.easeOut,
        );
      },
    );
  }

  // =====================================================
  // SNACKBAR
  // =====================================================

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
          content:
              Text(message),
          backgroundColor:
              isError
                  ? Colors.red
                  : Colors.green,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // =====================================================
  // CUSTOMER INITIAL
  // =====================================================

  String get _customerInitial {
    final name =
        _receiverName.trim();

    if (name.isEmpty) {
      return 'C';
    }

    return name
        .substring(
          0,
          1,
        )
        .toUpperCase();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer<ChatProvider>(
      builder: (
        BuildContext context,
        ChatProvider provider,
        Widget? child,
      ) {
        return Scaffold(
          backgroundColor:
              const Color(
            0xFFF8F9FC,
          ),
          appBar: AppBar(
            elevation: 1,
            titleSpacing: 8,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Colors.blue.shade100,
                  child: Text(
                    _customerInitial,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        _receiverName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.readOnly
                            ? 'Chat history'
                            : provider.isOtherUserTyping
                                ? 'Typing...'
                                : widget.negotiationMode
                                    ? 'Negotiation'
                                    : provider.isConnected
                                        ? 'Online'
                                        : 'Booking chat',
                        style:
                            TextStyle(
                          fontSize: 11,
                          color:
                              provider
                                      .isOtherUserTyping
                                  ? Colors.green
                                  : Colors.grey
                                      .shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip:
                    'Refresh',
                onPressed:
                    provider.isLoading
                        ? null
                        : _refreshMessages,
                icon:
                    const Icon(
                  Icons.refresh,
                ),
              ),
              IconButton(
                tooltip:
                    'More',
                icon:
                    const Icon(
                  Icons.more_vert,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              _buildConversationBanner(),

              Expanded(
                child:
                    _buildMessages(
                  provider,
                ),
              ),

              if (_canSendMessage)
                _buildComposer()
              else
                _buildReadOnlyFooter(),
            ],
          ),
        );
      },
    );
  }

  // =====================================================
  // CONVERSATION BANNER
  // =====================================================

  Widget _buildConversationBanner() {
    if (widget.negotiationMode) {
      return Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ),
        color:
            Colors.blue.withValues(
          alpha: 0.08,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.forum_outlined,
              color:
                  Colors.blue,
              size: 18,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Text(
                widget.topic
                            .trim()
                            .isEmpty ||
                        widget.topic ==
                            'general'
                    ? 'Pre-booking negotiation'
                    : 'Negotiation • ${_topicLabel(widget.topic)}',
                style:
                    const TextStyle(
                  fontSize: 12,
                  color:
                      Colors.blue,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 9,
      ),
      color:
          Colors.blue.withValues(
        alpha: 0.08,
      ),
      child: Row(
        children: [
          Icon(
            widget.readOnly
                ? Icons.history
                : Icons.shield_outlined,
            size: 18,
            color:
                Colors.blue,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              widget.readOnly
                  ? 'This booking is closed. Previous messages are available as read-only history.'
                  : 'Booking-specific secure chat',
              style:
                  const TextStyle(
                fontSize: 12,
                color:
                    Colors.blue,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _topicLabel(
    String topic,
  ) {
    final normalized =
        topic
            .trim()
            .toLowerCase()
            .replaceAll(
              '-',
              '_',
            )
            .replaceAll(
              ' ',
              '_',
            );

    switch (normalized) {
      case 'price':
        return 'Price';

      case 'date_time':
      case 'datetime':
      case 'date':
      case 'time':
        return 'Date / Time';

      case 'location':
        return 'Location';

      case 'requirements':
      case 'requirement':
        return 'Requirements';

      case 'other':
        return 'Something Else';

      case 'general':
      default:
        return 'General';
    }
  }

  // =====================================================
  // MESSAGES
  // =====================================================

  Widget _buildMessages(
    ChatProvider provider,
  ) {
    final messages =
        provider.messages;

    if ((_isInitializing ||
            provider.isLoading) &&
        messages.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null &&
        provider.errorMessage!
            .trim()
            .isNotEmpty &&
        messages.isEmpty) {
      return RefreshIndicator(
        onRefresh:
            _refreshMessages,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height:
                  MediaQuery.of(
                        context,
                      ).size.height *
                      0.55,
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    24,
                  ),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 50,
                        color:
                            Colors.red,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        provider.errorMessage!,
                        textAlign:
                            TextAlign.center,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton.icon(
                        onPressed:
                            _refreshMessages,
                        icon:
                            const Icon(
                          Icons.refresh,
                        ),
                        label:
                            const Text(
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
        onRefresh:
            _refreshMessages,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height:
                  MediaQuery.of(
                        context,
                      ).size.height *
                      0.55,
              child: Center(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      widget.negotiationMode
                          ? Icons.forum_outlined
                          : widget.readOnly
                              ? Icons.history
                              : Icons.chat,
                      size: 70,
                      color:
                          Colors.grey.shade400,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      widget.readOnly
                          ? 'No chat history'
                          : widget.negotiationMode
                              ? 'Start Negotiation'
                              : 'Start Conversation',
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      widget.readOnly
                          ? 'There are no previous messages for this booking.'
                          : widget.negotiationMode
                              ? 'Reply to the Customer before a booking is created.'
                              : 'Send a message to the Customer about this booking.',
                      textAlign:
                          TextAlign.center,
                      style:
                          TextStyle(
                        color:
                            Colors.grey.shade600,
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

    return RefreshIndicator(
      onRefresh:
          _refreshMessages,
      child: ListView.builder(
        controller:
            _scrollController,
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          16,
        ),
        itemCount:
            messages.length,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          return _buildMessageBubble(
            messages[index],
          );
        },
      ),
    );
  }

  // =====================================================
  // MESSAGE BUBBLE
  // =====================================================

  Widget _buildMessageBubble(
    ChatMessageModel message,
  ) {
    final isMine =
        _isMyMessage(
      message,
    );

    final text =
        message.message ?? '';

    return Align(
      alignment:
          isMine
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 10,
        ),
        constraints:
            BoxConstraints(
          maxWidth:
              MediaQuery.of(
                    context,
                  ).size.width *
                  0.75,
        ),
        padding:
            const EdgeInsets.fromLTRB(
          12,
          10,
          10,
          7,
        ),
        decoration:
            BoxDecoration(
          color:
              isMine
                  ? Theme.of(
                      context,
                    ).primaryColor
                  : Colors.grey.shade200,
          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            if (text.isNotEmpty)
              Text(
                text,
                style:
                    TextStyle(
                  color:
                      isMine
                          ? Colors.white
                          : Colors.black87,
                  height: 1.3,
                ),
              ),

            const SizedBox(
              height: 5,
            ),

            Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(
                    message.createdAt,
                  ),
                  style:
                      TextStyle(
                    fontSize: 10,
                    color:
                        isMine
                            ? Colors.white70
                            : Colors.grey,
                  ),
                ),

                if (isMine) ...[
                  const SizedBox(
                    width: 4,
                  ),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color:
                        message.isRead ==
                                true
                            ? Colors
                                .lightBlueAccent
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

  // =====================================================
  // COMPOSER
  // =====================================================

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding:
            const EdgeInsets.all(
          12,
        ),
        decoration:
            const BoxDecoration(
          color:
              Colors.white,
          border: Border(
            top:
                BorderSide(
              color:
                  Color(
                0xFFE0E0E0,
              ),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            IconButton(
              tooltip:
                  'Attach',
              icon:
                  const Icon(
                Icons.attach_file,
              ),
              onPressed:
                  _isSending
                      ? null
                      : () {
                          /*
                           * File sharing must use the same
                           * roomId / receiverId contract.
                           */
                        },
            ),

            Expanded(
              child: TextField(
                controller:
                    _messageController,
                enabled:
                    !_isSending &&
                    _canSendMessage,
                minLines: 1,
                maxLines: 5,
                maxLength: 5000,
                textCapitalization:
                    TextCapitalization
                        .sentences,
                textInputAction:
                    TextInputAction.send,
                onChanged:
                    _handleTyping,
                onSubmitted: (_) {
                  _sendMessage();
                },
                decoration:
                    InputDecoration(
                  counterText: '',
                  hintText:
                      widget.negotiationMode
                          ? 'Reply to Customer...'
                          : 'Type a message...',
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
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
              child: _isSending
                  ? const Padding(
                      padding:
                          EdgeInsets.all(
                        12,
                      ),
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            Colors.white,
                      ),
                    )
                  : IconButton(
                      tooltip:
                          'Send',
                      onPressed:
                          _canSendMessage
                              ? _sendMessage
                              : null,
                      icon:
                          const Icon(
                        Icons.send,
                        color:
                            Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // READ ONLY FOOTER
  // =====================================================

  Widget _buildReadOnlyFooter() {
    return SafeArea(
      top: false,
      child: Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration:
            BoxDecoration(
          color:
              Colors.grey.shade100,
          border: Border(
            top:
                BorderSide(
              color:
                  Colors.grey.shade300,
            ),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.lock_outline,
              color:
                  Colors.grey,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                'This booking is closed. Chat history is read-only.',
                style:
                    TextStyle(
                  color:
                      Colors.grey,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}