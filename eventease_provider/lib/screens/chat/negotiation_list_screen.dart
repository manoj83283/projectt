import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';

class NegotiationListScreen extends StatefulWidget {
  const NegotiationListScreen({
    super.key,
  });

  @override
  State<NegotiationListScreen> createState() {
    return _NegotiationListScreenState();
  }
}

class _NegotiationListScreenState
    extends State<NegotiationListScreen> {
  bool _initialized = false;

  // =====================================================
  // LIFECYCLE
  // =====================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _loadNegotiations();
      },
    );
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

  String _string(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final normalized =
        value.toString().trim();

    return normalized.isEmpty
        ? fallback
        : normalized;
  }

  bool _bool(
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

    final normalized = value
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

  Map<String, dynamic> _customer(
    Map<String, dynamic> room,
  ) {
    return _asMap(
      room['customer'] ??
          room['user'] ??
          room['sender'],
    );
  }

  Map<String, dynamic> _service(
    Map<String, dynamic> room,
  ) {
    return _asMap(
      room['service'],
    );
  }

  String _roomId(
    Map<String, dynamic> room,
  ) {
    return _string(
      room['roomId'] ??
          room['chatRoomId'] ??
          room['_id'] ??
          room['id'],
    );
  }

  String _serviceId(
    Map<String, dynamic> room,
  ) {
    final service =
        _service(room);

    return _string(
      room['serviceId'] ??
          service['_id'] ??
          service['id'],
    );
  }

  String _customerId(
    Map<String, dynamic> room,
  ) {
    final customer =
        _customer(room);

    return _string(
      room['customerId'] ??
          room['userId'] ??
          room['senderId'] ??
          customer['_id'] ??
          customer['id'],
    );
  }

  String _customerName(
    Map<String, dynamic> room,
  ) {
    final customer =
        _customer(room);

    final firstName =
        _string(
      customer['firstName'],
    );

    final lastName =
        _string(
      customer['lastName'],
    );

    final combinedName = <String>[
      firstName,
      lastName,
    ]
        .where(
          (item) => item.isNotEmpty,
        )
        .join(' ')
        .trim();

    return _string(
      room['customerName'] ??
          room['userName'] ??
          customer['fullName'] ??
          customer['name'],
      fallback:
          combinedName.isNotEmpty
              ? combinedName
              : 'Customer',
    );
  }

  String _serviceName(
    Map<String, dynamic> room,
  ) {
    final service =
        _service(room);

    return _string(
      room['serviceName'] ??
          service['name'] ??
          service['title'],
      fallback:
          'Service',
    );
  }

  String _topic(
    Map<String, dynamic> room,
  ) {
    return _string(
      room['topic'] ??
          room['negotiationTopic'],
      fallback:
          'general',
    );
  }

  String _topicLabel(
    Map<String, dynamic> room,
  ) {
    final normalized = _topic(
      room,
    )
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

  IconData _topicIcon(
    Map<String, dynamic> room,
  ) {
    final normalized = _topic(
      room,
    )
        .toLowerCase()
        .replaceAll(
          '-',
          '_',
        );

    switch (normalized) {
      case 'price':
        return Icons.currency_rupee;

      case 'date_time':
      case 'datetime':
      case 'date':
      case 'time':
        return Icons.schedule_outlined;

      case 'location':
        return Icons.location_on_outlined;

      case 'requirements':
      case 'requirement':
        return Icons.checklist_outlined;

      case 'other':
        return Icons.more_horiz;

      default:
        return Icons.chat_bubble_outline;
    }
  }

  String _lastMessage(
    Map<String, dynamic> room,
  ) {
    final lastMessage =
        room['lastMessage'];

    if (lastMessage is Map) {
      final message =
          _asMap(
        lastMessage,
      );

      return _string(
        message['message'] ??
            message['content'] ??
            message['text'],
        fallback:
            'No messages yet',
      );
    }

    return _string(
      lastMessage ??
          room['lastMessageText'] ??
          room['message'],
      fallback:
          'No messages yet',
    );
  }

  int _unreadCount(
    Map<String, dynamic> room,
  ) {
    final value =
        room['unreadCount'] ??
        room['providerUnreadCount'] ??
        room['unread'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  DateTime? _updatedAt(
    Map<String, dynamic> room,
  ) {
    final value =
        room['updatedAt'] ??
        room['lastMessageAt'] ??
        room['createdAt'];

    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  // =====================================================
  // NEGOTIATION FILTER
  // =====================================================

  bool _isNegotiationRoom(
    dynamic rawRoom,
  ) {
    final room =
        _asMap(rawRoom);

    if (room.isEmpty) {
      return false;
    }

    final type = _string(
      room['chatType'] ??
          room['type'] ??
          room['roomType'],
    )
        .toLowerCase()
        .replaceAll(
          '-',
          '_',
        );

    if (type == 'negotiation' ||
        type == 'pre_booking' ||
        type == 'prebooking') {
      return true;
    }

    if (_bool(
      room['negotiationMode'] ??
          room['isNegotiation'],
    )) {
      return true;
    }

    /*
     * Negotiation rooms do not require bookingId.
     * A topic + service/customer context is therefore
     * also accepted as a compatibility fallback.
     */
    final bookingId =
        _string(
      room['bookingId'],
    );

    final negotiationTopic =
        _string(
      room['negotiationTopic'] ??
          room['topic'],
    );

    return bookingId.isEmpty &&
        negotiationTopic.isNotEmpty &&
        _serviceId(room).isNotEmpty;
  }

  List<Map<String, dynamic>> _negotiations(
    ChatProvider provider,
  ) {
    final result =
        <Map<String, dynamic>>[];

    for (final rawRoom in provider.chatRooms) {
      if (!_isNegotiationRoom(
        rawRoom,
      )) {
        continue;
      }

      final room =
          _asMap(rawRoom);

      if (room.isNotEmpty) {
        result.add(
          room,
        );
      }
    }

    result.sort(
      (
        left,
        right,
      ) {
        final leftDate =
            _updatedAt(left);

        final rightDate =
            _updatedAt(right);

        if (leftDate == null &&
            rightDate == null) {
          return 0;
        }

        if (leftDate == null) {
          return 1;
        }

        if (rightDate == null) {
          return -1;
        }

        return rightDate.compareTo(
          leftDate,
        );
      },
    );

    return result;
  }

  // =====================================================
  // LOAD
  // =====================================================

  Future<void> _loadNegotiations() async {
    await context
        .read<ChatProvider>()
        .getChatRooms();
  }

  // =====================================================
  // OPEN CHAT
  // =====================================================

  Future<void> _openChat(
    Map<String, dynamic> room,
  ) async {
    final roomId =
        _roomId(room);

    final serviceId =
        _serviceId(room);

    final customerId =
        _customerId(room);

    if (roomId.isEmpty) {
      _showMessage(
        'Negotiation room is unavailable.',
        isError: true,
      );

      return;
    }

    if (serviceId.isEmpty) {
      _showMessage(
        'Service information is unavailable.',
        isError: true,
      );

      return;
    }

    if (customerId.isEmpty) {
      _showMessage(
        'Customer information is unavailable.',
        isError: true,
      );

      return;
    }

    final provider =
        context.read<ChatProvider>();

    final opened =
        await provider.openNegotiation(
      roomId: roomId,
      serviceId: serviceId,
      customerId: customerId,
      topic: _topic(room),
    );

    if (!mounted) {
      return;
    }

    if (!opened) {
      _showMessage(
        provider.errorMessage ??
            'Unable to open negotiation chat.',
        isError: true,
      );

      return;
    }

    /*
     * Change this route only if your Provider application's
     * actual Chat screen uses a different named route.
     *
     * The arguments deliberately contain NO bookingId.
     */
    await Navigator.pushNamed(
      context,
      '/chat',
      arguments:
          <String, dynamic>{
        'chatType':
            'negotiation',

        'negotiationMode':
            true,

        'roomId':
            roomId,

        'chatRoomId':
            roomId,

        'serviceId':
            serviceId,

        'customerId':
            customerId,

        'receiverId':
            customerId,

        'customerName':
            _customerName(
          room,
        ),

        'receiverName':
            _customerName(
          room,
        ),

        'serviceName':
            _serviceName(
          room,
        ),

        'topic':
            _topic(
          room,
        ),

        'negotiationTopic':
            _topic(
          room,
        ),

        'readOnly':
            false,
      },
    );

    if (!mounted) {
      return;
    }

    await provider.markRoomAsRead(
      roomId,
    );

    if (!mounted) {
      return;
    }

    await _loadNegotiations();
  }

  // =====================================================
  // MESSAGE
  // =====================================================

  void _showMessage(
    String value, {
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
              Text(value),
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
  // DATE / TIME
  // =====================================================

  String _formatTime(
    DateTime? dateTime,
  ) {
    if (dateTime == null) {
      return '';
    }

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

    final dateOnly =
        DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference =
        today
            .difference(
              dateOnly,
            )
            .inDays;

    if (difference == 0) {
      final hour =
          date.hour == 0
              ? 12
              : date.hour > 12
                  ? date.hour - 12
                  : date.hour;

      final minute =
          date.minute
              .toString()
              .padLeft(
                2,
                '0',
              );

      final period =
          date.hour >= 12
              ? 'PM'
              : 'AM';

      return '$hour:$minute $period';
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
        final negotiations =
            _negotiations(
          provider,
        );

        return Scaffold(
          backgroundColor:
              const Color(
            0xFFF8F9FC,
          ),
          appBar: AppBar(
            title:
                const Text(
              'Negotiations',
            ),
            actions: [
              IconButton(
                tooltip:
                    'Refresh',
                onPressed:
                    provider.isLoading
                        ? null
                        : _loadNegotiations,
                icon:
                    const Icon(
                  Icons.refresh,
                ),
              ),
            ],
          ),
          body:
              RefreshIndicator(
            onRefresh:
                _loadNegotiations,
            child:
                _buildContent(
              provider:
                  provider,
              negotiations:
                  negotiations,
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // CONTENT
  // =====================================================

  Widget _buildContent({
    required ChatProvider provider,
    required List<Map<String, dynamic>>
        negotiations,
  }) {
    if (provider.isLoading &&
        negotiations.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 500,
            child: Center(
              child:
                  CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (provider.errorMessage != null &&
        provider.errorMessage!
            .trim()
            .isNotEmpty &&
        negotiations.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          24,
        ),
        children: [
          const SizedBox(
            height: 100,
          ),
          const Icon(
            Icons.error_outline,
            size: 55,
            color:
                Colors.red,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            provider.errorMessage!,
            textAlign:
                TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child:
                ElevatedButton.icon(
              onPressed:
                  _loadNegotiations,
              icon:
                  const Icon(
                Icons.refresh,
              ),
              label:
                  const Text(
                'Try Again',
              ),
            ),
          ),
        ],
      );
    }

    if (negotiations.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          24,
        ),
        children: [
          const SizedBox(
            height: 120,
          ),
          Icon(
            Icons.forum_outlined,
            size: 70,
            color:
                Colors.grey.shade400,
          ),
          const SizedBox(
            height: 18,
          ),
          const Text(
            'No negotiations yet',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Pre-booking conversations from interested customers will appear here.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(
        14,
      ),
      itemCount:
          negotiations.length,
      separatorBuilder: (
        BuildContext context,
        int index,
      ) {
        return const SizedBox(
          height: 10,
        );
      },
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        return _buildNegotiationCard(
          negotiations[index],
        );
      },
    );
  }

  // =====================================================
  // NEGOTIATION CARD
  // =====================================================

  Widget _buildNegotiationCard(
    Map<String, dynamic> room,
  ) {
    final customerName =
        _customerName(
      room,
    );

    final serviceName =
        _serviceName(
      room,
    );

    final topic =
        _topicLabel(
      room,
    );

    final lastMessage =
        _lastMessage(
      room,
    );

    final unread =
        _unreadCount(
      room,
    );

    final updatedAt =
        _updatedAt(
      room,
    );

    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        onTap: () {
          _openChat(
            room,
          );
        },
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    child:
                        const Icon(
                      Icons.person,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customerName,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                            if (updatedAt !=
                                null)
                              Text(
                                _formatTime(
                                  updatedAt,
                                ),
                                style:
                                    TextStyle(
                                  fontSize: 11,
                                  color:
                                      Colors.grey
                                          .shade600,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          serviceName,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              TextStyle(
                            color:
                                Colors.grey
                                    .shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.blue
                          .withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      _topicIcon(
                        room,
                      ),
                      size: 17,
                      color:
                          Colors.blue,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      'Topic: $topic',
                      style:
                          const TextStyle(
                        color:
                            Colors.blue,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons
                        .format_quote,
                    size: 20,
                    color:
                        Colors.grey,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                    child: Text(
                      lastMessage,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        color:
                            Colors.grey
                                .shade800,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (unread > 0) ...[
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      constraints:
                          const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration:
                          const BoxDecoration(
                        color:
                            Colors.red,
                        shape:
                            BoxShape.circle,
                      ),
                      alignment:
                          Alignment.center,
                      child: Text(
                        unread > 99
                            ? '99+'
                            : '$unread',
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton.icon(
                  onPressed: () {
                    _openChat(
                      room,
                    );
                  },
                  icon:
                      const Icon(
                    Icons
                        .chat_bubble_outline,
                  ),
                  label:
                      const Text(
                    'OPEN CHAT',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}