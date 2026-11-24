import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({
    super.key,
  });

  @override
  State<ChatListScreen> createState() =>
      _ChatListScreenState();
}

class _ChatListScreenState
    extends State<ChatListScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _onSearchChanged,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _loadChats();
        }
      },
    );
  }

  void _onSearchChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      _searchQuery =
          _searchController.text.trim().toLowerCase();
    });
  }

  Future<void> _loadChats() async {
    if (!mounted) {
      return;
    }

    try {
      await context
          .read<ChatProvider>()
          .getChatRooms();
    } catch (error) {
      debugPrint(
        'CHAT LIST LOAD ERROR: $error',
      );
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(
      _onSearchChanged,
    );

    _searchController.dispose();

    super.dispose();
  }

  // =====================================================
  // DATA HELPERS
  // =====================================================

  Map<String, dynamic> _asMap(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, dynamic item) => MapEntry(
          key.toString(),
          item,
        ),
      );
    }

    return <String, dynamic>{};
  }

  String _asString(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final result = value.toString().trim();

    return result.isEmpty
        ? fallback
        : result;
  }

  int _asInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }

  String _extractId(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    final map = _asMap(value);

    if (map.isEmpty) {
      return '';
    }

    return _asString(
      map['_id'] ??
          map['id'] ??
          map['userId'] ??
          map['customerId'] ??
          map['providerId'],
    );
  }

  String _resolveRoomId(
    Map<String, dynamic> room,
  ) {
    final chatRoom = _asMap(
      room['chatRoom'],
    );

    final booking = _asMap(
      room['booking'],
    );

    var roomId = _asString(
      room['roomId'] ??
          room['chatRoomId'] ??
          chatRoom['roomId'] ??
          chatRoom['chatRoomId'] ??
          chatRoom['_id'] ??
          chatRoom['id'],
    );

    if (roomId.isNotEmpty) {
      return roomId;
    }

    /*
     * Do not automatically interpret room['id'] as a room ID
     * until we have checked for an associated booking.
     */
    final bookingId = _resolveBookingId(
      room,
    );

    if (bookingId.isNotEmpty) {
      return 'booking:$bookingId';
    }

    roomId = _asString(
      room['_id'] ??
          room['id'],
    );

    return roomId;
  }

  String _resolveBookingId(
    Map<String, dynamic> room,
  ) {
    final booking = _asMap(
      room['booking'],
    );

    final id = _extractId(
      room['bookingId'] ??
          room['booking'] ??
          booking,
    );

    return id;
  }

  String _resolveServiceId(
    Map<String, dynamic> room,
  ) {
    final service = _asMap(
      room['service'],
    );

    final booking = _asMap(
      room['booking'],
    );

    return _extractId(
      room['serviceId'] ??
          room['service'] ??
          booking['serviceId'] ??
          booking['service'] ??
          service,
    );
  }

  String _resolveReceiverId(
    Map<String, dynamic> room,
  ) {
    /*
     * In the Provider app, the receiver is normally
     * the Customer.
     */

    final customer = _asMap(
      room['customer'],
    );

    final user = _asMap(
      room['user'],
    );

    final receiver = _asMap(
      room['receiver'],
    );

    final otherUser = _asMap(
      room['otherUser'],
    );

    final booking = _asMap(
      room['booking'],
    );

    final bookingCustomer = _asMap(
      booking['customer'],
    );

    final bookingUser = _asMap(
      booking['user'],
    );

    return _extractId(
      room['receiverId'] ??
          room['customerId'] ??
          room['userId'] ??
          room['otherUserId'] ??
          receiver ??
          customer ??
          user ??
          otherUser ??
          booking['customerId'] ??
          booking['userId'] ??
          bookingCustomer ??
          bookingUser,
    );
  }

  String _resolveReceiverName(
    Map<String, dynamic> room,
  ) {
    final customer = _asMap(
      room['customer'],
    );

    final user = _asMap(
      room['user'],
    );

    final receiver = _asMap(
      room['receiver'],
    );

    final otherUser = _asMap(
      room['otherUser'],
    );

    final booking = _asMap(
      room['booking'],
    );

    final bookingCustomer = _asMap(
      booking['customer'],
    );

    final bookingUser = _asMap(
      booking['user'],
    );

    final directName = _asString(
      room['userName'] ??
          room['customerName'] ??
          room['receiverName'] ??
          room['otherUserName'],
    );

    if (directName.isNotEmpty) {
      return directName;
    }

    final possibleUsers = <Map<String, dynamic>>[
      receiver,
      customer,
      user,
      otherUser,
      bookingCustomer,
      bookingUser,
    ];

    for (final person in possibleUsers) {
      if (person.isEmpty) {
        continue;
      }

      final fullName = _asString(
        person['fullName'] ??
            person['name'],
      );

      if (fullName.isNotEmpty) {
        return fullName;
      }

      final firstName = _asString(
        person['firstName'],
      );

      final lastName = _asString(
        person['lastName'],
      );

      final combinedName = [
        firstName,
        lastName,
      ].where(
        (value) => value.isNotEmpty,
      ).join(' ').trim();

      if (combinedName.isNotEmpty) {
        return combinedName;
      }

      final businessName = _asString(
        person['businessName'] ??
            person['shopName'],
      );

      if (businessName.isNotEmpty) {
        return businessName;
      }
    }

    return 'Customer';
  }

  String _resolveProfileImage(
    Map<String, dynamic> room,
  ) {
    final customer = _asMap(
      room['customer'],
    );

    final user = _asMap(
      room['user'],
    );

    final receiver = _asMap(
      room['receiver'],
    );

    final otherUser = _asMap(
      room['otherUser'],
    );

    return _asString(
      room['profileImage'] ??
          room['customerImage'] ??
          room['receiverImage'] ??
          customer['profileImage'] ??
          user['profileImage'] ??
          receiver['profileImage'] ??
          otherUser['profileImage'],
    );
  }

  String _resolveLastMessage(
    Map<String, dynamic> room,
  ) {
    final rawLastMessage =
        room['lastMessage'];

    if (rawLastMessage is Map) {
      final messageMap = _asMap(
        rawLastMessage,
      );

      return _asString(
        messageMap['message'] ??
            messageMap['content'] ??
            messageMap['text'],
        fallback: 'Start Conversation',
      );
    }

    return _asString(
      rawLastMessage ??
          room['lastMessageText'] ??
          room['message'],
      fallback: 'Start Conversation',
    );
  }

  String _resolveLastMessageTime(
    Map<String, dynamic> room,
  ) {
    final rawLastMessage =
        room['lastMessage'];

    dynamic rawTime =
        room['lastMessageTime'] ??
        room['lastMessageAt'] ??
        room['updatedAt'];

    if (rawLastMessage is Map) {
      final messageMap = _asMap(
        rawLastMessage,
      );

      rawTime =
          messageMap['createdAt'] ??
          messageMap['timestamp'] ??
          rawTime;
    }

    if (rawTime == null) {
      return '';
    }

    final dateTime = DateTime.tryParse(
      rawTime.toString(),
    );

    if (dateTime == null) {
      return _asString(
        rawTime,
      );
    }

    final localTime =
        dateTime.toLocal();

    final hour =
        localTime.hour > 12
            ? localTime.hour - 12
            : localTime.hour == 0
                ? 12
                : localTime.hour;

    final minute =
        localTime.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final period =
        localTime.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }

  int _resolveUnreadCount(
    Map<String, dynamic> room,
  ) {
    return _asInt(
      room['unreadCount'] ??
          room['providerUnreadCount'] ??
          room['unreadMessages'],
    );
  }

  bool _isNegotiationRoom(
    Map<String, dynamic> room,
    String roomId,
  ) {
    if (room['negotiationMode'] == true ||
        room['isNegotiation'] == true) {
      return true;
    }

    final type = _asString(
      room['type'] ??
          room['chatType'] ??
          room['conversationType'],
    ).toLowerCase();

    return roomId
            .toLowerCase()
            .startsWith(
              'negotiation:',
            ) ||
        type == 'negotiation';
  }

  bool _matchesSearch(
    dynamic rawRoom,
  ) {
    if (_searchQuery.isEmpty) {
      return true;
    }

    final room = _asMap(
      rawRoom,
    );

    final name =
        _resolveReceiverName(
      room,
    ).toLowerCase();

    final message =
        _resolveLastMessage(
      room,
    ).toLowerCase();

    return name.contains(
          _searchQuery,
        ) ||
        message.contains(
          _searchQuery,
        );
  }

  // =====================================================
  // OPEN CHAT
  // =====================================================

  Future<void> _openChat(
    Map<String, dynamic> room,
  ) async {
    final roomId =
        _resolveRoomId(
      room,
    );

    final receiverId =
        _resolveReceiverId(
      room,
    );

    final receiverName =
        _resolveReceiverName(
      room,
    );

    final bookingId =
        _resolveBookingId(
      room,
    );

    final serviceId =
        _resolveServiceId(
      room,
    );

    final negotiationMode =
        _isNegotiationRoom(
      room,
      roomId,
    );

    if (roomId.isEmpty) {
      _showMessage(
        'Chat room information is unavailable.',
      );
      return;
    }

    if (receiverId.isEmpty) {
      _showMessage(
        'Customer information is unavailable for this conversation.',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          roomId: roomId,
          receiverId: receiverId,
          receiverName: receiverName,
          bookingId:
              bookingId.isEmpty
                  ? null
                  : bookingId,
          serviceId:
              serviceId.isEmpty
                  ? null
                  : serviceId,
          negotiationMode:
              negotiationMode,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadChats();
  }

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(
    BuildContext context,
  ) {
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
          final filteredRooms =
              provider.chatRooms.where(
            _matchesSearch,
          ).toList();

          return Column(
            children: [
              // ======================
              // SEARCH
              // ======================

              Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
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
                    suffixIcon:
                        _searchQuery
                                .isNotEmpty
                            ? IconButton(
                                onPressed:
                                    () {
                                  _searchController
                                      .clear();
                                },
                                icon:
                                    const Icon(
                                  Icons.close,
                                ),
                              )
                            : null,
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
                    const EdgeInsets.all(
                  12,
                ),
                decoration:
                    BoxDecoration(
                  color: Theme.of(
                    context,
                  ).primaryColor.withValues(
                        alpha: 0.08,
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
                    const SizedBox(
                      width: 10,
                    ),
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

              const SizedBox(
                height: 12,
              ),

              // ======================
              // CHAT LIST
              // ======================

              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : filteredRooms.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh:
                                _loadChats,
                            child:
                                ListView.builder(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.all(
                                16,
                              ),
                              itemCount:
                                  filteredRooms
                                      .length,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                return _chatCard(
                                  context,
                                  filteredRooms[
                                      index],
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

  // =====================================================
  // EMPTY STATE
  // =====================================================

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadChats,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
                MediaQuery.of(context)
                        .size
                        .height *
                    0.55,
            child: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No Chats Available'
                        : 'No chats match your search',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CHAT CARD
  // =====================================================

  Widget _chatCard(
    BuildContext context,
    dynamic rawRoom,
  ) {
    final room = _asMap(
      rawRoom,
    );

    final roomId =
        _resolveRoomId(
      room,
    );

    final userName =
        _resolveReceiverName(
      room,
    );

    final lastMessage =
        _resolveLastMessage(
      room,
    );

    final lastMessageTime =
        _resolveLastMessageTime(
      room,
    );

    final unreadCount =
        _resolveUnreadCount(
      room,
    );

    final profileImage =
        _resolveProfileImage(
      room,
    );

    final negotiationMode =
        _isNegotiationRoom(
      room,
      roomId,
    );

    final initial =
        userName.trim().isEmpty
            ? '?'
            : userName
                .trim()
                .substring(
                  0,
                  1,
                )
                .toUpperCase();

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 26,
          backgroundImage:
              profileImage.isNotEmpty
                  ? NetworkImage(
                      profileImage,
                    )
                  : null,
          child:
              profileImage.isEmpty
                  ? Text(
                      initial,
                    )
                  : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                userName,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            if (negotiationMode) ...[
              const SizedBox(
                width: 8,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.orange
                      .withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: const Text(
                  'Negotiation',
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        Colors.orange,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
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
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Text(
              lastMessageTime,
              style:
                  const TextStyle(
                fontSize: 11,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(
                height: 5,
              ),
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
          ],
        ),
        onTap: () {
          _openChat(
            room,
          );
        },
      ),
    );
  }
}