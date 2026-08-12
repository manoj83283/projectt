import 'package:flutter/material.dart';

class DistanceWidget extends StatelessWidget {
  final double distanceKm;
  final String? travelTime;
  final bool showIcon;
  final bool showTravelTime;
  final bool compact;
  final Color? color;

  const DistanceWidget({
    required this.distanceKm, super.key,
    this.travelTime,
    this.showIcon = true,
    this.showTravelTime = true,
    this.compact = false,
    this.color,
  });

  Color getDistanceColor() {
    if (distanceKm <= 5) {
      return Colors.green;
    } else if (distanceKm <= 15) {
      return Colors.orange;
    }
    return Colors.red;
  }

  String getDistanceText() {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final distanceColor =
        color ?? getDistanceColor();

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon)
            Icon(
              Icons.location_on,
              size: 16,
              color: distanceColor,
            ),
          if (showIcon)
            const SizedBox(width: 4),

          Text(
            getDistanceText(),
            style: TextStyle(
              fontSize: 13,
              color: distanceColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: distanceColor.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              distanceColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon)
            Icon(
              Icons.location_on,
              color: distanceColor,
              size: 18,
            ),

          if (showIcon)
            const SizedBox(width: 6),

          Text(
            getDistanceText(),
            style: TextStyle(
              color: distanceColor,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (showTravelTime &&
              travelTime != null) ...[
            const SizedBox(width: 8),

            Container(
              width: 1,
              height: 14,
              color: Colors.grey.shade300,
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.access_time,
              size: 16,
              color: Colors.grey,
            ),

            const SizedBox(width: 4),

            Text(
              travelTime!,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Nearby Badge Widget
class NearbyBadge extends StatelessWidget {
  final double distanceKm;

  const NearbyBadge({
    required this.distanceKm, super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (distanceKm > 10) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: const Text(
        'Nearby',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}