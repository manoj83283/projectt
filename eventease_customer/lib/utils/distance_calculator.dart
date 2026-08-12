import 'dart:math';

class DistanceCalculator {
  DistanceCalculator._();

  static const double _earthRadiusKm = 6371;

  // =====================================================
  // CALCULATE DISTANCE (HAVERSINE)
  // =====================================================

  static double calculate({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _degreesToRadians(
      lat2 - lat1,
    );

    final dLon = _degreesToRadians(
      lon2 - lon1,
    );

    final a =
        pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            pow(sin(dLon / 2), 2);

    final c =
        2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  // =====================================================
  // DISTANCE TEXT
  // =====================================================

  static String formatDistance(
    double distanceKm,
  ) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }

    return '${distanceKm.toStringAsFixed(1)} km';
  }

  // =====================================================
  // DISTANCE IN METERS
  // =====================================================

  static double toMeters(
    double distanceKm,
  ) {
    return distanceKm * 1000;
  }

  // =====================================================
  // IS NEARBY
  // =====================================================

  static bool isNearby({
    required double distanceKm,
    double radiusKm = 10,
  }) {
    return distanceKm <= radiusKm;
  }

  // =====================================================
  // ESTIMATE TRAVEL TIME
  // =====================================================

  static String estimateTravelTime(
    double distanceKm,
  ) {
    const avgSpeedKmPerHour = 40;

    final hours =
        distanceKm / avgSpeedKmPerHour;

    final minutes =
        (hours * 60).round();

    if (minutes < 60) {
      return '$minutes min';
    }

    final hrs = minutes ~/ 60;
    final mins = minutes % 60;

    return '$hrs hr $mins min';
  }

  // =====================================================
  // FAST DELIVERY/TRAVEL LABEL
  // =====================================================

  static String travelLabel(
    double distanceKm,
  ) {
    if (distanceKm <= 2) {
      return 'Very Near';
    }

    if (distanceKm <= 5) {
      return 'Nearby';
    }

    if (distanceKm <= 15) {
      return 'Moderate';
    }

    return 'Far';
  }

  // =====================================================
  // CHECK WITHIN RADIUS
  // =====================================================

  static bool isWithinRadius({
    required double centerLat,
    required double centerLon,
    required double targetLat,
    required double targetLon,
    required double radiusKm,
  }) {
    final distance = calculate(
      lat1: centerLat,
      lon1: centerLon,
      lat2: targetLat,
      lon2: targetLon,
    );

    return distance <= radiusKm;
  }

  // =====================================================
  // SORT DISTANCES
  // =====================================================

  static List<T> sortByDistance<T>({
    required List<T> items,
    required double userLat,
    required double userLon,
    required double Function(T item)
        getLatitude,
    required double Function(T item)
        getLongitude,
  }) {
    items.sort((a, b) {
      final distanceA = calculate(
        lat1: userLat,
        lon1: userLon,
        lat2: getLatitude(a),
        lon2: getLongitude(a),
      );

      final distanceB = calculate(
        lat1: userLat,
        lon1: userLon,
        lat2: getLatitude(b),
        lon2: getLongitude(b),
      );

      return distanceA.compareTo(
        distanceB,
      );
    });

    return items;
  }

  // =====================================================
  // LOCATION VALIDATION
  // =====================================================

  static bool isValidLatitude(
    double latitude,
  ) {
    return latitude >= -90 &&
        latitude <= 90;
  }

  static bool isValidLongitude(
    double longitude,
  ) {
    return longitude >= -180 &&
        longitude <= 180;
  }

  static bool isValidLocation({
    required double latitude,
    required double longitude,
  }) {
    return isValidLatitude(
          latitude,
        ) &&
        isValidLongitude(
          longitude,
        );
  }

  // =====================================================
  // DEGREES TO RADIANS
  // =====================================================

  static double _degreesToRadians(
    double degrees,
  ) {
    return degrees * pi / 180;
  }
}