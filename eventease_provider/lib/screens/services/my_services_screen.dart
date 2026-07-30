import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_model.dart';
import '../../providers/service_provider.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() =>
      _MyServicesScreenState();
}

class _MyServicesScreenState
    extends State<MyServicesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<ServiceProvider>()
          .getMyServices();
    });
  }

  Future<void> _refresh() async {
    await context
        .read<ServiceProvider>()
        .getMyServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Services',
        ),
      ),
      body: Consumer<ServiceProvider>(
        builder: (
          context,
          serviceProvider,
          child,
        ) {
          if (serviceProvider.isLoading &&
              serviceProvider
                  .services.isEmpty) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (serviceProvider
              .services.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons
                              .business_center_outlined,
                          size: 80,
                          color:
                              Colors.grey,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          'No Services Found',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount: serviceProvider
                  .services.length,
              itemBuilder:
                  (context, index) {
                final ServiceModel
                    service =
                    serviceProvider
                        .services[index];

                return _ServiceCard(
                  service: service,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Add Service Screen
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Service',
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceCard({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              child:
                  service.images.isNotEmpty
                      ? Image.network(
                          service.images.first,
                          width:
                              double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              height: 180,
                              color: Colors
                                  .grey.shade200,
                              child: const Icon(
                                Icons.image,
                                size: 50,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 180,
                          width:
                              double.infinity,
                          color: Colors
                              .grey.shade200,
                          child: const Icon(
                            Icons.image,
                            size: 50,
                          ),
                        ),
            ),

            const SizedBox(height: 12),

            Text(
              service.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              service.description,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Chip(
                  label: Text(
                    '₹${service.price}',
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  backgroundColor:
                      service.isActive
                          ? Colors.green
                              .shade100
                          : Colors.red
                              .shade100,
                  label: Text(
                    service.isActive
                        ? 'Active'
                        : 'Inactive',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Edit Service
                  },
                  icon: const Icon(
                    Icons.edit,
                  ),
                  label:
                      const Text('Edit'),
                ),

                const SizedBox(width: 10),

                ElevatedButton.icon(
                  onPressed: () {
                    // View Service
                  },
                  icon: const Icon(
                    Icons.visibility,
                  ),
                  label:
                      const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}