import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String id;
  final String title;
  final String? imageUrl;
  final IconData icon;
  final int serviceCount;
  final Color color;
  final VoidCallback? onTap;

  const CategoryCard({
    required this.id, required this.title, required this.icon, super.key,
    this.imageUrl,
    this.serviceCount = 0,
    this.color = Colors.blue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.90),
              color.withValues(alpha: 0.65),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  color.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              // =====================
              // IMAGE OR ICON
              // =====================

              if (imageUrl != null &&
                  imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  child: Image.network(
                    imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          context,
                          error,
                          stackTrace,
                        ) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 30,
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 70,
                  height: 70,
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 34,
                  ),
                ),

              const SizedBox(height: 12),

              // =====================
              // CATEGORY TITLE
              // =====================

              Text(
                title,
                textAlign:
                    TextAlign.center,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                '$serviceCount Services',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}