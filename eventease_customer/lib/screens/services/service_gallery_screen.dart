import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

class ServiceGalleryScreen extends StatefulWidget {
  const ServiceGalleryScreen({
    super.key,
  });

  @override
  State<ServiceGalleryScreen> createState() =>
      _ServiceGalleryScreenState();
}

class _ServiceGalleryScreenState
    extends State<ServiceGalleryScreen> {
  final PageController pageController =
      PageController();

  int currentIndex = 0;

  final List<String> galleryImages = [
    'https://via.placeholder.com/800x500',
    'https://via.placeholder.com/800x501',
    'https://via.placeholder.com/800x502',
    'https://via.placeholder.com/800x503',
    'https://via.placeholder.com/800x504',
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${currentIndex + 1} / ${galleryImages.length}',
        ),
      ),

      body: Column(
        children: [
          // ===========================
          // MAIN GALLERY
          // ===========================

          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount:
                  galleryImages.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder:
                  (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Container(
                    width:
                        double.infinity,
                    color: Colors.black,
                    child: Image.network(
                      galleryImages[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (
                        context,
                        child,
                        progress,
                      ) {
                        if (progress ==
                            null) {
                          return child;
                        }

                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 80,
                            color:
                                Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // ===========================
          // INDICATORS
          // ===========================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                galleryImages.length,
                (index) {
                  return AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 250,
                    ),
                    margin:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 4,
                    ),
                    width:
                        currentIndex ==
                                index
                            ? 24
                            : 8,
                    height: 8,
                    decoration:
                        BoxDecoration(
                      color:
                          currentIndex ==
                                  index
                              ? ThemeConfig
                                  .primaryColor
                              : Colors.grey,
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ===========================
          // THUMBNAILS
          // ===========================

          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection:
                  Axis.horizontal,
              padding:
                  const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 15,
              ),
              itemCount:
                  galleryImages.length,
              itemBuilder:
                  (context, index) {
                final selected =
                    currentIndex ==
                        index;

                return GestureDetector(
                  onTap: () {
                    pageController.animateToPage(
                      index,
                      duration:
                          const Duration(
                        milliseconds:
                            300,
                      ),
                      curve:
                          Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 80,
                    margin:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 5,
                    ),
                    decoration:
                        BoxDecoration(
                      border: Border.all(
                        color: selected
                            ? ThemeConfig
                                .primaryColor
                            : Colors
                                .transparent,
                        width: 3,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                      child:
                          Image.network(
                        galleryImages[
                            index],
                        fit:
                            BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}