import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import 'edit_service_screen.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({
    super.key,
    required this.service,
  });

  @override
  State<ServiceDetailsScreen> createState() =>
      _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState
    extends State<ServiceDetailsScreen> {
  late ServiceModel service;

  @override
  void initState() {
    super.initState();
    service = widget.service;
  }

  Future<void> _toggleServiceStatus() async {
    final provider =
        context.read<ServiceProvider>();

    bool success;

    if (service.isActive) {
      success =
          await provider.deactivateService(
        service.id,
      );
    } else {
      success =
          await provider.activateService(
        service.id,
      );
    }

    if (!mounted) return;

    if (success) {
      setState(() {
        service = service.copyWith(
          isActive: !service.isActive,
        );
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            service.isActive
                ? 'Service Activated'
                : 'Service Deactivated',
          ),
        ),
      );
    }
  }

  Future<void> _openEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditServiceScreen(
          service: service,
        ),
      ),
    );

    if (result == true) {
      await context
          .read<ServiceProvider>()
          .getServiceById(service.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Service Details'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
            ),
            onPressed: _openEditScreen,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ======================
            // SERVICE IMAGE
            // ======================

            if (service.images.isNotEmpty)
              SizedBox(
                height: 260,
                width: double.infinity,
                child: PageView.builder(
                  itemCount:
                      service.images.length,
                  itemBuilder:
                      (context, index) {
                    return Image.network(
                      service.images[index],
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                            context,
                            error,
                            stackTrace,
                          ) {
                        return Container(
                          color: Colors.grey
                              .shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 60,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            else
              Container(
                height: 260,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 60,
                  ),
                ),
              ),

            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  // ======================
                  // TITLE
                  // ======================

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: theme
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              service.isActive
                                  ? Colors
                                      .green
                                  : Colors
                                      .red,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                        child: Text(
                          service.isActive
                              ? 'ACTIVE'
                              : 'INACTIVE',
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // ======================
                  // PRICE
                  // ======================

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons
                            .currency_rupee,
                        color:
                            Colors.green,
                      ),
                      title:
                          const Text('Price'),
                      subtitle: Text(
                        '₹${service.price}',
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                          color:
                              Colors.green,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // ======================
                  // CATEGORY
                  // ======================

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.category,
                      ),
                      title: const Text(
                        'Category',
                      ),
                      subtitle: Text(
                        service.category ??
                            'N/A',
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // ======================
                  // DURATION
                  // ======================

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.access_time,
                      ),
                      title: const Text(
                        'Duration',
                      ),
                      subtitle: Text(
                        service.duration ??
                            'N/A',
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // ======================
                  // LOCATION
                  // ======================

                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_on,
                      ),
                      title: const Text(
                        'Location',
                      ),
                      subtitle: Text(
                        service.location ??
                            'N/A',
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    'Description',
                    style: theme
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    service.description,
                    style: theme
                        .textTheme
                        .bodyLarge,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ======================
                  // STATS
                  // ======================

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          title: 'Rating',
                          value:
                              '${service.rating ?? 0}',
                          icon: Icons.star,
                          color:
                              Colors.orange,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: _statCard(
                          title: 'Reviews',
                          value:
                              '${service.reviewCount ?? 0}',
                          icon:
                              Icons.reviews,
                          color:
                              Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 55,
                    child:
                        ElevatedButton.icon(
                      icon: Icon(
                        service.isActive
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      label: Text(
                        service.isActive
                            ? 'DEACTIVATE SERVICE'
                            : 'ACTIVATE SERVICE',
                      ),
                      onPressed:
                          _toggleServiceStatus,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 55,
                    child:
                        OutlinedButton.icon(
                      icon:
                          const Icon(Icons.edit),
                      label:
                          const Text('EDIT SERVICE'),
                      onPressed:
                          _openEditScreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}