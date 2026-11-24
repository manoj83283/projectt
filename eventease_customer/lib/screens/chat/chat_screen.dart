import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme_config.dart';
import '../../providers/chat_provider.dart';

// =====================================================
// CHAT SCREEN
// =====================================================

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

  ChatProvider? _chatProvider;

  String bookingId = '';
  String serviceId = '';
  String roomId = '';
  String providerId = '';
  String providerName = 'Service Provider';
  String providerPhone = '';
  String topic = 'general';

  bool _argumentsLoaded = false;
  bool _initializationScheduled = false;
  bool _isInitializing = false;
  bool _isSending = false;

  bool _negotiationMode = false;
  bool _readOnly = false;
  bool _chatEnabled = true;

  // =====================================================
  // LIFECYCLE
  // =====================================================

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _chatProvider ??=
        context.read<ChatProvider>();

    if (!_argumentsLoaded) {
      _argumentsLoaded = true;

      _loadRouteArguments();
    }

    if (!_initializationScheduled) {
      _initializationScheduled = true;

      WidgetsBinding.instance
          .addPostFrameCallback(
        (_) {
          if (!mounted) {
            return;
          }

          _initializeChat();
        },
      );
    }
  }

  @override
  void dispose() {
    final provider =
        _chatProvider;

    if (provider != null &&
        roomId.isNotEmpty) {
      try {
        provider.stopTyping(
          roomId: roomId,
          bookingId: bookingId,
          receiverId: providerId,
        );
      } catch (_) {
        // Cleanup must not interrupt disposal.
      }

      try {
        provider.leaveRoom(
          roomId,
        );
      } catch (_) {
        // Cleanup must not interrupt disposal.
      }
    }

    messageController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  // =====================================================
  // VALUE HELPERS
  // =====================================================

  Map<String, dynamic> _asMap(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (
          key,
          dynamic item,
        ) {
          return MapEntry(
            key.toString(),
            item,
          );
        },
      );
    }

    return <String, dynamic>{};
  }

  String _asString(
    dynamic value, {
    String fallback = '',
  }) {
    final normalized =
        value
            ?.toString()
            .trim() ??
        '';

    return normalized.isEmpty
        ? fallback
        : normalized;
  }

  bool _asBool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized =
        value
            .toString()
            .trim()
            .toLowerCase();

    if (<String>{
      'true',
      '1',
      'yes',
    }.contains(normalized)) {
      return true;
    }

    if (<String>{
      'false',
      '0',
      'no',
    }.contains(normalized)) {
      return false;
    }

    return fallback;
  }

  // =====================================================
  // ROUTE ARGUMENTS
  // =====================================================

  void _loadRouteArguments() {
    final arguments =
        ModalRoute.of(context)
            ?.settings
            .arguments;

    if (arguments is! Map) {
      return;
    }

    final map =
        _asMap(
      arguments,
    );

    final chatType =
        _asString(
      map['chatType'],
    ).toLowerCase();

    _negotiationMode =
        chatType ==
            'negotiation' ||
        _asBool(
          map['negotiationMode'],
        );

    bookingId =
        _asString(
      map['bookingId'],
    );

    serviceId =
        _asString(
      map['serviceId'],
    );

    roomId =
        _asString(
      map['roomId'] ??
          map['chatRoomId'],
    );

    providerId =
        _asString(
      map['providerId'] ??
          map['receiverId'],
    );

    providerName =
        _asString(
      map['providerName'] ??
          map['receiverName'] ??
          map['userName'],
      fallback:
          'Service Provider',
    );

    providerPhone =
        _asString(
      map['providerPhone'] ??
          map['receiverPhone'],
    );

    topic =
        _asString(
      map['topic'] ??
          map['negotiationTopic'],
      fallback:
          'general',
    );

    _readOnly =
        _asBool(
      map['readOnly'],
    );

    _chatEnabled =
        _asBool(
      map['chatEnabled'],
      fallback: true,
    );

    /*
     * Booking Chat always uses:
     *
     * booking:<bookingId>
     *
     * Negotiation rooms must NOT be changed into
     * booking rooms.
     */
    if (!_negotiationMode &&
        bookingId.isNotEmpty) {
      roomId =
          'booking:$bookingId';
    }
  }

  // =====================================================
  // MESSAGE PERMISSION
  // =====================================================

  bool get _canSendMessage {
    if (_readOnly) {
      return false;
    }

    /*
     * Negotiation is independent of OTP and booking state.
     */
    if (_negotiationMode) {
      return roomId.isNotEmpty;
    }

    /*
     * Booking Chat follows the communication state
     * returned by the Booking backend.
     */
    return _chatEnabled &&
        bookingId.isNotEmpty &&
        roomId.isNotEmpty;
  }

  // =====================================================
  // INITIALIZE CHAT
  // =====================================================

  Future<void> _initializeChat() async {
    if (!mounted ||
        _isInitializing) {
      return;
    }

    final provider =
        _chatProvider ??
        context.read<ChatProvider>();

    _chatProvider =
        provider;

    _isInitializing = true;

    try {
      if (_negotiationMode) {
        await _initializeNegotiationChat(
          provider,
        );
      } else {
        await _initializeBookingChat(
          provider,
        );
      }

      if (!mounted) {
        return;
      }

      _scrollToBottom();
    } catch (error, stackTrace) {
      debugPrint(
        'CHAT INITIALIZATION ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      if (mounted) {
        _showMessage(
          _negotiationMode
              ? 'Unable to initialize negotiation chat.'
              : 'Unable to initialize booking chat.',
          isError: true,
        );
      }
    } finally {
      _isInitializing = false;
    }
  }

  // =====================================================
  // INITIALIZE NEGOTIATION CHAT
  // =====================================================

  Future<void> _initializeNegotiationChat(
    ChatProvider provider,
  ) async {
    /*
     * Negotiation does NOT require:
     *
     * bookingId
     * accepted booking
     * Provider arrival
     * OTP verification
     */

    if (roomId.isEmpty) {
      if (serviceId.isEmpty ||
          providerId.isEmpty) {
        _showMessage(
          'Service and Provider information are required to start negotiation.',
          isError: true,
        );

        return;
      }

      final arguments =
          ModalRoute.of(context)
              ?.settings
              .arguments;

      final map =
          arguments is Map
              ? _asMap(arguments)
              : <String, dynamic>{};

      final bookingDate =
          _asString(
        map['bookingDate'],
      );

      final bookingTime =
          _asString(
        map['bookingTime'],
      );

      final opened =
          await provider.openNegotiation(
        serviceId: serviceId,
        providerId: providerId,
        topic: topic,
        bookingDate:
            bookingDate.isEmpty
                ? null
                : bookingDate,
        bookingTime:
            bookingTime.isEmpty
                ? null
                : bookingTime,
      );

      if (!mounted) {
        return;
      }

      if (!opened) {
        _showMessage(
          provider.error ??
              'Unable to start negotiation chat.',
          isError: true,
        );

        return;
      }

      roomId =
          provider.currentRoomId ??
          '';

      if (roomId.isEmpty) {
        _showMessage(
          'Negotiation room is unavailable.',
          isError: true,
        );

        return;
      }
    } else {
      provider.joinNegotiationRoom(
        roomId: roomId,
        serviceId: serviceId,
        providerId: providerId,
        topic: topic,
      );

      await provider.loadMessages(
        roomId: roomId,
      );

      if (!mounted) {
        return;
      }

      await provider.markAsRead(
        roomId,
      );
    }
  }

  // =====================================================
  // INITIALIZE BOOKING CHAT
  // =====================================================

  Future<void> _initializeBookingChat(
    ChatProvider provider,
  ) async {
    if (bookingId.isEmpty) {
      _showMessage(
        'Booking information is unavailable.',
        isError: true,
      );

      return;
    }

    if (roomId.isEmpty) {
      roomId =
          'booking:$bookingId';
    }

    await provider.openBookingChat(
      bookingId: bookingId,
      roomId: roomId,
    );

    if (!mounted) {
      return;
    }

    roomId =
        provider.currentRoomId ??
        roomId;
  }

  // =====================================================
  // REFRESH MESSAGES
  // =====================================================

  Future<void> _refreshMessages() async {
    if (!mounted ||
        roomId.isEmpty) {
      return;
    }

    final provider =
        _chatProvider ??
        context.read<ChatProvider>();

    _chatProvider =
        provider;

    try {
      await provider.loadMessages(
        roomId: roomId,
        showLoading: false,
      );

      if (!mounted) {
        return;
      }

      await provider.markAsRead(
        roomId,
      );

      if (!mounted) {
        return;
      }

      _scrollToBottom();
    } catch (error, stackTrace) {
      debugPrint(
        'CHAT REFRESH ERROR: $error',
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
        _isSending) {
      return;
    }

    if (!_canSendMessage) {
      _showMessage(
        _readOnly
            ? 'This conversation is closed for new messages.'
            : 'Chat is currently unavailable.',
        isError: true,
      );

      return;
    }

    final message =
        messageController
            .text
            .trim();

    if (message.isEmpty) {
      return;
    }

    if (roomId.isEmpty) {
      _showMessage(
        'Chat room is unavailable.',
        isError: true,
      );

      return;
    }

    setState(() {
      _isSending =
          true;
    });

    messageController.clear();

    try {
      final provider =
          _chatProvider ??
          context.read<ChatProvider>();

      _chatProvider =
          provider;

      /*
       * IMPORTANT:
       *
       * Sending is room-based.
       *
       * No bookingId is required for negotiation messages.
       */
      final success =
          await provider.sendMessage(
        roomId: roomId,
        message: message,
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        messageController.text =
            message;

        _showMessage(
          provider.error
                      ?.trim()
                      .isNotEmpty ==
                  true
              ? provider.error!
              : 'Unable to send the message.',
          isError: true,
        );

        return;
      }

      provider.stopTyping(
        roomId: roomId,
        bookingId: bookingId,
        receiverId: providerId,
      );

      _scrollToBottom();
    } catch (error, stackTrace) {
      debugPrint(
        'SEND CHAT MESSAGE ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      if (mounted) {
        messageController.text =
            message;

        _showMessage(
          error.toString(),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending =
              false;
        });
      } else {
        _isSending =
            false;
      }
    }
  }

  // =====================================================
  // CALL PROVIDER
  // =====================================================

  Future<void> _callProvider() async {
    /*
     * Calling belongs to Booking Chat.
     *
     * Pre-booking negotiation does not expose the
     * Provider phone number.
     */
    if (_negotiationMode) {
      _showMessage(
        'Provider calling becomes available after the booking is accepted.',
        isError: true,
      );

      return;
    }

    if (_readOnly) {
      _showMessage(
        'Calling is unavailable for closed bookings.',
        isError: true,
      );

      return;
    }

    final normalizedPhone =
        providerPhone.replaceAll(
      RegExp(
        r'[^0-9+]',
      ),
      '',
    );

    if (normalizedPhone.isEmpty) {
      _showMessage(
        'Provider phone number is unavailable.',
        isError: true,
      );

      return;
    }

    final uri =
        Uri(
      scheme: 'tel',
      path: normalizedPhone,
    );

    try {
      final launched =
          await launchUrl(
        uri,
        mode:
            LaunchMode.externalApplication,
      );

      if (!mounted) {
        return;
      }

      if (!launched) {
        _showMessage(
          'Unable to open the phone application.',
          isError: true,
        );
      }
    } catch (error, stackTrace) {
      debugPrint(
        'CHAT CALL PROVIDER ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      if (mounted) {
        _showMessage(
          'Unable to open the phone application.',
          isError: true,
        );
      }
    }
  }

  // =====================================================
  // TYPING
  // =====================================================

  void _handleTypingChanged(
    String value,
  ) {
    if (!mounted ||
        !_canSendMessage ||
        roomId.isEmpty ||
        providerId.isEmpty) {
      return;
    }

    final provider =
        _chatProvider ??
        context.read<ChatProvider>();

    _chatProvider =
        provider;

    if (value.trim().isEmpty) {
      provider.stopTyping(
        roomId: roomId,
        bookingId: bookingId,
        receiverId: providerId,
      );

      return;
    }

    provider.startTyping(
      roomId: roomId,
      bookingId: bookingId,
      receiverId: providerId,
    );
  }

  // =====================================================
  // SCROLL
  // =====================================================

  void _scrollToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted ||
            !scrollController
                .hasClients) {
          return;
        }

        scrollController.animateTo(
          scrollController
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
  // MESSAGE
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
  // TIME FORMAT
  // =====================================================

  String _formatMessageTime(
    DateTime? dateTime,
  ) {
    if (dateTime == null) {
      return '';
    }

    final localTime =
        dateTime.toLocal();

    final hour =
        localTime.hour;

    final minute =
        localTime.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final period =
        hour >= 12
            ? 'PM'
            : 'AM';

    final displayHour =
        hour == 0
            ? 12
            : hour > 12
                ? hour - 12
                : hour;

    return '$displayHour:$minute $period';
  }

  String _formatDateSeparator(
    DateTime dateTime,
  ) {
    final date =
        dateTime.toLocal();

    final now =
        DateTime.now();

    final today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    final messageDate =
        DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference =
        today
            .difference(
              messageDate,
            )
            .inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    final day =
        date.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        date.month
            .toString()
            .padLeft(
              2,
              '0',
            );

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
        messages[index]
            .createdAt
            ?.toLocal();

    final previousDate =
        messages[index - 1]
            .createdAt
            ?.toLocal();

    if (currentDate == null ||
        previousDate == null) {
      return false;
    }

    return currentDate.year !=
            previousDate.year ||
        currentDate.month !=
            previousDate.month ||
        currentDate.day !=
            previousDate.day;
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
        final messages =
            provider.messages;

        final canSendMessage =
            _canSendMessage;

        return Scaffold(
          backgroundColor:
              const Color(
            0xFFF8F9FC,
          ),
          appBar: AppBar(
            elevation: 0,
            titleSpacing: 8,
            title: Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    _negotiationMode
                        ? Icons
                            .forum_outlined
                        : Icons.person,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        providerName
                                .trim()
                                .isEmpty
                            ? 'Service Provider'
                            : providerName,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      Text(
                        _readOnly
                            ? 'Chat history'
                            : provider
                                    .isOtherUserTyping
                                ? 'Typing...'
                                : provider
                                        .isConnected
                                    ? _negotiationMode
                                        ? 'Negotiation chat'
                                        : 'Online'
                                    : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              _readOnly
                                  ? Colors.grey
                                  : provider
                                          .isOtherUserTyping
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
                tooltip:
                    'Refresh',
                onPressed:
                    provider.isLoading ||
                            roomId.isEmpty
                        ? null
                        : _refreshMessages,
                icon:
                    const Icon(
                  Icons.refresh,
                ),
              ),

              /*
               * Phone is intentionally unavailable in
               * pre-booking negotiation.
               */
              if (!_negotiationMode &&
                  !_readOnly &&
                  providerPhone
                      .trim()
                      .isNotEmpty)
                IconButton(
                  tooltip:
                      'Call Provider',
                  onPressed:
                      _callProvider,
                  icon:
                      const Icon(
                    Icons.call,
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              _buildConversationBanner(),

              Expanded(
                child:
                    _buildMessagesArea(
                  provider,
                  messages,
                ),
              ),

              if (canSendMessage)
                _buildMessageInput(
                  provider,
                )
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
    if (_negotiationMode) {
      return Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ),
        color:
            ThemeConfig.primaryColor
                .withValues(
          alpha: 0.08,
        ),
        child: Row(
          children: [
            const Icon(
              Icons
                  .forum_outlined,
              size: 18,
              color:
                  ThemeConfig
                      .primaryColor,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Text(
                topic
                            .trim()
                            .isEmpty ||
                        topic ==
                            'general'
                    ? 'Pre-booking negotiation chat'
                    : 'Pre-booking negotiation • ${_formatTopic(topic)}',
                style:
                    const TextStyle(
                  fontSize: 12,
                  color:
                      ThemeConfig
                          .primaryColor,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (bookingId.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      color:
          ThemeConfig.primaryColor
              .withValues(
        alpha: 0.08,
      ),
      child: Row(
        children: [
          Icon(
            _readOnly
                ? Icons.history
                : Icons
                    .shield_outlined,
            size: 18,
            color:
                ThemeConfig
                    .primaryColor,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              _readOnly
                  ? 'This booking is closed. Previous chat messages are available in read-only mode.'
                  : 'Booking-specific secure chat',
              style:
                  const TextStyle(
                fontSize: 12,
                color:
                    ThemeConfig
                        .primaryColor,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTopic(
    String value,
  ) {
    switch (value
        .trim()
        .toLowerCase()
        .replaceAll(
          '-',
          '_',
        )) {
      case 'price':
        return 'Price';

      case 'date_time':
      case 'datetime':
      case 'time':
        return 'Date / Time';

      case 'location':
        return 'Location';

      case 'requirements':
        return 'Requirements';

      case 'other':
        return 'Something Else';

      default:
        return 'General';
    }
  }

  // =====================================================
  // MESSAGES AREA
  // =====================================================

  Widget _buildMessagesArea(
    ChatProvider provider,
    List<dynamic> messages,
  ) {
    if ((_isInitializing ||
            provider.isLoading) &&
        messages.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (provider.error != null &&
        provider.error!
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
                        Icons
                            .error_outline,
                        size: 50,
                        color:
                            Colors.red,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        provider.error!,
                        textAlign:
                            TextAlign.center,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton.icon(
                        onPressed:
                            roomId.isEmpty
                                ? _initializeChat
                                : _refreshMessages,
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
            roomId.isEmpty
                ? _initializeChat
                : _refreshMessages,
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
                      Icon(
                        _readOnly
                            ? Icons.history
                            : _negotiationMode
                                ? Icons
                                    .forum_outlined
                                : Icons
                                    .chat_bubble_outline,
                        size: 55,
                        color:
                            Colors.grey,
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Text(
                        _readOnly
                            ? 'No chat history'
                            : _negotiationMode
                                ? 'Start the conversation'
                                : 'No messages yet',
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        _readOnly
                            ? 'There are no previous messages for this booking.'
                            : _negotiationMode
                                ? 'Discuss the service with the Provider before booking.'
                                : 'Send a message to your service provider.',
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
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

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (mounted) {
          _scrollToBottom();
        }
      },
    );

    return RefreshIndicator(
      onRefresh:
          _refreshMessages,
      child: ListView.builder(
        controller:
            scrollController,
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          12,
        ),
        itemCount:
            messages.length,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          final message =
              messages[index];

          final isMe =
              message.isMine ==
              true;

          final dynamic rawCreatedAt =
              message.createdAt;

          final DateTime? createdAt =
              rawCreatedAt is DateTime
                  ? rawCreatedAt
                  : rawCreatedAt ==
                          null
                      ? null
                      : DateTime.tryParse(
                          rawCreatedAt
                              .toString(),
                        );

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
                message:
                    message,
                isMe:
                    isMe,
              ),
            ],
          );
        },
      ),
    );
  }

  // =====================================================
  // DATE SEPARATOR
  // =====================================================

  Widget _buildDateSeparator(
    String label,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Row(
        children: [
          const Expanded(
            child:
                Divider(),
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
            decoration:
                BoxDecoration(
              color:
                  Colors.grey.shade200,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color:
                    Colors.grey.shade700,
                fontSize: 11,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
          const Expanded(
            child:
                Divider(),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // MESSAGE BUBBLE
  // =====================================================

  Widget _buildMessageBubble({
    required dynamic message,
    required bool isMe,
  }) {
    final messageText =
        message.message
                ?.toString() ??
            '';

    final dynamic rawCreatedAt =
        message.createdAt;

    final DateTime? createdAt =
        rawCreatedAt is DateTime
            ? rawCreatedAt
            : rawCreatedAt == null
                ? null
                : DateTime.tryParse(
                    rawCreatedAt
                        .toString(),
                  );

    final isRead =
        message.isRead ==
        true;

    final delivered =
        message.delivered ==
        true;

    return Align(
      alignment:
          isMe
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 8,
        ),
        padding:
            const EdgeInsets.fromLTRB(
          13,
          10,
          10,
          7,
        ),
        constraints:
            BoxConstraints(
          maxWidth:
              MediaQuery.of(
                    context,
                  ).size.width *
                  0.76,
        ),
        decoration:
            BoxDecoration(
          color:
              isMe
                  ? ThemeConfig
                      .primaryColor
                  : Colors.white,
          borderRadius:
              BorderRadius.only(
            topLeft:
                const Radius.circular(
              16,
            ),
            topRight:
                const Radius.circular(
              16,
            ),
            bottomLeft:
                Radius.circular(
              isMe ? 16 : 4,
            ),
            bottomRight:
                Radius.circular(
              isMe ? 4 : 16,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black
                      .withValues(
                alpha: 0.05,
              ),
              blurRadius: 5,
              offset:
                  const Offset(
                0,
                2,
              ),
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
                style:
                    TextStyle(
                  color:
                      isMe
                          ? Colors.white
                          : Colors.black87,
                  fontSize: 15,
                  height: 1.3,
                ),
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
                    createdAt,
                  ),
                  style:
                      TextStyle(
                    fontSize: 10,
                    color:
                        isMe
                            ? Colors.white70
                            : Colors.grey,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(
                    width: 4,
                  ),
                  Icon(
                    isRead
                        ? Icons.done_all
                        : delivered
                            ? Icons.done_all
                            : Icons.done,
                    size: 15,
                    color:
                        isRead
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
  // CLOSED / READ-ONLY FOOTER
  // =====================================================

  Widget _buildReadOnlyFooter() {
    final text =
        _readOnly
            ? 'This booking is closed. Chat history is read-only.'
            : _negotiationMode
                ? 'This negotiation is currently unavailable.'
                : 'New messages are currently disabled for this booking.';

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
        child: Row(
          children: [
            const Icon(
              Icons.lock_outline,
              color:
                  Colors.grey,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                text,
                style:
                    const TextStyle(
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

  // =====================================================
  // MESSAGE INPUT
  // =====================================================

  Widget _buildMessageInput(
    ChatProvider provider,
  ) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        10,
        8,
        10,
        10,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withValues(
              alpha: 0.07,
            ),
            blurRadius: 10,
            offset:
                const Offset(
              0,
              -2,
            ),
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
                controller:
                    messageController,
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
                    TextInputAction
                        .newline,
                onChanged:
                    _handleTypingChanged,
                decoration:
                    InputDecoration(
                  counterText: '',
                  hintText:
                      _negotiationMode
                          ? 'Message Provider...'
                          : 'Type a message...',
                  filled: true,
                  fillColor:
                      Colors.grey
                          .shade100,
                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      26,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      26,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      26,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          ThemeConfig
                              .primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            CircleAvatar(
              radius: 23,
              backgroundColor:
                  ThemeConfig
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