import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({
    super.key,
  });

  @override
  State<ServiceDetailScreen> createState() =>
      _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Map<String, dynamic>? _getServiceArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      return args;
    }

    if (args is Map) {
      return args.map(
        (key, value) => MapEntry(
          key.toString(),
          value,
        ),
      );
    }

    return null;
  }

  String _getStringValue(
    Map<String, dynamic>? service,
    String key,
    String fallback,
  ) {
    final value = service?[key];

    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  String _getPriceValue(
    Map<String, dynamic>? service,
  ) {
    final value = service?['price'];

    if (value == null) {
      return '10000';
    }

    if (value is num) {
      return value.toStringAsFixed(0);
    }

    final parsed = num.tryParse(
      value.toString(),
    );

    return parsed?.toStringAsFixed(0) ?? '10000';
  }

  void _openProviderProfile(
    Map<String, dynamic>? service,
  ) {
    Navigator.pushNamed(
      context,
      RouteConfig.providerProfile,
      arguments: service,
    );
  }

  void _openChat(
    Map<String, dynamic>? service,
  ) {
    Navigator.pushNamed(
      context,
      RouteConfig.chat,
      arguments: {
        'service': service,
      },
    );
  }

  void _addToCart(
    Map<String, dynamic>? service,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_getStringValue(service, 'name', 'Service')} added to cart',
        ),
      ),
    );
  }

  void _bookNow(
    Map<String, dynamic>? service,
  ) {
    Navigator.pushNamed(
      context,
      RouteConfig.booking,
      arguments: {
        'service': service,
      },
    );
  }

  void _shareService(
    Map<String, dynamic>? service,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Share option coming soon',
        ),
      ),
    );
  }

  void _toggleFavorite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Added to favorites',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = _getServiceArguments();

    final serviceName = _getStringValue(
      service,
      'name',
      'Service Name',
    );

    final providerName = _getStringValue(
      service,
      'provider',
      'Provider Name',
    );

    final location = _getStringValue(
      service,
      'location',
      'Hyderabad',
    );

    final rating = _getStringValue(
      service,
      'rating',
      '4.8',
    );

    final price = _getPriceValue(
      service,
    );

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FC,
      ),
      appBar: AppBar(
        title: const Text(
          'Service Details',
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: () {
              _shareService(
                service,
              );
            },
            icon: const Icon(
              Icons.share,
            ),
          ),
          IconButton(
            tooltip: 'Favorite',
            onPressed: _toggleFavorite,
            icon: const Icon(
              Icons.favorite_border,
            ),
          ),
        ],
      ),

      // =====================================
      // BODY
      // =====================================

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================
            // SERVICE IMAGE
            // =====================================

            Container(
              height: 250,
              width: double.infinity,
              color: ThemeConfig.primaryColor.withOpacity(
                0.1,
              ),
              child: const Icon(
                Icons.image,
                size: 100,
                color: ThemeConfig.primaryColor,
              ),
            ),

            // =====================================
            // SERVICE INFO
            // =====================================

            Padding(
              padding: const EdgeInsets.all(
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        '(245 Reviews)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
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
                        color: Colors.red,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Container(
                    padding: const EdgeInsets.all(
                      14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(
                        0.1,
                      ),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.currency_rupee,
                          color: Colors.green,
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // =====================================
                  // PROVIDER
                  // =====================================

                  const Text(
                    'Provider',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.person,
                        ),
                      ),
                      title: Text(
                        providerName,
                      ),
                      subtitle: const Text(
                        'Verified Provider',
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // =====================================
                  // DESCRIPTION
                  // =====================================

                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    'Professional event service with experienced staff, high-quality equipment, and excellent customer support. Perfect for weddings, birthday events, corporate functions, and special occasions.',
                    style: TextStyle(
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // =====================================
                  // FEATURES
                  // =====================================

                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

                  // =====================================
                  // REVIEWS
                  // =====================================

                  const Text(
                    'Customer Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.person,
                        ),
                      ),
                      title: Text(
                        'Excellent Service',
                      ),
                      subtitle: Text(
                        'Highly recommended for events.',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.orange,
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

      // =====================================
      // BOTTOM ACTIONS
      // =====================================

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(
            16,
          ),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        0,
                        48,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _openChat(
                        service,
                      );
                    },
                    icon: const Icon(
                      Icons.chat,
                      size: 18,
                    ),
                    label: const Text(
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
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        0,
                        48,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _addToCart(
                        service,
                      );
                    },
                    child: const Text(
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        0,
                        48,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _bookNow(
                        service,
                      );
                    },
                    child: const Text(
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

  Widget _buildFeature(
    IconData icon,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green,
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