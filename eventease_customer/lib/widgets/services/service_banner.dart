import 'package:flutter/material.dart';

class ServiceBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? offerText;
  final String buttonText;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onButtonPressed;

  const ServiceBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.offerText,
    this.buttonText = "Explore",
    this.height = 200,
    this.onTap,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Banner Image

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: height,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Gradient Overlay

            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                gradient: LinearGradient(
                  begin:
                      Alignment.topCenter,
                  end:
                      Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black
                        .withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Offer Badge

            if (offerText != null &&
                offerText!.isNotEmpty)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    offerText!,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Content

            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed:
                          onButtonPressed,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white,
                        foregroundColor:
                            Colors.black,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      child: Text(
                        buttonText,
                      ),
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
}