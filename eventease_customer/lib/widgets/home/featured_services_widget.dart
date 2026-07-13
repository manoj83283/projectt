import 'package:flutter/material.dart';

import '../services/service_card.dart';

class FeaturedServiceModel {
  final String id;
  final String title;
  final String category;
  final String providerName;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double price;
  final double? originalPrice;
  final bool isFavorite;

  const FeaturedServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.providerName,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.price,
    this.originalPrice,
    this.isFavorite = false,
  });
}

class FeaturedServicesWidget extends StatelessWidget {
  final String title;
  final List<FeaturedServiceModel> services;
  final bool isLoading;

  final VoidCallback? onSeeAll;

  final Function(FeaturedServiceModel)?
      onServiceTap;

  final Function(FeaturedServiceModel)?
      onFavoriteTap;

  final Function(FeaturedServiceModel)?
      onBookNow;

  const FeaturedServicesWidget({
    super.key,
    this.title = "Featured Services",
    required this.services,
    this.isLoading = false,
    this.onSeeAll,
    this.onServiceTap,
    this.onFavoriteTap,
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ==========================
        // HEADER
        // ==========================

        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: const Text(
                  "See All",
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ==========================
        // LOADING
        // ==========================

        if (isLoading)
          SizedBox(
            height: 380,
            child: ListView.builder(
              scrollDirection:
                  Axis.horizontal,
              itemCount: 3,
              itemBuilder:
                  (context, index) {
                return Container(
                  width: 300,
                  margin:
                      const EdgeInsets.only(
                    left: 16,
                    bottom: 10,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .grey.shade200,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                );
              },
            ),
          )

        // ==========================
        // EMPTY STATE
        // ==========================

        else if (services.isEmpty)
          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 30,
            ),
            child: Text(
              "No Featured Services Available",
            ),
          )

        // ==========================
        // SERVICES LIST
        // ==========================

        else
          SizedBox(
            height: 420,
            child: ListView.builder(
              scrollDirection:
                  Axis.horizontal,
              padding:
                  const EdgeInsets.only(
                left: 16,
                right: 8,
              ),
              itemCount:
                  services.length,
              itemBuilder:
                  (context, index) {
                final service =
                    services[index];

                return SizedBox(
                  width: 320,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(
                      right: 12,
                    ),
                    child: ServiceCard(
                      id: service.id,
                      title: service.title,
                      category:
                          service.category,
                      providerName:
                          service.providerName,
                      imageUrl:
                          service.imageUrl,
                      rating:
                          service.rating,
                      reviewCount:
                          service.reviewCount,
                      price:
                          service.price,
                      originalPrice:
                          service
                              .originalPrice,
                      isFavorite:
                          service.isFavorite,
                      onTap: () {
                        onServiceTap
                            ?.call(
                          service,
                        );
                      },
                      onFavorite: () {
                        onFavoriteTap
                            ?.call(
                          service,
                        );
                      },
                      onBookNow: () {
                        onBookNow
                            ?.call(
                          service,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}