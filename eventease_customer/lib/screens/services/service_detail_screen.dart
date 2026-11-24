import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

import '../chat/negotiation_menu.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({
    super.key,
  });

  @override
  State<ServiceDetailScreen> createState() {
    return _ServiceDetailScreenState();
  }
}

class _ServiceDetailScreenState
    extends State<ServiceDetailScreen> {
  // =====================================================
  // ARGUMENTS
  // =====================================================

  Map<String, dynamic>? _getServiceArguments() {
    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      return args;
    }

    if (args is Map) {
      return args.map(
        (
          key,
          dynamic value,
        ) {
          return MapEntry(
            key.toString(),
            value,
          );
        },
      );
    }

    return null;
  }

  // =====================================================
  // MAP HELPER
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

  // =====================================================
  // STRING HELPER
  // =====================================================

  String _getStringValue(
    Map<String, dynamic>? service,
    String key,
    String fallback,
  ) {
    final value =
        service?[key];

    if (value == null) {
      return fallback;
    }

    if (value is Map) {
      final map =
          _asMap(value);

      final candidates =
          <dynamic>[
        map['businessName'],
        map['shopName'],
        map['fullName'],
        map['name'],
        map['title'],
        map['_id'],
        map['id'],
      ];

      for (final candidate in candidates) {
        if (candidate == null) {
          continue;
        }

        final text =
            candidate
                .toString()
                .trim();

        if (text.isNotEmpty) {
          return text;
        }
      }

      return fallback;
    }

    final text =
        value.toString().trim();

    return text.isEmpty
        ? fallback
        : text;
  }

  // =====================================================
  // BOOLEAN HELPER
  // =====================================================

  bool _getBoolValue(
    Map<String, dynamic>? source,
    List<String> keys, {
    bool fallback = false,
  }) {
    if (source == null) {
      return fallback;
    }

    for (final key in keys) {
      if (!source.containsKey(key)) {
        continue;
      }

      final value =
          source[key];

      if (value is bool) {
        return value;
      }

      if (value is num) {
        return value != 0;
      }

      final normalized =
          value
              ?.toString()
              .trim()
              .toLowerCase();

      if (normalized == null ||
          normalized.isEmpty) {
        continue;
      }

      if (<String>{
        'true',
        '1',
        'yes',
        'online',
        'active',
        'available',
        'ready',
        'approved',
      }.contains(normalized)) {
        return true;
      }

      if (<String>{
        'false',
        '0',
        'no',
        'offline',
        'inactive',
        'unavailable',
        'full',
        'disabled',
      }.contains(normalized)) {
        return false;
      }
    }

    return fallback;
  }

  // =====================================================
  // PRICE
  // =====================================================

  String _getPriceValue(
    Map<String, dynamic>? service,
  ) {
    final value =
        service?['price'] ??
        service?['basePrice'] ??
        service?['pricePerHour'];

    if (value == null) {
      return '0';
    }

    if (value is num) {
      return value.toStringAsFixed(
        0,
      );
    }

    final parsed =
        num.tryParse(
      value.toString(),
    );

    return parsed?.toStringAsFixed(
          0,
        ) ??
        '0';
  }

  // =====================================================
  // SERVICE ID
  // =====================================================

  String _extractServiceId(
    Map<String, dynamic>? service,
  ) {
    if (service == null) {
      return '';
    }

    return (service['_id'] ??
            service['id'] ??
            service['serviceId'] ??
            '')
        .toString()
        .trim();
  }

  // =====================================================
  // PROVIDER ID
  // =====================================================

  String _extractProviderId(
    Map<String, dynamic>? service,
  ) {
    if (service == null) {
      return '';
    }

    final directProviderId =
        service['providerId'];

    if (directProviderId != null) {
      final value =
          directProviderId
              .toString()
              .trim();

      if (value.isNotEmpty) {
        return value;
      }
    }

    final provider =
        service['provider'];

    if (provider is Map) {
      final providerMap =
          _asMap(provider);

      return (providerMap['_id'] ??
              providerMap['id'] ??
              providerMap['providerId'] ??
              '')
          .toString()
          .trim();
    }

    return provider
            ?.toString()
            .trim() ??
        '';
  }

  // =====================================================
  // SELECTED BOOKING DATE
  // =====================================================

  String _selectedBookingDate(
    Map<String, dynamic>? service,
  ) {
    if (service == null) {
      return '';
    }

    final availability =
        _asMap(
      service['availability'],
    );

    return (service['bookingDate'] ??
            service['selectedDate'] ??
            service['date'] ??
            availability['bookingDate'] ??
            availability['selectedDate'] ??
            availability['date'] ??
            '')
        .toString()
        .trim();
  }

  // =====================================================
  // SELECTED BOOKING TIME
  // =====================================================

  String _selectedBookingTime(
    Map<String, dynamic>? service,
  ) {
    if (service == null) {
      return '';
    }

    final availability =
        _asMap(
      service['availability'],
    );

    return (service['bookingTime'] ??
            service['selectedTime'] ??
            service['time'] ??
            service['timeSlot'] ??
            availability['bookingTime'] ??
            availability['selectedTime'] ??
            availability['time'] ??
            availability['timeSlot'] ??
            '')
        .toString()
        .trim();
  }

  // =====================================================
  // PROVIDER ONLINE
  // =====================================================

  bool _providerOnline(
    Map<String, dynamic>? service,
  ) {
    if (service == null) {
      return false;
    }

    if (service.containsKey(
      'providerOnline',
    )) {
      return _getBoolValue(
        service,
        <String>[
          'providerOnline',
        ],
      );
    }

    final provider =
        service['provider'];

    if (provider is Map) {
      final providerMap =
          _asMap(provider);

      return _getBoolValue(
        providerMap,
        <String>[
          'isOnline',
          'online',
          'isAvailable',
          'availabilityStatus',
          'presence',
          'onlineStatus',
          'status',
        ],
      );
    }

    return false;
  }

  // =====================================================
  // SERVICE ACTIVE
  // =====================================================

  bool _serviceActive(
    Map<String, dynamic>? service,
  ) {
    if (service == null) {
      return false;
    }

    final isActive =
        _getBoolValue(
      service,
      <String>[
        'isActive',
        'active',
      ],
      fallback: true,
    );

    final isAvailable =
        _getBoolValue(
      service,
      <String>[
        'isAvailable',
        'available',
      ],
      fallback: true,
    );

    final isFull =
        _getBoolValue(
      service,
      <String>[
        'isFull',
        'full',
      ],
      fallback: false,
    );

    final status =
        (service['status'] ??
                service['approvalStatus'] ??
                '')
            .toString()
            .trim()
            .toLowerCase();

    final explicitlyInactive =
        <String>{
      'inactive',
      'disabled',
      'rejected',
      'deleted',
      'unavailable',
    }.contains(status);

    return isActive &&
        isAvailable &&
        !isFull &&
        !explicitlyInactive;
  }

  // =====================================================
  // SLOT AVAILABLE
  // =====================================================

  bool _slotAvailable(
    Map<String, dynamic>? service,
  ) {
    if (service == null) {
      return false;
    }

    /*
     * The backend remains authoritative for whether the
     * selected provider/service/date/time combination is
     * available.
     */

    if (service.containsKey(
      'slotAvailable',
    )) {
      return _getBoolValue(
        service,
        <String>[
          'slotAvailable',
        ],
      );
    }

    if (service.containsKey(
      'isSlotAvailable',
    )) {
      return _getBoolValue(
        service,
        <String>[
          'isSlotAvailable',
        ],
      );
    }

    final availability =
        service['availability'];

    if (availability is Map) {
      final availabilityMap =
          _asMap(
        availability,
      );

      if (availabilityMap.containsKey(
        'slotAvailable',
      )) {
        return _getBoolValue(
          availabilityMap,
          <String>[
            'slotAvailable',
          ],
        );
      }

      if (availabilityMap.containsKey(
        'isSlotAvailable',
      )) {
        return _getBoolValue(
          availabilityMap,
          <String>[
            'isSlotAvailable',
          ],
        );
      }

      if (availabilityMap.containsKey(
        'available',
      )) {
        return _getBoolValue(
          availabilityMap,
          <String>[
            'available',
          ],
        );
      }
    }

    /*
     * Do not guess that an unknown slot is free.
     */
    return false;
  }

  // =====================================================
  // NEGOTIATION RULE
  // =====================================================

  bool _canNegotiate(
    Map<String, dynamic>? service,
  ) {
    final providerOnline =
        _providerOnline(
      service,
    );

    final serviceActive =
        _serviceActive(
      service,
    );

    final slotAvailable =
        _slotAvailable(
      service,
    );

    /*
     * PRE-BOOKING NEGOTIATION RULE
     *
     * No bookingId.
     * No booking status.
     * No OTP verification.
     */

    final canNegotiate =
        providerOnline &&
        serviceActive &&
        slotAvailable;

    return canNegotiate;
  }

  // =====================================================
  // PROVIDER PROFILE
  // =====================================================

  void _openProviderProfile(
    Map<String, dynamic>? service,
  ) {
    Navigator.pushNamed(
      context,
      RouteConfig.providerProfile,
      arguments:
          service,
    );
  }

  // =====================================================
  // NEGOTIATION
  // =====================================================

  Future<void> _openNegotiation(
    Map<String, dynamic>? service,
  ) async {
    final providerOnline =
        _providerOnline(
      service,
    );

    final serviceActive =
        _serviceActive(
      service,
    );

    final slotAvailable =
        _slotAvailable(
      service,
    );

    final canNegotiate =
        providerOnline &&
        serviceActive &&
        slotAvailable;

    // =================================================
    // PROVIDER / SERVICE / SLOT NOT AVAILABLE
    // =================================================

    if (!canNegotiate) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'The Provider is unavailable for the selected date and time. Please select another slot.',
          ),
        ),
      );

      return;
    }

    final serviceId =
        _extractServiceId(
      service,
    );

    final providerId =
        _extractProviderId(
      service,
    );

    if (serviceId.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Service information is unavailable.',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );

      return;
    }

    if (providerId.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Provider information is unavailable.',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );

      return;
    }

    final serviceName =
        _getStringValue(
      service,
      'name',
      'Service',
    );

    final providerName =
        _getStringValue(
      service,
      'providerName',
      _getStringValue(
        service,
        'provider',
        'Service Provider',
      ),
    );

    // =================================================
    // CENTRAL NEGOTIATION MENU
    // =================================================

    final selectedTopic =
        await NegotiationMenu.show(
      context,
      serviceName:
          serviceName,
      providerName:
          providerName,
    );

    if (!mounted ||
        selectedTopic == null) {
      return;
    }

    final topicValue =
        negotiationTopicValue(
      selectedTopic,
    );

    final starterMessage =
        negotiationStarterMessage(
      selectedTopic,
    );

    final bookingDate =
        _selectedBookingDate(
      service,
    );

    final bookingTime =
        _selectedBookingTime(
      service,
    );

    /*
     * IMPORTANT
     *
     * This is PRE-BOOKING negotiation.
     *
     * Do NOT pass bookingId.
     * Do NOT generate booking:<bookingId>.
     * Do NOT check accepted status.
     * Do NOT check OTP.
     *
     * ChatScreen -> ChatProvider.openNegotiation()
     * creates/opens the negotiation room.
     */

    await Navigator.pushNamed(
      context,
      RouteConfig.chat,
      arguments:
          <String, dynamic>{
        'chatType':
            'negotiation',

        'negotiationMode':
            true,

        'serviceId':
            serviceId,

        'serviceName':
            serviceName,

        'providerId':
            providerId,

        'receiverId':
            providerId,

        'providerName':
            providerName,

        'receiverName':
            providerName,

        'topic':
            topicValue,

        'negotiationTopic':
            topicValue,

        'starterMessage':
            starterMessage,

        'bookingDate':
            bookingDate,

        'bookingTime':
            bookingTime,

        'service':
            service,

        'providerOnline':
            providerOnline,

        'serviceActive':
            serviceActive,

        'slotAvailable':
            slotAvailable,

        'canNegotiate':
            true,

        /*
         * Explicitly no Booking Chat permissions.
         */
        'readOnly':
            false,

        'chatEnabled':
            true,
      },
    );
  }

  // =====================================================
  // CART
  // =====================================================

  void _addToCart(
    Map<String, dynamic>? service,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '${_getStringValue(service, 'name', 'Service')} added to cart',
        ),
      ),
    );
  }

  // =====================================================
  // BOOK
  // =====================================================

  void _bookNow(
    Map<String, dynamic>? service,
  ) {
    Navigator.pushNamed(
      context,
      RouteConfig.booking,
      arguments:
          <String, dynamic>{
        'service':
            service,
      },
    );
  }

  // =====================================================
  // SHARE
  // =====================================================

  void _shareService(
    Map<String, dynamic>? service,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Share option coming soon',
        ),
      ),
    );
  }

  // =====================================================
  // FAVORITE
  // =====================================================

  void _toggleFavorite() {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Added to favorites',
        ),
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
    final service =
        _getServiceArguments();

    final serviceName =
        _getStringValue(
      service,
      'name',
      'Service Name',
    );

    final providerName =
        _getStringValue(
      service,
      'providerName',
      _getStringValue(
        service,
        'provider',
        'Provider Name',
      ),
    );

    final location =
        _getStringValue(
      service,
      'location',
      'Hyderabad',
    );

    final rating =
        _getStringValue(
      service,
      'rating',
      '4.8',
    );

    final price =
        _getPriceValue(
      service,
    );

    final providerOnline =
        _providerOnline(
      service,
    );

    final serviceActive =
        _serviceActive(
      service,
    );

    final slotAvailable =
        _slotAvailable(
      service,
    );

    final canNegotiate =
        _canNegotiate(
      service,
    );

    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF8F9FC,
      ),
      appBar: AppBar(
        title:
            const Text(
          'Service Details',
        ),
        actions: [
          IconButton(
            tooltip:
                'Share',
            onPressed: () {
              _shareService(
                service,
              );
            },
            icon:
                const Icon(
              Icons.share,
            ),
          ),
          IconButton(
            tooltip:
                'Favorite',
            onPressed:
                _toggleFavorite,
            icon:
                const Icon(
              Icons.favorite_border,
            ),
          ),
        ],
      ),

      // =================================================
      // BODY
      // =================================================

      body:
          SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // =============================================
            // SERVICE IMAGE
            // =============================================

            Container(
              height: 250,
              width:
                  double.infinity,
              color:
                  ThemeConfig.primaryColor
                      .withValues(
                alpha: 0.1,
              ),
              child:
                  const Icon(
                Icons.image,
                size: 100,
                color:
                    ThemeConfig
                        .primaryColor,
              ),
            ),

            // =============================================
            // SERVICE INFORMATION
            // =============================================

            Padding(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style:
                        const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color:
                            Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        rating,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        '(245 Reviews)',
                        style:
                            TextStyle(
                          color:
                              Colors.grey
                                  .shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color:
                            Colors.red,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Container(
                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.green
                              .withValues(
                        alpha: 0.1,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.currency_rupee,
                          color:
                              Colors.green,
                        ),
                        Text(
                          price,
                          style:
                              const TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // =======================================
                  // NEGOTIATION AVAILABILITY
                  // =======================================

                  _buildAvailabilityCard(
                    providerOnline:
                        providerOnline,
                    serviceActive:
                        serviceActive,
                    slotAvailable:
                        slotAvailable,
                    canNegotiate:
                        canNegotiate,
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // =======================================
                  // PROVIDER
                  // =======================================

                  const Text(
                    'Provider',
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Card(
                    child: ListTile(
                      onTap: () {
                        _openProviderProfile(
                          service,
                        );
                      },
                      leading:
                          const CircleAvatar(
                        child: Icon(
                          Icons.person,
                        ),
                      ),
                      title: Text(
                        providerName,
                      ),
                      subtitle: Text(
                        providerOnline
                            ? 'Verified Provider • Online'
                            : 'Verified Provider • Offline',
                      ),
                      trailing:
                          const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // =======================================
                  // DESCRIPTION
                  // =======================================

                  const Text(
                    'Description',
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    'Professional event service with experienced staff, high-quality equipment, and excellent customer support. Perfect for weddings, birthday events, corporate functions, and special occasions.',
                    style:
                        TextStyle(
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // =======================================
                  // FEATURES
                  // =======================================

                  const Text(
                    'Features',
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _buildFeature(
                    Icons.check_circle,
                    'Experienced Team',
                  ),

                  _buildFeature(
                    Icons.check_circle,
                    'Affordable Pricing',
                  ),

                  _buildFeature(
                    Icons.check_circle,
                    '24x7 Support',
                  ),

                  _buildFeature(
                    Icons.check_circle,
                    'Instant Booking',
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // =======================================
                  // REVIEWS
                  // =======================================

                  const Text(
                    'Customer Reviews',
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const Card(
                    child: ListTile(
                      leading:
                          CircleAvatar(
                        child: Icon(
                          Icons.person,
                        ),
                      ),
                      title:
                          Text(
                        'Excellent Service',
                      ),
                      subtitle:
                          Text(
                        'Highly recommended for events.',
                      ),
                      trailing: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color:
                                Colors.orange,
                            size: 18,
                          ),
                          Text(
                            '5',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 110,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // =================================================
      // BOTTOM ACTIONS
      // =================================================

      bottomNavigationBar:
          SafeArea(
        child: Container(
          padding:
              const EdgeInsets.all(
            16,
          ),
          color:
              Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child:
                      OutlinedButton.icon(
                    style:
                        OutlinedButton.styleFrom(
                      minimumSize:
                          const Size(
                        0,
                        48,
                      ),
                      padding:
                          EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _openNegotiation(
                        service,
                      );
                    },
                    icon:
                        const Icon(
                      Icons
                          .chat_bubble_outline,
                      size: 18,
                    ),
                    label:
                        const Text(
                      'Chat',
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: SizedBox(
                  height: 48,
                  child:
                      OutlinedButton(
                    style:
                        OutlinedButton.styleFrom(
                      minimumSize:
                          const Size(
                        0,
                        48,
                      ),
                      padding:
                          EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _addToCart(
                        service,
                      );
                    },
                    child:
                        const Text(
                      'Add Cart',
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: SizedBox(
                  height: 48,
                  child:
                      ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      minimumSize:
                          const Size(
                        0,
                        48,
                      ),
                      padding:
                          EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _bookNow(
                        service,
                      );
                    },
                    child:
                        const Text(
                      'Book Now',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // AVAILABILITY CARD
  // =====================================================

  Widget _buildAvailabilityCard({
    required bool providerOnline,
    required bool serviceActive,
    required bool slotAvailable,
    required bool canNegotiate,
  }) {
    final color =
        canNegotiate
            ? Colors.green
            : Colors.orange;

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border:
            Border.all(
          color:
              color.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                canNegotiate
                    ? Icons
                        .chat_bubble_outline
                    : Icons
                        .chat_bubble_outline,
                color: color,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  canNegotiate
                      ? 'Negotiation Available'
                      : 'Negotiation Unavailable',
                  style:
                      TextStyle(
                    color: color,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          _availabilityRow(
            'Provider online',
            providerOnline,
          ),

          _availabilityRow(
            'Service active',
            serviceActive,
          ),

          _availabilityRow(
            'Selected slot available',
            slotAvailable,
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            canNegotiate
                ? 'Chat with the Provider about price, date/time, location, requirements, or general questions before booking.'
                : 'The Provider must be online, the service must be active, and the selected slot must be available before negotiation can start.',
            style:
                TextStyle(
              fontSize: 12,
              color:
                  Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // AVAILABILITY ROW
  // =====================================================

  Widget _availabilityRow(
    String title,
    bool available,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 3,
      ),
      child: Row(
        children: [
          Icon(
            available
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            size: 18,
            color:
                available
                    ? Colors.green
                    : Colors.red,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            title,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // FEATURE
  // =====================================================

  Widget _buildFeature(
    IconData icon,
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                Colors.green,
            size: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              title,
            ),
          ),
        ],
      ),
    );
  }
}