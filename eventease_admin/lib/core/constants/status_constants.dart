class StatusConstants {
  StatusConstants._();

  // =====================================================
  // COMMON STATUS
  // =====================================================

  static const String active =
      'active';

  static const String inactive =
      'inactive';

  static const String pending =
      'pending';

  static const String approved =
      'approved';

  static const String rejected =
      'rejected';

  static const String suspended =
      'suspended';

  static const String blocked =
      'blocked';

  static const String deleted =
      'deleted';

  // =====================================================
  // BOOKING STATUS
  // =====================================================

  static const String bookingPending =
      'pending';

  static const String bookingConfirmed =
      'confirmed';

  static const String bookingAssigned =
      'assigned';

  static const String bookingInProgress =
      'in_progress';

  static const String bookingCompleted =
      'completed';

  static const String bookingCancelled =
      'cancelled';

  static const String bookingRefunded =
      'refunded';

  // =====================================================
  // ORDER STATUS
  // =====================================================

  static const String orderPlaced =
      'placed';

  static const String orderAccepted =
      'accepted';

  static const String orderProcessing =
      'processing';

  static const String orderPacked =
      'packed';

  static const String orderShipped =
      'shipped';

  static const String orderOutForDelivery =
      'out_for_delivery';

  static const String orderDelivered =
      'delivered';

  static const String orderCancelled =
      'cancelled';

  static const String orderReturned =
      'returned';

  static const String orderRefunded =
      'refunded';

  // =====================================================
  // PAYMENT STATUS
  // =====================================================

  static const String paymentPending =
      'pending';

  static const String paymentInitiated =
      'initiated';

  static const String paymentProcessing =
      'processing';

  static const String paymentSuccess =
      'success';

  static const String paymentFailed =
      'failed';

  static const String paymentRefunded =
      'refunded';

  static const String paymentPartialRefund =
      'partial_refund';

  // =====================================================
  // SETTLEMENT STATUS
  // =====================================================

  static const String settlementPending =
      'pending';

  static const String settlementApproved =
      'approved';

  static const String settlementProcessing =
      'processing';

  static const String settlementPaid =
      'paid';

  static const String settlementRejected =
      'rejected';

  // =====================================================
  // KYC STATUS
  // =====================================================

  static const String kycPending =
      'pending';

  static const String kycUnderReview =
      'under_review';

  static const String kycApproved =
      'approved';

  static const String kycRejected =
      'rejected';

  static const String kycResubmissionRequired =
      'resubmission_required';

  // =====================================================
  // PROVIDER STATUS
  // =====================================================

  static const String providerPending =
      'pending';

  static const String providerApproved =
      'approved';

  static const String providerRejected =
      'rejected';

  static const String providerSuspended =
      'suspended';

  static const String providerBlocked =
      'blocked';

  // =====================================================
  // SERVICE STATUS
  // =====================================================

  static const String serviceDraft =
      'draft';

  static const String servicePending =
      'pending';

  static const String serviceApproved =
      'approved';

  static const String serviceRejected =
      'rejected';

  static const String serviceActive =
      'active';

  static const String serviceInactive =
      'inactive';

  // =====================================================
  // SUPPORT TICKET STATUS
  // =====================================================

  static const String ticketOpen =
      'open';

  static const String ticketAssigned =
      'assigned';

  static const String ticketInProgress =
      'in_progress';

  static const String ticketWaitingCustomer =
      'waiting_customer';

  static const String ticketResolved =
      'resolved';

  static const String ticketClosed =
      'closed';

  static const String ticketReopened =
      'reopened';

  // =====================================================
  // NOTIFICATION STATUS
  // =====================================================

  static const String notificationDraft =
      'draft';

  static const String notificationScheduled =
      'scheduled';

  static const String notificationSent =
      'sent';

  static const String notificationDelivered =
      'delivered';

  static const String notificationFailed =
      'failed';

  static const String notificationRead =
      'read';

  // =====================================================
  // COUPON STATUS
  // =====================================================

  static const String couponActive =
      'active';

  static const String couponInactive =
      'inactive';

  static const String couponExpired =
      'expired';

  static const String couponScheduled =
      'scheduled';

  // =====================================================
  // BANNER STATUS
  // =====================================================

  static const String bannerActive =
      'active';

  static const String bannerInactive =
      'inactive';

  static const String bannerScheduled =
      'scheduled';

  // =====================================================
  // REVIEW STATUS
  // =====================================================

  static const String reviewPending =
      'pending';

  static const String reviewApproved =
      'approved';

  static const String reviewRejected =
      'rejected';

  static const String reviewHidden =
      'hidden';

  // =====================================================
  // PRIORITY STATUS
  // =====================================================

  static const String low =
      'low';

  static const String medium =
      'medium';

  static const String high =
      'high';

  static const String critical =
      'critical';

  // =====================================================
  // GET DISPLAY LABEL
  // =====================================================

  static String formatStatus(
    String status,
  ) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() +
                    word.substring(1),
        )
        .join(' ');
  }
}